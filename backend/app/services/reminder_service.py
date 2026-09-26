# app/services/reminder_service.py
"""
تذكيرات دورية عبر الإشعارات الفورية:
  1. متأخرات الاشتراك: تنبيه المحاسبين/المدراء بالأعضاء الذين لديهم مبلغ
     متأخر (balance_due > 0)
  2. المواعيد القادمة: تنبيه المدراء بموعد يقترب خلال يوم واحد

FastAPI بحد ذاته ليس خادم مهام مجدولة. لتشغيل هذه الدوال دورياً:

  الخيار الأول (الأبسط - موصى به): أضف مهمة cron على مستوى نظام التشغيل
  تستدعي المسار الإداري POST /admin/run-reminders يومياً، مثال Linux:
      0 8 * * * curl -X POST -H "Authorization: Bearer <admin_token>" \
                 https://your-server.com/admin/run-reminders

  الخيار الثاني: استخدم APScheduler (يتطلب حزمة إضافية) وشغّلها عند
  إقلاع التطبيق في main.py.

كلا الخيارين يستدعيان نفس الدوال هنا.
"""
from sqlalchemy.orm import Session

from app.models.member import Member
from app.models.records import Event
from app.models.user import User, RoleEnum
from app.services import push_service


def _active_staff_ids(db, roles):
    return [
        u.id for u in db.query(User).filter(
            User.role.in_(roles),
            User.deleted == False,  # noqa: E712
            User.is_active == True,  # noqa: E712
        ).all()
    ]


def send_overdue_subscription_reminders(db: Session) -> int:
    """
    يرسل تذكيراً واحداً مجمّعاً (وليس رسالة لكل عضو متأخر على حدة) لكل من
    admin و accountant بعدد الأعضاء المتأخرين وإجمالي المبلغ المتأخر.
    """
    overdue_members = db.query(Member).filter(Member.balance_due > 0, Member.deleted == False).all()  # noqa: E712
    if not overdue_members:
        return 0

    total_due = sum(m.balance_due for m in overdue_members)
    recipient_ids = _active_staff_ids(db, [RoleEnum.admin, RoleEnum.accountant])

    for uid in recipient_ids:
        push_service.send_to_user(
            db, uid,
            title="تذكير بمتأخرات الاشتراكات",
            body=f"{len(overdue_members)} عضو لديهم متأخرات بإجمالي {total_due:,} ﷼",
            data={"type": "subscription_overdue"},
        )

    return len(recipient_ids)


def send_upcoming_event_reminders(db: Session, within_days: int = 1) -> int:
    """
    يرسل تذكيراً بكل حدث يقع خلال within_days يوماً من الآن. event_date
    مخزّن كنص (YYYY-MM-DD) وليس تاريخاً حقيقياً في قاعدة البيانات (لتبسيط
    المزامنة بين الأجهزة)، لذا تُقارَن السلاسل النصية مباشرة.
    """
    from datetime import date, timedelta

    today = date.today()
    target_dates = {(today + timedelta(days=i)).isoformat() for i in range(within_days + 1)}

    upcoming = db.query(Event).filter(Event.deleted == False, Event.event_date.in_(target_dates)).all()  # noqa: E712
    if not upcoming:
        return 0

    recipient_ids = _active_staff_ids(db, [RoleEnum.admin])

    count = 0
    for event in upcoming:
        for uid in recipient_ids:
            push_service.send_to_user(
                db, uid,
                title="تذكير بموعد قادم",
                body=f"{event.title} - {event.event_date}" + (f" الساعة {event.event_time}" if event.event_time else ""),
                data={"type": "event_reminder", "event_id": str(event.id)},
            )
            count += 1

    return count


def run_all_reminders(db: Session) -> dict:
    """نقطة دخول واحدة تُشغّل كل أنواع التذكيرات معاً."""
    overdue_count = send_overdue_subscription_reminders(db)
    events_count = send_upcoming_event_reminders(db)
    return {"overdue_reminders_sent": overdue_count, "event_reminders_sent": events_count}

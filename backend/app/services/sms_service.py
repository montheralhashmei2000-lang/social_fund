# app/services/sms_service.py
"""
إشعار الأعضاء بنتيجة طلباتهم عبر قناة خارجية (الأعضاء لا يملكون حسابات دخول).

ترتيب المحاولات:
  1. بوابة HTTP عامة عند ضبط SMS_GATEWAY_URL (POST JSON: phone, message
     مع ترويسة Bearer إن ضُبط SMS_GATEWAY_TOKEN) — تصلح لأي مزود محلي.
  2. Twilio بنفس إعدادات OTP (TWILIO_ACCOUNT_SID / TWILIO_AUTH_TOKEN /
     TWILIO_FROM_NUMBER) عند توفرها.
  3. وإلا يُسجل النص في سجلات الخادم فقط (حتى تُعدّ بوابتك).
الفشل لا يُعطّل العملية الأصلية أبداً — يُسجل ويُكمل.
"""
import logging

import httpx
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.member import Member

logger = logging.getLogger("sms_service")


def _format_phone(phone: str) -> str:
    return phone if phone.startswith("+") else f"+967{phone.lstrip('0')}"


def send_sms(phone: str, message: str) -> str:
    """يعيد: gateway / twilio / logged / failed (للتوثيق في السجلات)."""
    if not phone:
        logger.info("SMS (لا رقم هاتف): %s", message)
        return "logged"
    try:
        if settings.SMS_GATEWAY_URL:
            headers = {"Authorization": f"Bearer {settings.SMS_GATEWAY_TOKEN}"} if getattr(settings, "SMS_GATEWAY_TOKEN", None) else {}
            resp = httpx.post(
                settings.SMS_GATEWAY_URL,
                json={"phone": _format_phone(phone), "message": message},
                headers=headers, timeout=10,
            )
            if resp.status_code < 300:
                return "gateway"
            logger.error("بوابة SMS رفضت الرسالة: %s", resp.status_code)
            return "failed"
    except Exception as e:
        logger.error("فشل إرسال SMS عبر البوابة: %s", e)
        return "failed"

    if settings.TWILIO_ACCOUNT_SID and settings.TWILIO_AUTH_TOKEN and settings.TWILIO_FROM_NUMBER:
        try:
            from twilio.rest import Client
            Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN).messages.create(
                body=message, from_=settings.TWILIO_FROM_NUMBER, to=_format_phone(phone),
            )
            return "twilio"
        except Exception as e:
            logger.error("فشل إرسال SMS عبر Twilio: %s", e)
            return "failed"

    logger.info("SMS (لا بوابة مضبوطة) إلى %s: %s", phone, message)
    return "logged"


def notify_aid_status(db: Session, aid, old_status: str, new_status: str):
    """يُستدعى آلياً بعد كل تغيير حالة طلب مساعدة - يبلغ العضو بنتيجة طلبه."""
    member = db.query(Member).filter(Member.id == aid.member_id).first()
    message = (
        f"عزيزي {aid.member_name}، تم تحديث حالة طلب المساعدة ({aid.aid_type}) "
        f"من {old_status} إلى {new_status}. - الصندوق الاجتماعي التنموي"
    )
    outcome = send_sms(getattr(member, "phone", None) or "", message)
    logger.info("إشعار عضو عن طلب مساعدة: النتيجة=%s", outcome)
    return outcome

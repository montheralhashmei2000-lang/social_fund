# app/services/push_service.py
"""
إرسال إشعارات FCM عبر Firebase Admin SDK.

الاستيراد هنا كسول (lazy): غياب حزمة firebase_admin أو ملف بيانات الاعتماد
لا يوقف الخادم ولا يستورد الشبكة عند الإقلاع - الإشعارات تُعطَّل فقط.
"""
import logging
from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.device_token import DeviceToken

logger = logging.getLogger("push_service")

_firebase_app = None
_init_attempted = False


def _get_firebase_app():
    global _firebase_app, _init_attempted
    if _firebase_app is not None:
        return _firebase_app
    if _init_attempted:
        return None

    _init_attempted = True
    try:
        import firebase_admin
        from firebase_admin import credentials
        cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
        _firebase_app = firebase_admin.initialize_app(cred)
        logger.info("Firebase Admin SDK initialized.")
    except ImportError:
        logger.warning("حزمة firebase-admin غير مثبتة - الإشعارات معطّلة.")
        _firebase_app = None
    except Exception as e:
        logger.warning(
            "Firebase not configured (%s). Push notifications are disabled "
            "until a valid credentials file is provided at %s.",
            e, settings.FIREBASE_CREDENTIALS_PATH,
        )
        _firebase_app = None
    return _firebase_app


def register_token(db: Session, user_id, token, platform=None):
    existing = db.query(DeviceToken).filter(DeviceToken.token == token).first()
    if existing:
        existing.user_id = user_id
        existing.platform = platform
        existing.last_used_at = datetime.now(timezone.utc)
    else:
        db.add(DeviceToken(user_id=user_id, token=token, platform=platform))
    db.commit()


def unregister_token(db: Session, token, user_id=None):
    """يحذف token بشرط ملكيته للمستخدم الممرر (إصلاح ملاحظة الفحص 3).

    user_id=None يعني بلا تحقق ملكية - لا يُستخدم من المسارات العامة.
    """
    q = db.query(DeviceToken).filter(DeviceToken.token == token)
    if user_id is not None:
        q = q.filter(DeviceToken.user_id == user_id)
    deleted = q.delete(synchronize_session=False)
    db.commit()
    return deleted


def send_to_user(db: Session, user_id, title, body, data=None):
    app = _get_firebase_app()
    if app is None:
        return

    from firebase_admin import messaging as fcm

    tokens = [t.token for t in db.query(DeviceToken).filter(DeviceToken.user_id == user_id).all()]
    if not tokens:
        return

    message = fcm.MulticastMessage(
        notification=fcm.Notification(title=title, body=body),
        data={k: str(v) for k, v in (data or {}).items()},
        tokens=tokens,
    )

    try:
        response = fcm.send_multicast(message, app=app)
        if response.failure_count:
            _cleanup_invalid_tokens(db, tokens, response)
    except Exception as e:
        logger.warning("Push send failed: %s", e)


def _cleanup_invalid_tokens(db, tokens, response):
    from firebase_admin import messaging as fcm

    for token, result in zip(tokens, response.responses):
        if not result.success and result.exception:
            code = getattr(result.exception, "code", "")
            if code in (fcm.UnregisteredError.code if hasattr(fcm.UnregisteredError, "code") else "UNREGISTERED",
                        "NOT_FOUND", "UNREGISTERED", "INVALID_ARGUMENT"):
                db.query(DeviceToken).filter(DeviceToken.token == token).delete(synchronize_session=False)
    db.commit()


def notify_new_aid_request(db, reviewer_user_ids, member_name, aid_type, amount, aid_id):
    for uid in reviewer_user_ids:
        send_to_user(
            db, uid,
            title="طلب مساعدة جديد",
            body=f"{member_name} - {aid_type} ({amount:,} ﷼)",
            data={"type": "aid_new", "aid_id": str(aid_id)},
        )


def notify_new_message(db, to_user_id, from_name, body_preview, message_id):
    send_to_user(
        db, to_user_id,
        title=f"رسالة جديدة من {from_name}",
        body=body_preview[:100],
        data={"type": "message_new", "message_id": str(message_id)},
    )

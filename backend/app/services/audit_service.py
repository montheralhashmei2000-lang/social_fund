# app/services/audit_service.py
import json
from app.models.audit import AuditLog


def log_action(db, user, action, resource_type, resource_id=None,
                summary=None, changes=None, ip_address=None, device_id=None):
    """
    Writes one immutable audit row. Call this inside the same DB transaction
    as the actual data change so both succeed or fail together.

    changes: optional dict like {"status": {"old": "...", "new": "..."}}
    """
    entry = AuditLog(
        user_id=user.id if user else None,
        user_name=user.full_name if user else "نظام",
        action=action,
        resource_type=resource_type,
        resource_id=str(resource_id) if resource_id else None,
        summary=summary,
        changes=json.dumps(changes, ensure_ascii=False, default=str) if changes else None,
        ip_address=ip_address,
        device_id=device_id,
    )
    db.add(entry)
    return entry

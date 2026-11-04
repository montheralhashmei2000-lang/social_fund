# app/routers/sync.py
"""
نقطة مزامنة العمليات المتراكمة (Background Synchronization).

المعمارية: "محلياً أولاً" - تطبيق Flutter يكتب في SQLite ثم يضع العملية في
طابور (outbox). عند توفّر الشبكة ولو لفترة قصيرة يرسل كل العمليات المتراكمة
في حزمة واحدة إلى هذا المسار، فيُطبّقها الخادم بشكل ذرّي ومتسلسل.

كل عملية تُطبَّق بشكل مستقل (idempotent upsert) حتى لا يُفسد فشل عملية واحدة
بقية الحزمة. العمليات الفاشلة تُعاد إلى التطبيق لإعادة المحاولة لاحقاً.
"""
from fastapi import APIRouter, Depends, Request, HTTPException, status
from sqlalchemy.orm import Session
from typing import Any, Dict, List, Optional
from datetime import datetime, timezone

from app.core.database import get_db
from app.core.deps import get_current_user, require_permission, get_client_ip
from app.core.encryption import search_hash
from app.models.user import User, has_permission
from app.models.member import Member
from app.models.records import AidRequest, Event, Subscription, TreasuryEntry, Voucher
from app.models.fund_settings import FundSettings
from app.models.welfare import Beneficiary, PeriodicAid

router = APIRouter(prefix="/sync", tags=["Sync"])


# ===== خرائط الكيانات: (الموديل، الصلاحية المطلوبة، الحقول المسموحة) =====

_ENTITY_SPECS: Dict[str, Dict[str, Any]] = {
    "member": {
        "model": Member,
        "permission": "members",
        "fields": [
            "name", "national_id", "phone", "email", "city", "join_date",
            "status", "monthly_subscription", "total_paid", "balance_due",
        ],
        "required": ["name", "national_id", "phone"],
    },
    "aid_request": {
        "model": AidRequest,
        "permission": "aids",
        "fields": [
            "member_id", "member_name", "aid_type", "amount", "request_date",
            "status", "note", "reviewer_name",
        ],
        "required": ["member_id", "member_name", "aid_type", "amount", "request_date"],
    },
    "event": {
        "model": Event,
        "permission": "events",
        "fields": ["title", "event_date", "event_time", "place", "type", "color"],
        "required": ["title", "event_date"],
    },
    "treasury_entry": {
        "model": TreasuryEntry,
        "permission": "treasury",
        "fields": ["type", "category", "description", "amount", "entry_date", "reference_no"],
        "required": ["type", "category", "description", "amount", "entry_date"],
    },
    "subscription": {
        "model": Subscription,
        "permission": "subscriptions",
        "fields": [
            "member_id", "member_name", "amount", "payment_date", "method",
            "reference_no",
        ],
        "required": ["member_id", "amount", "payment_date", "method"],
    },
    "voucher": {
        "model": Voucher,
        "permission": "vouchers",
        # voucher_no و issued_by_name يولّدهما الخادم - لا تُرسل من الجهاز
        # (العميل لا يعرف العدّاد المركزي). journal_entry_id يُملأ في الخادم.
        "fields": [
            "kind", "member_id", "member_name", "donor_id", "beneficiary_id",
            "party_name", "amount", "voucher_date", "method", "description",
            "status", "treasury_account_id", "counter_account_id",
        ],
        "required": [
            "kind", "amount", "voucher_date", "method", "description",
        ],
    },
    "fund_settings": {
        "model": FundSettings,
        "permission": "settings",
        "fields": [
            "name", "logo_base64", "phone", "email", "address", "registration_no",
        ],
        "required": ["name"],
    },
    "beneficiary": {
        "model": Beneficiary,
        "permission": "beneficiaries",
        "fields": [
            "full_name", "national_id", "phone", "family_size", "monthly_income",
            "housing", "case_summary", "status",
        ],
        "required": ["full_name"],
    },
    "periodic_aid": {
        "model": PeriodicAid,
        "permission": "beneficiaries",
        "fields": ["beneficiary_id", "monthly_amount", "started_on", "status", "notes"],
        "required": ["beneficiary_id", "monthly_amount", "started_on"],
    },
}


def _apply_op(db: Session, op: Dict[str, Any]) -> None:
    """تطبيق عملية واحدة على قاعدة البيانات (upsert أو حذف منطقي)."""
    entity_type = str(op.get("entity_type") or "")
    spec = _ENTITY_SPECS.get(entity_type)
    if spec is None:
        raise ValueError(f"نوع كيان غير مدعوم: {entity_type}")

    model = spec["model"]
    entity_id = str(op.get("entity_id") or "")
    if not entity_id:
        raise ValueError("معرّف الكيان مطلوب")

    operation = str(op.get("operation") or "upsert")
    payload: Dict[str, Any] = op.get("payload") or {}

    # الحذف منطقي (soft delete) - يبقى السجل للتدقيق.
    if operation == "delete":
        obj = db.get(model, entity_id)
        if obj is None:
            return
        if hasattr(obj, "deleted"):
            obj.deleted = True
        else:
            db.delete(obj)
        db.flush()
        return

    if operation not in ("upsert", "create", "update"):
        raise ValueError(f"عملية غير مدعومة: {operation}")

    values: Dict[str, Any] = {}
    for field in spec["fields"]:
        if field in payload:
            values[field] = payload[field]

    for field in spec["required"]:
        if values.get(field) in (None, ""):
            raise ValueError(f"الحقل المطلوب مفقود: {field}")

    # تجزئة البحث لرقم الهوية (تشفير شفاف + فهرس بحث).
    if values.get("national_id"):
        values["national_id_search"] = search_hash(values["national_id"])

    obj = db.get(model, entity_id)
    is_new = obj is None
    if is_new:
        obj = model(id=entity_id)
        db.add(obj)

    # السند يحتاج حقولاً يولّدها الخادم (رقم السند ومُصدِره) ولا يملكها الجهاز.
    if entity_type == "voucher":
        _fill_voucher_server_fields(db, obj, values, is_new)

    for key, val in values.items():
        setattr(obj, key, val)
    db.flush()


def _fill_voucher_server_fields(
    db: Session, obj: Voucher, values: Dict[str, Any], is_new: bool
) -> None:
    """توليد الحقول التي لا يمكن للجهاز معرفتها: رقم السند واسم المُصدِر."""
    from app.routers.vouchers import next_voucher_no
    from app.services import sequence_service

    if is_new or not obj.voucher_no:
        kind = values.get("kind") or "قبض"
        # قد تصل القيمة كنص أو كـ Enum من الحزمة.
        kind = kind.value if hasattr(kind, "value") else str(kind)
        obj.voucher_no = next_voucher_no(db, kind)
    if not obj.issued_by_name:
        obj.issued_by_name = values.get("issued_by_name") or "مزامنة تلقائية"


@router.post("/push")
def push_operations(
    request: Request,
    body: Dict[str, Any],
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """
    استقبال حزمة عمليات متراكمة وتطبيقها على الخادم.

    يستجيب بـ:
      applied: قائمة العمليات التي طُبّقت بنجاح
      failed:  قائمة العمليات التي فشلت (مع السبب) لتعيد المحاولة
    """
    operations = body.get("operations") or []
    if not isinstance(operations, list):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "صيغة operations غير صحيحة")

    applied: List[Dict[str, Any]] = []
    failed: List[Dict[str, Any]] = []

    # ترتيب العمليات حسب تسلسلها الزمني (op_seq) لضمان تماسك الترتيب.
    def _seq(op: Dict[str, Any]) -> int:
        try:
            return int(op.get("seq") or 0)
        except (TypeError, ValueError):
            return 0

    ordered = sorted(operations, key=_seq)

    for op in ordered:
        op_id = str(op.get("op_id") or "")
        entity_type = str(op.get("entity_type") or "")
        entity_id = str(op.get("entity_id") or "")
        try:
            spec = _ENTITY_SPECS.get(entity_type)
            if spec is None:
                raise ValueError(f"نوع كيان غير مدعوم: {entity_type}")

            # فحص الصلاحية لكل نوع كيان (RBAC) - لا تجاوز مسموح.
            if not has_permission(user.role, spec["permission"]):
                raise ValueError(f"لا تملك صلاحية: {spec['permission']}")

            _apply_op(db, op)
            applied.append({
                "op_id": op_id,
                "entity_type": entity_type,
                "entity_id": entity_id,
            })
        except Exception as exc:  # noqa: BLE001 - نُرجع سبب الفشل للعميل
            failed.append({
                "op_id": op_id,
                "entity_type": entity_type,
                "entity_id": entity_id,
                "error": str(exc),
            })

    # commit واحد لكل الحزمة - ذرّي.
    try:
        db.commit()
    except Exception:
        db.rollback()
        raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, "فشل حفظ الدفعة على الخادم")

    return {
        "applied": applied,
        "failed": failed,
        "server_time": datetime.now(timezone.utc).isoformat(),
        "counts": {"applied": len(applied), "failed": len(failed)},
    }


@router.get("/status")
def sync_status(
    db: Session = Depends(get_db),
    user: User = Depends(require_permission("members")),
):
    """حالة الخادم للمزامنة - تُستخدم للتحقق من جاهزية الاتصال."""
    return {
        "status": "ok",
        "server_time": datetime.now(timezone.utc).isoformat(),
        "supported_entities": sorted(_ENTITY_SPECS.keys()),
    }


def _iso(value: Any) -> Optional[str]:
    """تحويل طابع زمني إلى ISO-8601 (UTC) للمزامنة."""
    if value is None:
        return None
    if isinstance(value, datetime):
        if value.tzinfo is None:
            value = value.replace(tzinfo=timezone.utc)
        return value.astimezone(timezone.utc).isoformat()
    return str(value)


@router.get("/pull")
def pull_changes(
    since: Optional[str] = None,
    entities: Optional[str] = None,
    limit: int = 500,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """
    سحب تغييرات الخادم إلى الجهاز (Local-First).

    - since: آخر طابع زمني استلمه الجهاز (ISO-8601) - تُرجع ما هو أحدث منه.
    - entities: أنواع الكيانات المطلوبة مفصولة بفواصل (الافتراضي: الكل المسموح).
    - limit: أقصى عدد صفوف لكل كيان في الاستجابة.
    """
    wanted = None
    if entities:
        wanted = {e.strip() for e in entities.split(",") if e.strip()}

    since_dt: Optional[datetime] = None
    if since:
        try:
            since_dt = datetime.fromisoformat(since.replace("Z", "+00:00"))
            if since_dt.tzinfo is None:
                since_dt = since_dt.replace(tzinfo=timezone.utc)
        except ValueError:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "صيغة since غير صحيحة")

    limit = max(1, min(int(limit or 500), 2000))
    data: Dict[str, List[Dict[str, Any]]] = {}
    skipped: List[str] = []

    for entity_type, spec in _PULL_SPECS.items():
        if wanted is not None and entity_type not in wanted:
            continue
        if not has_permission(user.role, spec["permission"]):
            # لا يُرفع خطأ: بعض الأدوار لا ترى كل الكيانات.
            skipped.append(entity_type)
            continue

        query = db.query(spec["model"])
        if since_dt is not None:
            query = query.filter(spec["model"].updated_at > since_dt)
        rows = query.order_by(spec["model"].updated_at.asc()).limit(limit).all()
        data[entity_type] = [spec["out"](o) for o in rows]

    return {
        "data": data,
        "server_time": datetime.now(timezone.utc).isoformat(),
        "skipped_entities": skipped,
        "counts": {k: len(v) for k, v in data.items()},
    }


# ===== السحب: تنزيل تغييرات الخادم إلى الجهاز =====

# خرائط الإخراج: (الموديل، دالة التحويل، الصلاحية المطلوبة)
_PULL_SPECS: Dict[str, Dict[str, Any]] = {
    "member": {
        "model": Member,
        "permission": "members",
        "out": lambda o: {
            "id": str(o.id), "name": o.name, "national_id": o.national_id,
            "phone": o.phone, "email": o.email, "city": o.city,
            "join_date": o.join_date,
            "status": o.status.value if hasattr(o.status, "value") else o.status,
            "monthly_subscription": o.monthly_subscription or 0,
            "total_paid": o.total_paid or 0, "balance_due": o.balance_due or 0,
            "updated_at": _iso(o.updated_at), "deleted": bool(o.deleted),
        },
    },
    "aid_request": {
        "model": AidRequest,
        "permission": "aids",
        "out": lambda o: {
            "id": str(o.id), "member_id": str(o.member_id),
            "member_name": o.member_name, "aid_type": o.aid_type,
            "amount": o.amount, "request_date": o.request_date,
            "status": o.status, "note": o.note, "reviewer_name": o.reviewer_name,
            "updated_at": _iso(o.updated_at), "deleted": bool(o.deleted),
        },
    },
    "subscription": {
        "model": Subscription,
        "permission": "subscriptions",
        "out": lambda o: {
            "id": str(o.id), "member_id": str(o.member_id),
            "member_name": o.member_name, "amount": o.amount,
            "payment_date": o.payment_date, "method": o.method,
            "reference_no": o.reference_no,
            "updated_at": _iso(o.updated_at), "deleted": bool(o.deleted),
        },
    },
    "treasury_entry": {
        "model": TreasuryEntry,
        "permission": "treasury",
        "out": lambda o: {
            "id": str(o.id),
            "type": o.type.value if hasattr(o.type, "value") else o.type,
            "category": o.category, "description": o.description,
            "amount": o.amount, "entry_date": o.entry_date,
            "reference_no": o.reference_no,
            "updated_at": _iso(o.updated_at), "deleted": bool(o.deleted),
        },
    },
    "voucher": {
        "model": Voucher,
        "permission": "vouchers",
        "out": lambda o: {
            "id": str(o.id), "voucher_no": o.voucher_no,
            "kind": o.kind.value if hasattr(o.kind, "value") else o.kind,
            "member_id": str(o.member_id) if o.member_id else None,
            "member_name": o.member_name or "",
            "donor_id": str(o.donor_id) if o.donor_id else None,
            "beneficiary_id": str(o.beneficiary_id) if o.beneficiary_id else None,
            "party_name": o.party_name, "amount": o.amount,
            "voucher_date": o.voucher_date, "method": o.method,
            "description": o.description, "issued_by_name": o.issued_by_name,
            "status": o.status,
            "treasury_account_id": str(o.treasury_account_id) if o.treasury_account_id else None,
            "counter_account_id": str(o.counter_account_id) if o.counter_account_id else None,
            "journal_entry_id": str(o.journal_entry_id) if o.journal_entry_id else None,
            "updated_at": _iso(o.updated_at), "deleted": bool(o.deleted),
        },
    },
    "event": {
        "model": Event,
        "permission": "events",
        "out": lambda o: {
            "id": str(o.id), "title": o.title, "event_date": o.event_date,
            "event_time": o.event_time, "place": o.place, "type": o.type,
            "color": o.color or "#1B5E20",
            "updated_at": _iso(o.updated_at), "deleted": bool(o.deleted),
        },
    },
    "fund_settings": {
        "model": FundSettings,
        "permission": "settings",
        "out": lambda o: {
            "id": str(o.id), "name": o.name, "logo_base64": o.logo_base64,
            "phone": o.phone, "email": o.email, "address": o.address,
            "registration_no": o.registration_no,
            "updated_at": _iso(o.updated_at), "deleted": bool(o.deleted),
        },
    },
}
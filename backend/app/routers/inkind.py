# app/routers/inkind.py
"""المساعدات العينية: بنود المخزون وحركات الإدخال والإخراج."""
from datetime import date
from decimal import Decimal
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import require_permission
from app.models.user import User
from app.models.welfare import InKindItem, InKindMovement
from app.services.audit_service import log_action

router = APIRouter(prefix="/inkind", tags=["In-Kind Aid & Inventory"])


class ItemIn(BaseModel):
    name: str
    unit: str = "قطعة"
    reorder_level: float = 0


class MovementIn(BaseModel):
    item_id: str
    direction: str  # in / out
    quantity: float
    movement_date: str
    beneficiary_id: Optional[str] = None
    campaign_id: Optional[str] = None
    note: Optional[str] = None


@router.get("/items")
def list_items(db: Session = Depends(get_db), user: User = Depends(require_permission("inkind"))):
    return [
        {
            "id": str(i.id), "name": i.name, "unit": i.unit,
            "quantity": float(i.quantity or 0), "reorder_level": float(i.reorder_level or 0),
            "low_stock": (i.reorder_level or 0) > 0 and (i.quantity or 0) <= (i.reorder_level or 0),
        }
        for i in db.query(InKindItem).order_by(InKindItem.name).all()
    ]


@router.post("/items", status_code=status.HTTP_201_CREATED)
def create_item(payload: ItemIn, db: Session = Depends(get_db), user: User = Depends(require_permission("inkind"))):
    item = InKindItem(**payload.model_dump())
    db.add(item)
    log_action(db, user, "create", "inkind_item", resource_id=item.id, summary=f"بند مخزون جديد: {item.name}")
    db.commit()
    return {"message": "تم إنشاء البند"}


@router.post("/movements", status_code=status.HTTP_201_CREATED)
def create_movement(payload: MovementIn, db: Session = Depends(get_db), user: User = Depends(require_permission("inkind"))):
    item = db.query(InKindItem).filter(InKindItem.id == payload.item_id).first()
    if not item:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "البند غير موجود")
    if payload.direction not in ("in", "out"):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "الاتجاه يجب أن يكون in أو out")
    qty = Decimal(str(payload.quantity))
    if qty <= 0:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "الكمية يجب أن تكون أكبر من صفر")

    if payload.direction == "out" and qty > (item.quantity or 0):
        raise HTTPException(status.HTTP_400_BAD_REQUEST,
                            f"الكمية المطلوبة {qty} أكبر من المتوفر ({item.quantity})")

    m = InKindMovement(
        item_id=item.id, direction=payload.direction, quantity=qty,
        movement_date=date.fromisoformat(payload.movement_date),
        beneficiary_id=payload.beneficiary_id, campaign_id=payload.campaign_id,
        note=payload.note, by_user_id=user.id,
    )
    db.add(m)
    item.quantity = (item.quantity or 0) + (qty if payload.direction == "in" else -qty)
    log_action(db, user, "create", "inkind_movement", resource_id=item.id,
               summary=f"حركة {payload.direction} للبند {item.name} بكمية {qty}")
    db.commit()
    return {"message": "تم تسجيل الحركة", "new_quantity": float(item.quantity)}


@router.get("/movements")
def list_movements(item_id: Optional[str] = None, db: Session = Depends(get_db), user: User = Depends(require_permission("inkind"))):
    q = db.query(InKindMovement).order_by(InKindMovement.movement_date.desc())
    if item_id:
        q = q.filter(InKindMovement.item_id == item_id)
    return [
        {
            "id": str(m.id), "item_id": str(m.item_id), "direction": m.direction,
            "quantity": float(m.quantity), "movement_date": m.movement_date.isoformat(),
            "note": m.note,
        }
        for m in q.limit(300).all()
    ]

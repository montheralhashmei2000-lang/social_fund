# app/routers/push.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.services import push_service

router = APIRouter(prefix="/push", tags=["Push Notifications"])


class RegisterTokenRequest(BaseModel):
    token: str
    platform: Optional[str] = None


class UnregisterTokenRequest(BaseModel):
    token: str


@router.post("/register-token")
def register_token(payload: RegisterTokenRequest, db: Session = Depends(get_db),
                   user: User = Depends(get_current_user)):
    push_service.register_token(db, user.id, payload.token, payload.platform)
    return {"message": "تم تسجيل الجهاز لاستقبال الإشعارات"}


@router.post("/unregister-token")
def unregister_token(payload: UnregisterTokenRequest, db: Session = Depends(get_db),
                     user: User = Depends(get_current_user)):
    # إصلاح الثغرة رقم 3 في تقرير الفحص: كان أي مستخدم مسجَّل يستطيع إلغاء
    # تسجيل token جهاز مستخدم آخر إذا عرف قيمته. الآن يُقبل token المستخدم
    # الحالي فقط.
    deleted = push_service.unregister_token(db, payload.token, user.id)
    if not deleted:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "الرمز غير موجود لهذا الحساب")
    return {"message": "تم إلغاء تسجيل الجهاز"}

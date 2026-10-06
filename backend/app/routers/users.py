# app/routers/users.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel

from app.core.database import get_db
from app.core.deps import get_current_user
from app.core.security import hash_password
from app.models.user import User, RoleEnum
from app.services.audit_service import log_action

router = APIRouter(prefix="/users", tags=["User Management"])

PASSWORD_MIN_LENGTH = 8


class UserCreate(BaseModel):
    username: str
    password: str
    full_name: str
    role: str
    phone: Optional[str] = None


class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    role: Optional[str] = None
    phone: Optional[str] = None
    is_active: Optional[bool] = None


class UserListOut(BaseModel):
    id: str
    username: str
    full_name: str
    role: str
    is_active: bool
    phone: Optional[str] = None

    class Config:
        from_attributes = True


class ColleagueOut(BaseModel):
    """قائمة الزملاء لأغراض اختيار مستلم رسالة داخلية فقط - بلا بيانات اتصال."""
    id: str
    username: str
    full_name: str
    role: str
    avatar_initial: Optional[str] = None


def _to_list_out(u: User) -> UserListOut:
    return UserListOut(
        id=str(u.id), username=u.username, full_name=u.full_name,
        role=u.role.value, is_active=u.is_active, phone=u.phone,
    )


def require_admin(user: User = Depends(get_current_user)) -> User:
    if user.role != RoleEnum.admin:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "إدارة المستخدمين متاحة لمدير النظام فقط")
    return user


@router.get("/colleagues", response_model=List[ColleagueOut])
def list_colleagues(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """
    أي مستخدم مسجَّل يمكنه رؤية قائمة الزملاء النشطين لاختيار مستلم رسالة
    داخلية - لكن الاستجابة لا تتضمن أرقام الهواتف أو أي بيانات اتصال
    (إصلاح الملاحظة 4 في تقرير الفحص). الهاتف متاح للمدير فقط عبر
    GET /users (القائمة الإدارية).
    """
    rows = (
        db.query(User)
        .filter(User.deleted == False, User.is_active == True, User.id != user.id)  # noqa: E712
        .order_by(User.full_name)
        .all()
    )
    return [
        ColleagueOut(
            id=str(u.id), username=u.username, full_name=u.full_name,
            role=u.role.value, avatar_initial=u.avatar_initial,
        )
        for u in rows
    ]


@router.get("", response_model=List[UserListOut])
def list_users(db: Session = Depends(get_db), admin: User = Depends(require_admin)):
    return db.query(User).filter(User.deleted == False).order_by(User.full_name).all()  # noqa: E712


@router.post("", response_model=UserListOut, status_code=status.HTTP_201_CREATED)
def create_user(payload: UserCreate, db: Session = Depends(get_db), admin: User = Depends(require_admin)):
    if db.query(User).filter(User.username == payload.username).first():
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "اسم المستخدم موجود مسبقاً")
    if len(payload.password) < PASSWORD_MIN_LENGTH:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            f"كلمة المرور يجب أن تكون {PASSWORD_MIN_LENGTH} أحرف على الأقل",
        )
    try:
        role = RoleEnum(payload.role)
    except ValueError:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "دور غير صالح")

    new_user = User(
        username=payload.username,
        password_hash=hash_password(payload.password),
        full_name=payload.full_name,
        role=role,
        phone=payload.phone,
        avatar_initial=payload.full_name[0] if payload.full_name else "?",
    )
    db.add(new_user)
    db.flush()
    log_action(db, admin, "create", "user", resource_id=new_user.id,
               summary=f"إنشاء مستخدم جديد: {payload.username} ({payload.role})")
    db.commit()
    db.refresh(new_user)
    return _to_list_out(new_user)


@router.put("/{user_id}", response_model=UserListOut)
def update_user(user_id: str, payload: UserUpdate, db: Session = Depends(get_db), admin: User = Depends(require_admin)):
    target = db.query(User).filter(User.id == user_id, User.deleted == False).first()  # noqa: E712
    if not target:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "المستخدم غير موجود")

    updates = payload.model_dump(exclude_unset=True)
    if str(admin.id) == str(target.id) and (
        updates.get("is_active") is False or ("role" in updates and updates["role"] != RoleEnum.admin.value)
    ):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "لا يمكنك تعطيل حسابك أو خفض صلاحياتك بنفسك")
    if "role" in updates:
        try:
            updates["role"] = RoleEnum(updates["role"])
        except ValueError:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "دور غير صالح")

    for field, val in updates.items():
        setattr(target, field, val)

    log_action(db, admin, "update", "user", resource_id=target.id,
               summary=f"تحديث بيانات المستخدم: {target.username}", changes=updates)
    db.commit()
    db.refresh(target)
    return _to_list_out(target)


@router.delete("/{user_id}")
def deactivate_user(user_id: str, db: Session = Depends(get_db), admin: User = Depends(require_admin)):
    if str(admin.id) == user_id:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "لا يمكنك حذف حسابك الخاص")

    target = db.query(User).filter(User.id == user_id, User.deleted == False).first()  # noqa: E712
    if not target:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "المستخدم غير موجود")

    target.deleted = True
    target.is_active = False
    log_action(db, admin, "delete", "user", resource_id=target.id,
               summary=f"تعطيل/حذف المستخدم: {target.username}")
    db.commit()
    return {"message": "تم حذف المستخدم"}

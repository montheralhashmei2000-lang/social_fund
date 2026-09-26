# app/core/deps.py
from fastapi import Depends, HTTPException, status, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import decode_token
from app.models.user import User, has_permission

bearer_scheme = HTTPBearer(auto_error=False)


def get_current_user(creds: HTTPAuthorizationCredentials = Depends(bearer_scheme),
                      db: Session = Depends(get_db)) -> User:
    if creds is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "غير مصرح - يرجى تسجيل الدخول")

    payload = decode_token(creds.credentials)
    if not payload or payload.get("type") != "access":
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "الجلسة منتهية أو غير صالحة")

    user_id = payload.get("sub")
    user = db.query(User).filter(User.id == user_id, User.deleted == False).first()  # noqa: E712
    if not user or not user.is_active:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "المستخدم غير موجود أو معطّل")
    return user


def require_permission(resource: str):
    def checker(user: User = Depends(get_current_user)) -> User:
        if not has_permission(user.role, resource):
            raise HTTPException(
                status.HTTP_403_FORBIDDEN,
                f"صلاحياتك ({user.role.value}) لا تسمح بالوصول إلى: {resource}",
            )
        return user
    return checker


def get_client_ip(request: Request):
    fwd = request.headers.get("x-forwarded-for")
    if fwd:
        return fwd.split(",")[0].strip()
    return request.client.host if request.client else None

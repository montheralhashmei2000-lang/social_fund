# app/schemas/auth.py
from typing import Optional
from pydantic import BaseModel


class LoginRequest(BaseModel):
    username: str
    password: str


class LoginStep1Response(BaseModel):
    requires_otp: bool = True
    otp_token: str
    user_name: str
    phone_hint: Optional[str] = None


class OtpVerifyRequest(BaseModel):
    otp_token: str
    code: str
    device_id: Optional[str] = None


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class RefreshRequest(BaseModel):
    refresh_token: str


class LogoutRequest(BaseModel):
    refresh_token: Optional[str] = None


class UserOut(BaseModel):
    id: str
    username: str
    full_name: str
    role: str
    avatar_initial: str
    phone: Optional[str] = None

    class Config:
        from_attributes = True


class ChangePasswordRequest(BaseModel):
    old_password: str
    new_password: str

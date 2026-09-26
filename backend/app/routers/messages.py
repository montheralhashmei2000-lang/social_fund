# app/routers/messages.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import or_
from typing import List

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.records import Message
from app.models.user import User
from app.schemas.domain import MessageCreate, MessageOut
from app.services import push_service

router = APIRouter(prefix="/messages", tags=["Messages"])


@router.get("", response_model=List[MessageOut])
def list_my_messages(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    return (
        db.query(Message)
        .filter(Message.deleted == False, or_(Message.to_user_id == user.id, Message.from_user_id == user.id))  # noqa: E712
        .order_by(Message.created_at.desc())
        .all()
    )


@router.post("", response_model=MessageOut, status_code=status.HTTP_201_CREATED)
def send_message(payload: MessageCreate, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    recipient = db.query(User).filter(User.id == payload.to_user_id, User.deleted == False).first()  # noqa: E712
    if not recipient:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "المستلم غير موجود")

    msg = Message(
        from_user_id=user.id, from_name=user.full_name,
        to_user_id=recipient.id, to_name=recipient.full_name,
        body=payload.body, read=False,
    )
    db.add(msg)
    db.commit()
    db.refresh(msg)

    push_service.notify_new_message(db, recipient.id, user.full_name, payload.body, msg.id)

    return msg


@router.patch("/{message_id}/read", response_model=MessageOut)
def mark_read(message_id: str, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    msg = db.query(Message).filter(Message.id == message_id, Message.to_user_id == user.id).first()
    if not msg:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "الرسالة غير موجودة")
    msg.read = True
    db.commit()
    db.refresh(msg)
    return msg

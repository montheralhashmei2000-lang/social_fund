# app/routers/events.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.core.deps import require_permission
from app.models.records import Event
from app.models.user import User
from app.schemas.domain import EventCreate, EventOut

router = APIRouter(prefix="/events", tags=["Scheduler"])


@router.get("", response_model=List[EventOut])
def list_events(db: Session = Depends(get_db), user: User = Depends(require_permission("scheduler"))):
    return db.query(Event).filter(Event.deleted == False).order_by(Event.event_date).all()  # noqa: E712


@router.post("", response_model=EventOut, status_code=status.HTTP_201_CREATED)
def create_event(payload: EventCreate, db: Session = Depends(get_db),
                  user: User = Depends(require_permission("scheduler"))):
    event = Event(**payload.model_dump())
    db.add(event)
    db.commit()
    db.refresh(event)
    return event


@router.delete("/{event_id}")
def delete_event(event_id: str, db: Session = Depends(get_db),
                  user: User = Depends(require_permission("scheduler"))):
    event = db.query(Event).filter(Event.id == event_id, Event.deleted == False).first()  # noqa: E712
    if not event:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "الحدث غير موجود")
    event.deleted = True
    db.commit()
    return {"message": "تم حذف الحدث"}

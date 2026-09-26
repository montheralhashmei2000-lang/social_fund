#!/usr/bin/env bash
# تشغيل الخادم للتطوير: بيئة افتراضية + متطلبات + هجرات + uvicorn
set -e
cd "$(dirname "$0")/../backend"
[ -d .venv ] || python3 -m venv .venv
source .venv/bin/activate
pip install -q -r requirements.txt
export DATABASE_URL="${DATABASE_URL:-sqlite:///./socialfund.db}"
export SECRET_KEY="${SECRET_KEY:-dev-only-change-me}"
export FIELD_ENCRYPTION_KEY="${FIELD_ENCRYPTION_KEY:-dev-only-change-me-32bytes-key!!}"
export ENV="${ENV:-development}"
alembic upgrade head
exec uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

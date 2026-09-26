@echo off
REM Backend dev server (Windows) - same as run_backend_dev.sh
chcp 65001 >nul
cd /d "%~dp0..\backend"
if not exist .venv python -m venv .venv
call .venv\Scripts\activate.bat
pip install -q -r requirements.txt
if "%DATABASE_URL%"=="" set "DATABASE_URL=sqlite:///./socialfund.db"
if "%SECRET_KEY%"=="" set "SECRET_KEY=dev-only-change-me"
if "%FIELD_ENCRYPTION_KEY%"=="" set "FIELD_ENCRYPTION_KEY=dev-only-change-me-32bytes-key!!"
set "ENV=development"
alembic upgrade head
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

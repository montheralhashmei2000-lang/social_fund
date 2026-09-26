@echo off
REM Release APK build (Windows) - set the server URL first:
REM   set API_BASE_URL=https://your-domain
if "%API_BASE_URL%"=="" (
    echo Missing API_BASE_URL. Run:  set API_BASE_URL=https://your-domain  then retry.
    exit /b 1
)
chcp 65001 >nul
cd /d "%~dp0..\mobile_app"
flutter pub get
flutter build apk --release --dart-define=API_BASE_URL=%API_BASE_URL% --dart-define=APP_ENV=production
if not exist ..\dist mkdir ..\dist
copy /y build\app\outputs\flutter-apk\app-release.apk ..\dist\SocialFund.apk >nul
echo APK ready: dist\SocialFund.apk

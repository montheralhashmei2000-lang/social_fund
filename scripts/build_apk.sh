#!/usr/bin/env bash
# بناء APK نسخة إنتاج من التطبيق — مرّر عنوان الخادم:
#   API_BASE_URL=https://your-domain bash scripts/build_apk.sh
set -e
cd "$(dirname "$0")/../mobile_app"
flutter pub get
flutter build apk --release \
  --dart-define=API_BASE_URL="${API_BASE_URL:?مرر API_BASE_URL}" \
  --dart-define=APP_ENV=production
mkdir -p ../dist
cp build/app/outputs/flutter-apk/app-release.apk ../dist/SocialFund.apk
echo "APK جاهز: dist/SocialFund.apk"

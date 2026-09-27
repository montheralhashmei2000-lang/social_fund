#!/usr/bin/env bash
# توليد مفتاح توقيع خاص بك (استبدل المفتاح التجريبي) - احتفظ بالملف وكلمات المرور في مكان آمن
# الاستخدام: bash scripts/generate_keystore.sh
set -e
read -rp "اسم المنشأة (CN): " CN
read -rp "كلمة مرور المفتاح: " -s PASS; echo
KS="mobile_app/android/key.jks"
keytool -genkeypair -v -keystore "$KS" -storepass "$PASS" -keypass "$PASS" \
  -alias socialfund -keyalg RSA -keysize 2048 -validity 10000 \
  -dname "CN=${CN:-SocialFund}, O=SocialFund, C=YE"
printf 'storePassword=%s\nkeyPassword=%s\nkeyAlias=socialfund\nstoreFile=key.jks\n' "$PASS" "$PASS" > mobile_app/android/key.properties
echo "تم - الملف $KS وkey.properties ممنوع رفعهما للـgit (مستثناة في .gitignore)"

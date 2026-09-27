#!/usr/bin/env bash
# استعادة نسخة: bash scripts/restore.sh backups/socialfund-XXXX.sql.gz[.enc] [PASSPHRASE]
set -e
cd "$(dirname "$0")/.."
F="$1"; [ -f "$F" ] || { echo "الملف غير موجود: $F"; exit 1; }
case "$F" in
  *.enc)
    [ -n "$2" ] || { echo "مرر كلمة التشفير كبارامتر ثانٍ"; exit 1; }
    DEC=$(mktemp --suffix=.sql.gz); openssl enc -d -aes-256-cbc -pbkdf2 -in "$F" -out "$DEC" -pass pass:"$2"; F="$DEC";;
esac
gunzip -c "$F" | docker compose exec -T db psql -U socialfund -d socialfund
echo "تمت الاستعادة - اختبر التطبيق قبل المتابعة"

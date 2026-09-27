#!/usr/bin/env bash
# نسخة احتياطية مشفرة عند الطلب: bash scripts/backup.sh [BACKUP_PASSPHRASE]
set -e
cd "$(dirname "$0")/.."
mkdir -p backups
TS=$(date +%Y%m%d-%H%M%S)
docker compose exec -T db pg_dump -U socialfund socialfund | gzip > "backups/socialfund-$TS.sql.gz"
if [ -n "$1" ]; then
  openssl enc -aes-256-cbc -pbkdf2 -salt -in "backups/socialfund-$TS.sql.gz" -out "backups/socialfund-$TS.sql.gz.enc" -pass pass:"$1"
  rm "backups/socialfund-$TS.sql.gz"
  echo "النسخة المشفرة: backups/socialfund-$TS.sql.gz.enc"
fi
if [ -n "$BACKUP_REMOTE" ] && command -v rclone >/dev/null; then
  rclone copy backups/ "$BACKUP_REMOTE" && echo "رُفعت إلى $BACKUP_REMOTE"
fi
echo "تمت النسخة الاحتياطية: socialfund-$TS"

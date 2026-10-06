#!/usr/bin/env bash
# يُشغَّل على الخادم (Ubuntu/Debian) بواسطة deploy.ps1 — لا حاجة لتشغيله يدوياً.
# آمن للتكرار: إعادة التشغيل تحدّث الكود فقط وتُبقي .env (المفاتيح) والبيانات.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"   # مجلد الرفع المؤقت
APP=/opt/socialfund
CUSTOM_DOMAIN="${1:-}"
export DEBIAN_FRONTEND=noninteractive

if [ "$(id -u)" -ne 0 ]; then echo "يجب التشغيل كـ root (sudo)"; exit 1; fi

echo ">> تجهيز النظام"
# ذاكرة قليلة (مثل خوادم 1GB المجانية): نضيف swap حتى لا ينهار بناء الخادم
if [ "$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)" -lt 2000 ] && [ "$(swapon --show | wc -l)" -eq 0 ]; then
  fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile >/dev/null && swapon /swapfile
  grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

apt-get update -y >/dev/null
apt-get install -y --no-install-recommends curl ca-certificates openssl sqlite3 cron iptables iptables-persistent >/dev/null

if ! command -v docker >/dev/null 2>&1; then
  echo ">> تثبيت Docker"
  curl -fsSL https://get.docker.com | sh >/dev/null
fi
systemctl enable --now docker >/dev/null 2>&1 || true

echo ">> فتح المنافذ 80 و443 في جدار الخادم"
# صور Oracle تأتي بقاعدة REJECT تسبق أي سماح: نُدخل السماح في أول القائمة
for port in 80 443; do
  iptables -C INPUT -p tcp --dport "$port" -j ACCEPT 2>/dev/null || iptables -I INPUT 1 -p tcp --dport "$port" -j ACCEPT
done
netfilter-persistent save >/dev/null 2>&1 || true
if command -v ufw >/dev/null 2>&1 && ufw status | grep -q "Status: active"; then
  ufw allow 80/tcp >/dev/null; ufw allow 443/tcp >/dev/null
fi

echo ">> نشر الملفات"
mkdir -p "$APP" "$APP/data" "$APP/backups"
rm -rf "$APP/server"
cp -a "$SRC/server" "$APP/server"
cp -f "$SRC/deploy/docker-compose.yml" "$SRC/deploy/Caddyfile" "$APP/"

# .env: لا يُستبدل أبداً بعد إنشائه (تغيير ENCRYPTION_KEY يُتلف البيانات المشفّرة)
if [ ! -f "$APP/.env" ]; then
  if [ -n "$CUSTOM_DOMAIN" ]; then
    DOMAIN="$CUSTOM_DOMAIN"
  else
    IP="$(curl -fsS https://api.ipify.org || curl -fsS https://ifconfig.me)"
    DOMAIN="${IP//./-}.sslip.io"     # عنوان HTTPS مجاني بلا شراء نطاق
  fi
  {
    echo "DOMAIN=$DOMAIN"
    echo "JWT_SECRET=$(openssl rand -hex 32)"
    echo "ENCRYPTION_KEY=$(openssl rand -hex 32)"
    echo "ADMIN_PASSWORD=$(openssl rand -base64 24 | tr -dc 'A-Za-z0-9' | head -c 16)"
  } > "$APP/.env"
  chmod 600 "$APP/.env"
  echo "تم إنشاء مفاتيح جديدة."
else
  echo "تم الإبقاء على المفاتيح الحالية."
fi
if [ -n "$CUSTOM_DOMAIN" ] && ! grep -q "^DOMAIN=$CUSTOM_DOMAIN$" "$APP/.env"; then
  sed -i "s|^DOMAIN=.*|DOMAIN=$CUSTOM_DOMAIN|" "$APP/.env"
fi

echo ">> بناء الخادم وتشغيله (أول مرة قد يستغرق بضع دقائق)"
cd "$APP"
docker compose up -d --build

echo ">> نسخ احتياطي يومي (يُحتفظ بآخر 14 نسخة)"
cat > /etc/cron.d/socialfund-backup <<'CRON'
30 3 * * * root f=/opt/socialfund/backups/db-$(date +\%F).db; sqlite3 /opt/socialfund/data/social_fund.db ".backup '$f'" && find /opt/socialfund/backups -name 'db-*.db' -mtime +14 -delete
CRON
chmod 644 /etc/cron.d/socialfund-backup

set -a; . "$APP/.env"; set +a
echo ">> انتظار جاهزية https://$DOMAIN (إصدار الشهادة قد يأخذ حتى دقيقتين)"
OK=0
for i in $(seq 1 40); do
  if curl -fsS --max-time 5 "https://$DOMAIN/health" >/dev/null 2>&1; then OK=1; break; fi
  sleep 5
done

echo "===SOCIALFUND-INFO==="
echo "URL=https://$DOMAIN"
echo "ADMIN_USER=admin"
echo "ADMIN_PASSWORD=$ADMIN_PASSWORD"
echo "ENCRYPTION_KEY=$ENCRYPTION_KEY"
echo "JWT_SECRET=$JWT_SECRET"
echo "HEALTH=$([ "$OK" = 1 ] && echo ok || echo failed)"
echo "===END==="

if [ "$OK" != 1 ]; then
  echo
  echo "!! الخادم لم يستجب عبر HTTPS. الأسباب الشائعة:"
  echo "   1) لم تُفتح المنافذ 80 و443 في لوحة مزوّد السحابة (Oracle: VCN > Security List > Ingress Rules)."
  echo "   2) النطاق لا يشير إلى هذا الخادم بعد."
  echo "--- آخر سجلات Caddy:"
  docker compose logs --tail 20 caddy || true
  echo "--- آخر سجلات الخادم:"
  docker compose logs --tail 20 server || true
  exit 2
fi

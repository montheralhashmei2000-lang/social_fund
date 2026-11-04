# خادم الصندوق الاجتماعي (Dart) — صورة إنتاج محسنة لـ Oracle Cloud Free Tier (ARM Ampere / Ubuntu 22.04 LTS).
# البناء متعدد المراحل: يجمع التنفيذي المستقل (يعمل على x86 و ARM دون تعديل).
FROM dart:stable AS build
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN dart pub get
COPY . .
RUN dart pub get --offline \
 && dart compile exe bin/server.dart -o /app/server

# صورة التشغيل: Ubuntu 22.04 LTS (قاعدة ARM64 أصلية لـ Oracle Ampere).
FROM ubuntu:22.04
# تثبيت تبعيات وقت التشغيل: SQLite3، مكتبات PostgreSQL 14، شهادات، أدوات تشخيص.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      libsqlite3-0 \
      libpq5 \
      postgresql-client-14 \
      ca-certificates \
      curl \
      tzdata \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /app/server /app/server
COPY assets /app/assets
ENV APP_ENV=production \
    DATA_DIR=/data \
    ASSETS_DIR=/app/assets \
    PORT=8000
VOLUME ["/data"]
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD curl -fsS http://127.0.0.1:8000/health || exit 1
CMD ["/app/server"]

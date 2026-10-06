# خادم الصندوق الاجتماعي (Dart) — صورة إنتاج صغيرة: يُترجَم إلى ملف تنفيذي واحد.
# يُبنى على الجهاز الهدف نفسه فيعمل على x86 وعلى ARM (مثل Oracle Ampere) دون تعديل.
FROM dart:stable AS build
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN dart pub get
COPY . .
RUN dart pub get --offline \
 && dart compile exe bin/server.dart -o /app/server

FROM debian:bookworm-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends libsqlite3-0 ca-certificates curl \
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

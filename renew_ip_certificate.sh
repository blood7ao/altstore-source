#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="${ALTSTORE_PROJECT_DIR:-/root/altstore-source}"
CERTBOT_IMAGE="${CERTBOT_IMAGE:-certbot/certbot:latest}"

CERTIFICATE="${PROJECT_DIR}/letsencrypt/live/8.138.233.235/cert.pem"

if [[ -f "$CERTIFICATE" ]] && openssl x509 -checkend 172800 -noout -in "$CERTIFICATE" >/dev/null 2>&1; then
  exit 0
fi

restore_service() {
  docker start teslat-web-1 >/dev/null 2>&1 || true
  docker compose -f "${PROJECT_DIR}/docker-compose.yml" up -d --force-recreate
}

trap restore_service EXIT
docker compose -f "${PROJECT_DIR}/docker-compose.yml" stop altstore-source || true
docker stop teslat-web-1 >/dev/null 2>&1 || true

docker run --rm --network host \
  -v "${PROJECT_DIR}/letsencrypt:/etc/letsencrypt" \
  "${CERTBOT_IMAGE}" renew \
  --standalone \
  --preferred-challenges tls-alpn-01 \
  --preferred-profile shortlived \
  --non-interactive

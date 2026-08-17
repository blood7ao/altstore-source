#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="${ALTSTORE_PROJECT_DIR:-/root/altstore-source}"
CERTBOT_IMAGE="${CERTBOT_IMAGE:-certbot/certbot:v5.4.0}"

restore_service() {
  docker compose -f "${PROJECT_DIR}/docker-compose.yml" up -d --force-recreate
}

trap restore_service EXIT
docker compose -f "${PROJECT_DIR}/docker-compose.yml" stop altstore-source || true

docker run --rm --network host \
  -v "${PROJECT_DIR}/letsencrypt:/etc/letsencrypt" \
  "${CERTBOT_IMAGE}" renew \
  --standalone \
  --preferred-challenges tls-alpn-01 \
  --preferred-profile shortlived \
  --non-interactive

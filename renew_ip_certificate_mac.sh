#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="${ALTSTORE_PROJECT_DIR:-/Users/teddy/soft/altstore-source}"
CERTBOT_BIN="${PROJECT_DIR}/.certbot-venv/bin/certbot"
CERT_DIR="${PROJECT_DIR}/letsencrypt-local"
CERTIFICATE="${CERT_DIR}/live/8.138.233.235/cert.pem"
SERVER="root@8.138.233.235"
KEY="/Users/teddy/soft/mac.pem"
REMOTE_PROJECT_DIR="/root/altstore-source"

[[ -x "$CERTBOT_BIN" ]] || {
  echo "找不到 Certbot：$CERTBOT_BIN" >&2
  exit 1
}

if [[ -f "$CERTIFICATE" ]] && openssl x509 -checkend 172800 -noout -in "$CERTIFICATE" >/dev/null 2>&1; then
  exit 0
fi

restore_server_web() {
  ssh -i "$KEY" -o BatchMode=yes "$SERVER" \
    'if [ -f /tmp/altstore-acme-http.pid ]; then kill "$(cat /tmp/altstore-acme-http.pid)" 2>/dev/null || true; rm -f /tmp/altstore-acme-http.pid; fi; docker start teslat-web-1 >/dev/null 2>&1 || true'
}

trap restore_server_web EXIT
ssh -i "$KEY" -o BatchMode=yes "$SERVER" \
  'docker stop teslat-web-1 >/dev/null 2>&1 || true; mkdir -p /root/altstore-source/acme-webroot/.well-known/acme-challenge; cd /root/altstore-source/acme-webroot; nohup python3 -m http.server 80 >/tmp/altstore-acme-http.log 2>&1 & echo $! >/tmp/altstore-acme-http.pid; sleep 2'

"$CERTBOT_BIN" renew \
  --manual \
  --preferred-challenges http \
  --manual-auth-hook "${PROJECT_DIR}/acme-auth-hook.sh" \
  --manual-cleanup-hook "${PROJECT_DIR}/acme-cleanup-hook.sh" \
  --preferred-profile shortlived \
  --config-dir "$CERT_DIR" \
  --work-dir "${CERT_DIR}/work" \
  --logs-dir "${CERT_DIR}/logs" \
  --non-interactive

tar -C "$CERT_DIR" -czf - . | ssh -i "$KEY" -o BatchMode=yes "$SERVER" \
  "mkdir -p '${REMOTE_PROJECT_DIR}/letsencrypt' && tar -xzf - -C '${REMOTE_PROJECT_DIR}/letsencrypt'"
ssh -i "$KEY" -o BatchMode=yes "$SERVER" \
  "docker compose -f '${REMOTE_PROJECT_DIR}/docker-compose.yml' up -d --force-recreate"

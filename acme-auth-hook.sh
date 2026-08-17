#!/usr/bin/env bash

set -Eeuo pipefail

TOKEN="${CERTBOT_TOKEN:?CERTBOT_TOKEN is required}"
VALIDATION="${CERTBOT_VALIDATION:?CERTBOT_VALIDATION is required}"
[[ "$TOKEN" =~ ^[A-Za-z0-9_-]+$ ]] || { echo 'invalid Certbot token' >&2; exit 1; }

SERVER="root@8.138.233.235"
KEY="/Users/teddy/soft/mac.pem"
REMOTE_DIR="/root/altstore-source/acme-webroot/.well-known/acme-challenge"
TEMP_FILE="$(mktemp /tmp/chatapp-acme-auth.XXXXXX)"
trap 'rm -f "$TEMP_FILE"' EXIT

printf '%s\n' "$VALIDATION" > "$TEMP_FILE"
ssh -i "$KEY" -o BatchMode=yes "$SERVER" "mkdir -p '$REMOTE_DIR'"
scp -q -i "$KEY" -o BatchMode=yes "$TEMP_FILE" "$SERVER:$REMOTE_DIR/$TOKEN"

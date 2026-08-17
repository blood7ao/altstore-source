#!/usr/bin/env bash

set -Eeuo pipefail

TOKEN="${CERTBOT_TOKEN:?CERTBOT_TOKEN is required}"
[[ "$TOKEN" =~ ^[A-Za-z0-9_-]+$ ]] || exit 0

ssh -i /Users/teddy/soft/mac.pem -o BatchMode=yes root@8.138.233.235 \
  "rm -f '/root/altstore-source/acme-webroot/.well-known/acme-challenge/$TOKEN'"

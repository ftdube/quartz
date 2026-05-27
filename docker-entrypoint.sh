#!/bin/sh
set -e
envsubst '${QUARTZ_PAGE_TITLE} ${QUARTZ_BASE_URL}' \
  < /usr/src/app/quartz.config.default.yaml \
  > /tmp/quartz.config.patched.yaml
cp /tmp/quartz.config.patched.yaml /usr/src/app/quartz.config.default.yaml

envsubst '${QUARTZ_PAGE_TITLE} ${QUARTZ_SHORT_NAME}' \
  < /usr/src/app/quartz/static/manifest.json \
  > /tmp/manifest.patched.json
cp /tmp/manifest.patched.json /usr/src/app/quartz/static/manifest.json

exec "$@"

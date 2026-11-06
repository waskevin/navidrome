#!/bin/sh
# Build the TOS 7 submission package for Navidrome.
# Produces: navidrome.tar.gz and navidrome.tar.gz.sha256
set -e

APPID=navidrome
VERSION=1.0.0

LC_ALL=C tar --owner=0 --group=0 -czf "${APPID}.tar.gz" config.ini "${APPID}.lang" "${APPID}.svg" docker-compose.yml
sha256sum "${APPID}.tar.gz" > "${APPID}.tar.gz.sha256"

echo "built ${APPID}.tar.gz (version ${VERSION})"
cat "${APPID}.tar.gz.sha256"

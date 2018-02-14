#!/bin/bash
set -eo pipefail
shopt -s nullglob

if [ $1 = "webui" ]; then
  DIRPATH=/srv/aptly/public
  URL=https://github.com/sdumetz/aptly-web-ui/releases
  VERSION=LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' $URL/latest|sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
  if [ ! -d "$DIRPATH" ]; then
    echo "======= DEPLOY WEB INTERFACE ======="
    mkdir -p $DIRPATH
    curl -SL $URL/download/$VERSION/aptly-web-ui.tar.gz |tar xzv -C $DIRPATH
  fi
fi

exec "$@"

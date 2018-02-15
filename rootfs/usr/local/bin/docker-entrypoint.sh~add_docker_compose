#!/bin/bash
set -eo pipefail
shopt -s nullglob

DIRPATH=/srv/aptly/public

if [ ! -d "$DIRPATH" ]; then
  echo "====== CREATE PUBLIC DIR ======="
  mkdir -p $DIRPATH
fi

if [ $WEBUI = "yes" ]; then
  URL=https://github.com/sdumetz/aptly-web-ui/releases
  VERSION=$(curl -L -s -H 'Accept: application/json' $URL/latest|sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
  if [ ! -d "$DIRPATH/ui" ]; then
    echo "======= DEPLOY WEB INTERFACE ======="
    curl -SL $URL/download/$VERSION/aptly-web-ui.tar.gz |tar xzv -C $DIRPATH
    echo "=========== FINISH DEPLOY =========="
  else
    echo "========== !!CANCEL DEPLOY ============"
    echo "======= ALREADY DEPLOYED WEBUI ======="
  fi
fi

exec "$@"

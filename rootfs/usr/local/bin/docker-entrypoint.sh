#!/bin/bash
set -eo pipefail
shopt -s nullglob

if [ $WEBUI = "yes" ]; then
  DIRPATH=/srv/aptly/public
  URL=https://github.com/sdumetz/aptly-web-ui/releases
  VERSION=$(curl -L -s -H 'Accept: application/json' $URL/latest|sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
  if [ ! -d "$DIRPATH/ui" ]; then
    echo "======= DEPLOY WEB INTERFACE ======="
    mkdir -p $DIRPATH
    curl -SL $URL/download/$VERSION/aptly-web-ui.tar.gz |tar xzv -C $DIRPATH
    echo "=========== FINISH DEPLOY =========="
  else
    echo "========== !!CANCEL DEPLOY ============"
    echo "======= ALREADY DEPLOYED WEBUI ======="
  fi
fi

exec "$@"

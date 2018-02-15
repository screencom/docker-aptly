#!/bin/bash
SERVERKEY=subkeys.pgp.net

function importkey() {
  gpg --keyserver $SERVERKEY --recv-keys $1 \
  && gpg --export --armor $1 | apt-key add -
}

importkey CE49EC21

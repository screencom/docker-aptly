#!/bin/bash
set -eo pipefail
shopt -s nullglob

GPGPATH=~/.gnupg
KEYSERVER=pgp.mit.edu
APTLYPATH=/srv/aptly
PUBPATH=$APTLYPATH/public

function checkdir() {
  if [ ! -d "$GPGPATH" ]; then
    echo "====== CREATE GNUGPG DIR ======="
    mkdir -p $GPGPATH
    chmod -R 600 $GPGPATH
  fi
  if [ ! -d "$PUBPATH" ]; then
    echo "====== CREATE PUBLIC DIR ======="
    mkdir -p $PUBPATH
  fi
}

function checkgpg() {
  if [ ! -f "$GPGPATH/gpg.conf" ]; then
    echo "====== GENERATE GPG CONF FILE ======="
    tee $GPGPATH/gpg.conf << EOF
    personal-digest-preferences SHA256
    cert-digest-algo SHA256
    default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed
    personal-cipher-preferences TWOFISH CAMELLIA256 AES 3DES
EOF
  fi
  if [ ! -f "/etc/mkgpg.conf" ]; then
    echo "======= CREATE BASH CONF GPG ======"
    tee /etc/mkgpg.conf << EOF
    %echo >>>>> Generating a default key <<<<<<<
    Key-Type: default
    Key-Length: 2048
    Subkey-Type: default
    Subkey-Length: 2048
    Name-Real: Ernesto Perez
    Name-Comment: Key Repository Packages deb
    Name-Email: eperez@isotrol.com
    Expire-Date: 0
    #Passphrase: Xb(9DUfr6m/eZe?YVFe{
    %no-ask-passphrase
    %no-protection
    %commit
    %echo >>>>>> Done GPG key <<<<<<<<<
EOF
  fi
}

function importkey() {
  gpg --keyserver $SERVERGPG --recv-keys $1 \
  && gpg --export --armor $1 | apt-key add -
}

function gengpg() {
  if [ ! -f "$APTLYPATH/gpg.priv.key" ]; then
    echo "======= GENERATE GPG PRIVATE KEY ========"
    gpg --batch --gen-key /etc/mkgpg.conf
    echo "======= FINISH GENERATE PRIVATE KEY ======="
    gpg --list-secret-keys
  else
    echo "======= IMPORT PRIVATE KEY DETECTED ======="
    gpg --import $APTLYPATH/gpg.priv.key
    gpg --list-secret-keys
    echo "======= FINISH IMPORT PRIVATE KEY ========"
  fi
  if [ ! -f "$PUBPATH/gpg.pub.key" ]; then
    echo "======= EXPORT GPG PUB KEY ========"
    IDKEY=$(gpg --list-keys --with-colons | awk -F: '/^pub:/ { print $5 }')
    gpg --armor --output $PUBPATH/gpg.pub.key --export $IDKEY
    gpg --keyserver $KEYSERVER --send-keys $IDKEY
    echo "======== FINISH EXPORT KEY ========"
  else
    echo "======= IMPORT PUB KEY DETECTED ======="
    gpg --import $PUBPATH/gpg.pub.key
    gpg --list-secret-keys
    echo "======= FINISH IMPORT PUB KEY ========"
  fi
}

function checkweb() {
  if [ $WEBUI = "yes" ]; then
    URL=https://github.com/sdumetz/aptly-web-ui/releases
    VERSION=$(curl -L -s -H 'Accept: application/json' $URL/latest|sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
    if [ ! -d "$PUBPATH/ui" ]; then
      echo "======= DEPLOY WEB INTERFACE ======="
      curl -SL $URL/download/$VERSION/aptly-web-ui.tar.gz |tar xzv -C $PUBPATH
      echo "=========== FINISH DEPLOY =========="
    else
      echo "========== !!CANCEL DEPLOY ============"
      echo "======= ALREADY DEPLOYED WEBUI ======="
    fi
  fi
}

checkdir
checkgpg
gengpg
checkweb

. "/etc/importkeys.conf"

exec "$@"

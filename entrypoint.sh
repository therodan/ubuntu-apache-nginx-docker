#!/bin/bash

if [ -z ${DH_SIZE+x} ]
then
  >&2 echo ">> no \$DH_SIZE specified using default" 
  DH_SIZE="2048"
fi


DH="/etc/nginx/ssl/dh.pem"

if [ ! -e "$DH" ]
then
  echo ">> seems like the first start of nginx"
  echo ">> doing some preparations..."
  echo ""

  echo ">> generating $DH with size: $DH_SIZE"
  openssl dhparam -out "$DH" $DH_SIZE
fi

if [ ! -e "/etc/nginx/ssl/cert.pem" ] || [ ! -e "/etc/nginx/ssl/key.pem" ]
then
  echo ">> generating self signed cert"
  openssl req -x509 -newkey rsa:4086 \
  -subj "/C=XX/ST=XXXX/L=XXXX/O=XXXX/CN=localhost" \
  -keyout "/etc/nginx/ssl/key.pem" \
  -out "/etc/nginx/ssl/cert.pem" \
  -days 3650 -nodes -sha256
fi

# exec CMD
echo ">> exec docker CMD"
echo "$@"
exec "$@"
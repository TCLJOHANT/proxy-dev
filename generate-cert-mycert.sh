#!/bin/bash

CERT_DIR="./certs"

if ! command -v mkcert &> /dev/null
then
    echo "Por favor instala mkcert: https://github.com/FiloSottile/mkcert"
    exit 1
fi

if [ $# -eq 0 ]; then
  echo "Uso: $0 dominio1 [dominio2 ...]"
  exit 1
fi

mkdir -p "$CERT_DIR"

for DOMAIN in "$@"; do
  echo "Generando certificado para $DOMAIN..."
  mkcert -cert-file "$CERT_DIR/$DOMAIN.crt" -key-file "$CERT_DIR/$DOMAIN.key" "$DOMAIN"
  if [ $? -eq 0 ]; then
    echo "✅ Certificado generado para $DOMAIN"
  else
    echo "❌ Error generando certificado para $DOMAIN"
  fi
done

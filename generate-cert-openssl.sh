#!/bin/bash

DOMAIN=$1
CERT_DIR="./certs"

if [ -z "$DOMAIN" ]; then
  echo "Uso: ./generate-cert.sh dominio.local"
  exit 1
fi

mkdir -p "$CERT_DIR"

# Ruta temporal para archivo de configuración OpenSSL
OPENSSL_CONF_TMP=$(mktemp)

cat > "$OPENSSL_CONF_TMP" <<EOF
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = dn
req_extensions     = req_ext

[ dn ]
CN = $DOMAIN

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $DOMAIN
EOF

# Generar clave y certificado con SAN
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$CERT_DIR/$DOMAIN.key" \
  -out "$CERT_DIR/$DOMAIN.crt" \
  -config "$OPENSSL_CONF_TMP"

# Eliminar config temporal
rm "$OPENSSL_CONF_TMP"

echo "✅ Certificado creado para $DOMAIN en $CERT_DIR/"
echo "🔒 Archivos: $DOMAIN.crt y $DOMAIN.key"

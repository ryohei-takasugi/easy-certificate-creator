#!/bin/bash

cd /opt/easyrsa
rm -rf ./*
cp -r /usr/share/easy-rsa/* .
# export PATH="/opt/easyrsa:$PATH"

cp /vars ./vars

easyrsa init-pki
echo "*.${SERVER_HOST}" | easyrsa build-ca nopass
easyrsa gen-dh nopass
easyrsa build-server-full server nopass
easyrsa gen-crl

easyrsa build-client-full client01 nopass




# 環境変数の設定
export CERT_DIR="/opt/openssl" # 証明書を保存するディレクトリ
export DOMAIN="my.domain.com" # 実際のドメイン名に置き換えてください
export DAYS=365 # 証明書の有効期限（日数）

# ディレクトリの作成
rm -rf "$CERT_DIR"/*
mkdir -p "$CERT_DIR"
cd "$CERT_DIR"

# 設定ファイルの生成
cat > server.csr.cnf <<EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C=US
ST=YourState
L=YourCity
O=YourOrganization
CN=$DOMAIN

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = localhost.$DOMAIN
DNS.2 = $DOMAIN
DNS.3 = www.$DOMAIN
EOF

# ルートCAの秘密鍵生成
openssl genrsa -out rootCA.key 2048

# ルートCAの証明書（自己署名）生成
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.pem -config server.csr.cnf

# サーバーの秘密鍵生成
openssl genrsa -out server.key 2048

# サーバーのCSR（証明書署名要求）生成
openssl req -new -key server.key -out server.csr -config server.csr.cnf

# 証明書を生成する際に、SANを含めるための設定ファイルを作成
cat > v3.ext <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = localhost.$DOMAIN
DNS.2 = $DOMAIN
DNS.3 = www.$DOMAIN
EOF

# サーバー証明書の生成（ルートCAによる署名）、SANを含む
openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days "$DAYS" -sha256 -extfile v3.ext

# 証明書と鍵の場所の出力
echo "ルートCA証明書: $CERT_DIR/rootCA.pem"
echo "サーバー証明書: $CERT_DIR/server.crt"
echo "サーバー秘密鍵: $CERT_DIR/server.key"

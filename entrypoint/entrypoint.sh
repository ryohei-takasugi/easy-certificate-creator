#!/bin/bash

# 環境変数の設定
export CERT_DIR="/opt/openssl" # 証明書を保存するディレクトリ
export SERVER_SUBJECT_ALT_NAME="localhost.my.domain.com my.domain.com www.my.domain.com" # 実際のドメイン名に置き換えてください
export CLIENT_SUBJECT_ALT_NAME="localhost.my.domain.com my.domain.com www.my.domain.com" # 実際のドメイン名に置き換えてください
export CLIENT_USERS="client1 client2 client3" # ユーザーのアカウント名
export SERVER_CERTIFICATE_VALIDITY_PERIOD=365 # 証明書の有効期限（日数）
export CLIENT_CERTIFICATE_VALIDITY_PERIOD=365 # 証明書の有効期限（日数）
export PASSWORD="yourpassword"
export DN_COUNTRY_NAME="JP"
export DN_STATE_OR_PROVINCE_NAME="Tokyo"
export DN_CITY="Shibuyaku"
export DN_COMPANY="company"
export DEBUG="true"


# ディレクトリの作成
rm -rf "$CERT_DIR"/*
mkdir -p "$CERT_DIR"
cd "$CERT_DIR"

/bin/bash /opt/entrypoint/server.sh
/bin/bash /opt/entrypoint/client.sh

# DOMAIN_ARRAY=($DOMAIN_LIST)

# # SANの設定を動的に生成
# ALT_NAMES=""
# for DOMAIN in "${DOMAIN_ARRAY[@]}"; do
#   ALT_NAMES="${ALT_NAMES}DNS:${DOMAIN}, "
# done
# ALT_NAMES="${ALT_NAMES%, }"
# echo $ALT_NAMES

# # 設定ファイルの生成
# cat > server.csr.cnf <<EOF
# [ req ]
# default_bits = 2048
# prompt = no
# default_md = sha256
# req_extensions = req_ext
# distinguished_name = dn

# [ dn ]
# C=$DN_COUNTRY_NAME
# ST=$DN_STATE_OR_PROVINCE_NAME
# L=$DN_CITY
# O=$DN_COMPANY
# CN=${DOMAIN_ARRAY[0]}

# [ req_ext ]
# subjectAltName = ${ALT_NAMES}
# EOF

# # ルートCAの秘密鍵生成
# openssl genrsa -out rootCA.key 2048

# # ルートCAの証明書（自己署名）生成
# openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.pem -config server.csr.cnf

# # サーバーの秘密鍵生成
# openssl genrsa -out server.key 2048

# # サーバーのCSR（証明書署名要求）生成
# openssl req -new -key server.key -out server.csr -config server.csr.cnf

# # 証明書を生成する際に、SANを含めるための設定ファイルを作成
# cat > v3.ext <<EOF
# authorityKeyIdentifier=keyid,issuer
# basicConstraints=CA:FALSE
# keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
# subjectAltName = ${ALT_NAMES}
# EOF

# # サーバー証明書の生成（ルートCAによる署名）、SANを含む
# openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days "$DAYS" -sha256 -extfile v3.ext

# # .p12ファイルの生成
# openssl pkcs12 -export -out server.p12 -inkey server.key -in server.crt -certfile rootCA.pem -passout pass:$PASSWORD

# # 証明書と鍵の場所の出力
# echo "-----------------------------"
# echo "file path"
# echo "  ルートCA証明書: $CERT_DIR/rootCA.pem"
# echo "  サーバー証明書: $CERT_DIR/server.crt"
# echo "  サーバー秘密鍵: $CERT_DIR/server.key"
# echo "  .p12ファイル: $CERT_DIR/server.p12"

# if [ "$DEBUG" = "true" ]
# then
#     echo "-----------------------------"
#     openssl x509 -text -noout -in "$CERT_DIR/server.crt"
# fi

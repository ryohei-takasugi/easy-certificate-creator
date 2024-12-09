#!/bin/bash

cd "$CERT_DIR"

DOMAIN_ARRAY=($SERVER_SUBJECT_ALT_NAME)

# SANの設定を動的に生成
ALT_NAMES=""
for DOMAIN in "${DOMAIN_ARRAY[@]}"; do
  ALT_NAMES="${ALT_NAMES}DNS:${DOMAIN}, "
done
ALT_NAMES="${ALT_NAMES%, }"
echo $ALT_NAMES


# サーバーのCSR（証明書署名要求）設定ファイルの生成
cat > server.csr.cnf <<EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C=$DN_COUNTRY_NAME
ST=$DN_STATE_OR_PROVINCE_NAME
L=$DN_CITY
O=$DN_COMPANY
CN=${DOMAIN_ARRAY[0]}

[ req_ext ]
subjectAltName = ${ALT_NAMES}
EOF

# 証明書を生成する際に、SANを含めるための設定ファイルを作成
cat > server.v3.ext <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = ${ALT_NAMES}
EOF

# ルートCAの秘密鍵生成
openssl genrsa -out rootCA.key 2048

# ルートCAの証明書（自己署名）生成
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days $SERVER_CERTIFICATE_VALIDITY_PERIOD -out rootCA.pem -config server.csr.cnf

# サーバーの秘密鍵生成
openssl genrsa -out server.key 2048

# サーバーのCSR（証明書署名要求）生成
openssl req -new -key server.key -out server.csr -config server.csr.cnf

# サーバー証明書の生成（ルートCAによる署名）、SANを含む
openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days "$SERVER_CERTIFICATE_VALIDITY_PERIOD" -sha256 -extfile server.v3.ext

# サーバーp12ファイルの生成
openssl pkcs12 -export -out server.p12 -inkey server.key -in server.crt -certfile rootCA.pem -passout pass:$PASSWORD

# Windows用ルート証明書生成
cp $CERT_DIR/rootCA.pem $CERT_DIR/rootCA.cer

# 証明書と鍵の場所の出力
echo
echo
echo '-------------------------------------------------'
echo
echo '生成内容の確認'
echo
echo '-------------------------------------------------'
echo
echo "ルートCA証明書(Mac用): $CERT_DIR/rootCA.pem"
echo "ルートCA証明書(Windows用): $CERT_DIR/rootCA.cer"
openssl x509 -text -fingerprint -noout -in $CERT_DIR/rootCA.pem
echo
echo
echo
echo "サーバー証明書: $CERT_DIR/server.crt"
openssl x509 -text -noout -in $CERT_DIR/server.crt
echo
echo
echo
echo "サーバー秘密鍵: $CERT_DIR/server.key"
openssl rsa -text -noout -in $CERT_DIR/server.key
echo
echo
echo
echo '-------------------------------------------------'
echo
echo '生成ファイルリスト'
echo
echo '-------------------------------------------------'
echo "ルートCA証明書(Mac用): $CERT_DIR/rootCA.pem"
echo "ルートCA証明書(Windows用): $CERT_DIR/rootCA.cer"
echo "サーバー証明書: $CERT_DIR/server.crt"
echo "サーバー秘密鍵: $CERT_DIR/server.key"
echo "サーバーp12ファイル: $CERT_DIR/server.p12"
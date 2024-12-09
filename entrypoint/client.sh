#!/bin/bash

cd "$CERT_DIR"

if [ ! -e /opt/openssl/rootCA.pem ]; then
  echo "Faild because rootCA.pem is missing"
  exit 1;
fi

DOMAIN_ARRAY=($CLIENT_SUBJECT_ALT_NAME)

# SANの設定を動的に生成
ALT_NAMES=""
for DOMAIN in "${DOMAIN_ARRAY[@]}"; do
  ALT_NAMES="${ALT_NAMES}DNS:${DOMAIN}, "
done
ALT_NAMES="${ALT_NAMES%, }"
echo $ALT_NAMES


USERS_ARRAY=($CLIENT_USERS)
for USER in "${USERS_ARRAY[@]}"; do

    mkdir -p $USER

    # クライアントのCSR（証明書署名要求）設定ファイルの生成
    cat > $USER/$USER.csr.cnf <<EOF
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
CN=${USER}-${DOMAIN_ARRAY[0]}

[ req_ext ]
basicConstraints = CA:FALSE
keyUsage = digitalSignature
extendedKeyUsage = clientAuth
EOF

    # 証明書を生成する際に、SANを含めるための設定ファイルを作成
    cat > $USER/$USER.v3.ext <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = ${ALT_NAMES}
EOF

    # クライアント証明書
    openssl genrsa -out $USER/$USER.key 2048

    # クライアントのCSR（証明書署名要求）生成
    openssl req -new -key $USER/$USER.key -out $USER/$USER.csr -config $USER/$USER.csr.cnf

    # クライアント証明書の生成（ルートCAによる署名）、SANを含む
    openssl x509 -req -in $USER/$USER.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out $USER/$USER.crt -days "$CLIENT_CERTIFICATE_VALIDITY_PERIOD" -sha256 -extfile $USER/$USER.v3.ext

    # クライアントp12ファイルの生成
    openssl pkcs12 -export -out $USER/$USER.p12 -inkey $USER/$USER.key -in $USER/$USER.crt -certfile rootCA.pem -passout pass:$PASSWORD

    # 証明書と鍵の場所の出力
    echo
    echo
    echo '-------------------------------------------------'
    echo
    echo '生成内容の確認'
    echo
    echo '-------------------------------------------------'
    echo "クライアント証明書: $CERT_DIR/client.crt"
    echo "クライアント秘密鍵: $CERT_DIR/client.key"
    echo "クライアントp12ファイル: $CERT_DIR/client.p12"
done


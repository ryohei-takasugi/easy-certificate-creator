# 証明書の生成方法

## ./conf/vars の編集
``` init
# Easy-RSA 3 parameter settings

if [ -z "$EASYRSA_CALLER" ]; then
        echo "You appear to be sourcing an Easy-RSA 'vars' file." >&2
        echo "This is no longer necessary and is disallowed. See the section called" >&2
        echo "'How to use this file' near the top comments for more details." >&2
        return 1
fi

# Organizational fields
set_var EASYRSA_REQ_COUNTRY    "US"
set_var EASYRSA_REQ_PROVINCE   "California"
set_var EASYRSA_REQ_CITY       "San Francisco"
set_var EASYRSA_REQ_ORG        "Copyleft Certificate Co"
set_var EASYRSA_REQ_EMAIL      "me@example.net"
set_var EASYRSA_REQ_OU         "My Organizational Unit"

# Default CN
set_var EASYRSA_REQ_CN         "MyServer"

# Choose a size in bits for your keypairs.
set_var EASYRSA_KEY_SIZE       2048

# crypto mode. rsa, ec, ed.
set_var EASYRSA_ALGO           rsa

# Cryptographic digest to use. include: md5, sha1, sha256, sha224, sha384, sha512
set_var EASYRSA_DIGEST         "sha256"

# In how many days should the root CA key expire?
set_var EASYRSA_CA_EXPIRE      3650

# In how many days should certificates expire?
set_var EASYRSA_CERT_EXPIRE    825

# How many days until the next CRL publish date?
set_var EASYRSA_CRL_DAYS       1800

# How many days before its expiration date a certificate is allowed to be renewed?
set_var EASYRSA_CERT_RENEW     30
```

## 生成（コンテナの実行）
```
$ docker compose up -d                                    
[+] Building 0.7s (12/12) FINISHED                                                                                                                     docker:desktop-linux
 => [easy-certificate-creator internal] load .dockerignore                                                                                                             0.0s
 => => transferring context: 2B                                                                                                                                        0.0s
 => [easy-certificate-creator internal] load build definition from Dockerfile                                                                                          0.0s
 => => transferring dockerfile: 668B                                                                                                                                   0.0s
 => [easy-certificate-creator internal] load metadata for docker.io/library/debian:bullseye-slim                                                                       0.6s
 => [easy-certificate-creator 1/7] FROM docker.io/library/debian:bullseye-slim@sha256:41c3fecb70015fd9c72d6df95573de3f92d5f4f46fdabe8dbd8d2bfb1531594d                 0.0s
 => [easy-certificate-creator internal] load build context                                                                                                             0.0s
 => => transferring context: 88B                                                                                                                                       0.0s
 => CACHED [easy-certificate-creator 2/7] RUN apt update && apt install -y openssl easy-rsa && apt clean                                                               0.0s
 => CACHED [easy-certificate-creator 3/7] RUN mkdir -p /opt/easyrsa                                                                                                    0.0s
 => CACHED [easy-certificate-creator 4/7] WORKDIR /opt/easyrsa                                                                                                         0.0s
 => CACHED [easy-certificate-creator 5/7] COPY ./conf/vars /vars                                                                                                       0.0s
 => CACHED [easy-certificate-creator 6/7] COPY ./entrypoint.sh /entrypoint.sh                                                                                          0.0s
 => CACHED [easy-certificate-creator 7/7] RUN chmod 755 /entrypoint.sh                                                                                                 0.0s
 => [easy-certificate-creator] exporting to image                                                                                                                      0.0s
 => => exporting layers                                                                                                                                                0.0s
 => => writing image sha256:65ab9680dbab5ec93fd5d1d7fc8f7377ac260b90111c1014713b9d04d0ad62b3                                                                           0.0s
 => => naming to docker.io/library/easy-certificate-creator-easy-certificate-creator                                                                                   0.0s
[+] Running 2/2
 ✔ Network easy-certificate-creator_default  Created                                                                                                                   0.0s 
 ✔ Container easy-certificate-creator        Started 
```

## 生成結果
``` bash
$ tree easyrsa/pki 
easyrsa/pki
├── ca.crt
├── certs_by_serial
│   ├── 0F378FEAF5B147F274BABA0A22806DFF.pem
│   └── E4A30B0968A9F13A91FAB5ED310486A0.pem
├── crl.pem
├── dh.pem
├── index.txt
├── index.txt.attr
├── index.txt.attr.old
├── index.txt.old
├── issued
│   ├── client01.crt
│   └── server.crt
├── openssl-easyrsa.cnf
├── private
│   ├── ca.key
│   ├── client01.key
│   └── server.key
├── renewed
│   ├── certs_by_serial
│   ├── private_by_serial
│   └── reqs_by_serial
├── reqs
│   ├── client01.req
│   └── server.req
├── revoked
│   ├── certs_by_serial
│   ├── private_by_serial
│   └── reqs_by_serial
├── safessl-easyrsa.cnf
├── serial
└── serial.old

13 directories, 20 files
```

# nginx cretificate file copy
``` bash
cp easyrsa/pki/private/server.key /etc/nginx/ssl/server.key
cp easyrsa/pki/issued/server.crt /etc/nginx/ssl/server.crt
```

# nginx.conf の編集
```
server {
  listen 80;
  server_name example.co.jp;
  return 301 https://$host$request_uri;
}

server {
  listen 443;
  server_name example.co.jp;

  ssl                  on;
  ssl_certificate      /etc/nginx/ssl/server.crt;
  ssl_certificate_key  /etc/nginx/ssl/server.key;

  location / {
    proxy_pass http://localhost:3000;
  }
}
```
# 証明書の生成方法

## easyrsa (未完成)

### ./conf/vars の編集
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

### 生成（コンテナの実行）
```
$ docker compose run --rm easy-certificate-creator                                 
Note: using Easy-RSA configuration from: /opt/easyrsa/vars

init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /opt/easyrsa/pki



Note: using Easy-RSA configuration from: /opt/easyrsa/vars
Using SSL: openssl OpenSSL 1.1.1w  11 Sep 2023
Generating RSA private key, 2048 bit long modulus (2 primes)
..................................+++++
.................................+++++
e is 65537 (0x010001)
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:
CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/opt/easyrsa/pki/ca.crt



Note: using Easy-RSA configuration from: /opt/easyrsa/vars
Using SSL: openssl OpenSSL 1.1.1w  11 Sep 2023
Generating DH parameters, 2048 bit long safe prime, generator 2
This is going to take a long time
................+.....................................................................................................................................................................................................................................................................................................................................+.........................+......................................................................................................................................................+..............................+...................+...........................................................................................................................+............................+..............................................................................................................+......................................................................................................................................................................................................................................................+.................................+...........................................................................................................................+...................................................................................................................................................................................................+.............................................................+........................................................................................................................................................................................................................................................................................................................................................+...........................................................................................................................................................................................+....................................................+.................................................................................+............................+........+....................................+...................................................................................................................................................+............................................................................................................................................................................................................................................................................................................................................................................................................+.....................................................+...................................................+...................................................................................................................................................................................................................................................................................................+................................+..............+.....................................................................................................+..+....................................+....................+....................+............................................................................................................................................................+........................................................................................................................................................................................................................................+............................................................................................................................................+...............................................................................................................................................................................+....................................................................................................................................................................................................................................................................................................................................................................+..................................................................................................................................................................................................................................................................................................................................................................................................................................................+..............+......................................................................+...................................+.................................................................................................................................++*++*++*++*

DH parameters of size 2048 created at /opt/easyrsa/pki/dh.pem



Note: using Easy-RSA configuration from: /opt/easyrsa/vars
Using SSL: openssl OpenSSL 1.1.1w  11 Sep 2023
Generating a RSA private key
......................+++++
.......................................+++++
writing new private key to '/opt/easyrsa/pki/easy-rsa-72.JmnnvA/tmp.u6OuKP'
-----
Using configuration from /opt/easyrsa/pki/easy-rsa-72.JmnnvA/tmp.SMgQIM
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'server'
Certificate is to be certified until May  4 13:31:51 2026 GMT (825 days)

Write out database with 1 new entries
Data Base Updated


Note: using Easy-RSA configuration from: /opt/easyrsa/vars
Using SSL: openssl OpenSSL 1.1.1w  11 Sep 2023
Using configuration from /opt/easyrsa/pki/easy-rsa-148.P3GucM/tmp.oWgpLz

An updated CRL has been created.
CRL file: /opt/easyrsa/pki/crl.pem



Note: using Easy-RSA configuration from: /opt/easyrsa/vars
Using SSL: openssl OpenSSL 1.1.1w  11 Sep 2023
Generating a RSA private key
...........................+++++
..+++++
writing new private key to '/opt/easyrsa/pki/easy-rsa-167.TRzlhT/tmp.b1aG09'
-----
Using configuration from /opt/easyrsa/pki/easy-rsa-167.TRzlhT/tmp.RcPPjP
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'client01'
Certificate is to be certified until May  4 13:31:52 2026 GMT (825 days)

Write out database with 1 new entries
Data Base Updated
```

### 生成結果
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

### nginx cretificate file copy
``` bash
cp easyrsa/pki/private/server.key /etc/nginx/ssl/server.key
cp easyrsa/pki/issued/server.crt /etc/nginx/ssl/server.crt
```

### nginx.conf の編集
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


## Openssl（動作確認済み）

### 生成（コンテナの実行）
`openssl`フォルダに証明書を生成する
```
$ docker compose run --rm easy-certificate-creator  
（省略）
```

### nginx cretificate file copy
`nginx`配下に証明書を移動
``` bash
cp openssl/server.key /etc/nginx/ssl/server.key
cp openssl/server.crt /etc/nginx/ssl/server.crt
```

### nginx.conf の編集
`nginx`に証明書を設定
```
server {
  listen 80;
  server_name localhost.my.domain.com;
  return 301 https://$host$request_uri;
}

server {
  listen 443;
  server_name localhost.my.domain.com;

  ssl                  on;
  ssl_certificate      /etc/nginx/ssl/server.crt;
  ssl_certificate_key  /etc/nginx/ssl/server.key;

  location / {
    proxy_pass http://localhost:3000;
  }
}
```

### edit hosts
add `localhost.my.domain.com`
```
$ vi /etc/hosts                           
##
# Host Database
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
127.0.0.1       localhost
255.255.255.255 broadcasthost
::1             localhost
# Added by Docker Desktop
# To allow the same kube context to work on the host and the container:
127.0.0.1 kubernetes.docker.internal

127.0.0.1 localhost.my.domain.com

# End of section
```

### ルート証明書の登録
OSによるので各自調べてください
また必要に応じて「常に信頼」にしてください。


### Webブラウザの再起動
完全にすべてのタブを閉じてWebブラウザを停止してください。
そのうえで立ち上げ直して、「https://localhost.my.domain.com」にアクセスします。

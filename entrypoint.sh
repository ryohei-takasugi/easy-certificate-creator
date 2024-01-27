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
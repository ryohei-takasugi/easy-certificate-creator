FROM debian:bullseye-slim

RUN apt update && apt install -y openssl easy-rsa && apt clean

RUN mkdir -p /opt/easyrsa
WORKDIR /opt/easyrsa
ENV PATH /opt/easyrsa:$PATH

# WORKDIR /usr/share/easy-rsa

# ENV PATH /usr/share/easy-rsa:$PATH

# COPY ./conf/vars ./vars

# RUN easyrsa init-pki
# RUN echo ${SERVER_HOST} | easyrsa build-ca nopass
# RUN easyrsa gen-dh nopass
# RUN easyrsa build-server-full server nopass
# RUN easyrsa gen-crl
# RUN openssl x509 -in pki/ca.crt -noout -subject -issuer -dates

COPY ./conf/vars /vars

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
CMD [ "/entrypoint.sh" ]
# CMD [ "bash"]
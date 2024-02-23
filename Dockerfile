FROM debian:bullseye-slim

RUN apt update && apt install -y openssl easy-rsa && apt clean

RUN mkdir -p /opt/easyrsa
WORKDIR /opt/easyrsa
ENV PATH /opt/easyrsa:$PATH

COPY ./conf/vars /vars

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
CMD [ "/entrypoint.sh" ]
# CMD [ "bash"]
FROM debian:bullseye-slim

RUN apt update && apt install -y openssl && apt clean

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
CMD [ "/entrypoint.sh" ]
# CMD [ "bash"]
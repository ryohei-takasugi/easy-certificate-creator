FROM debian:bullseye-slim

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
CMD [ "/entrypoint.sh" ]
# CMD [ "bash"]
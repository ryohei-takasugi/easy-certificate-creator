FROM debian:bullseye-slim

RUN apt update && apt install -y openssl && apt clean

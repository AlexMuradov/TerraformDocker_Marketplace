FROM webdevops/php-nginx

USER root
WORKDIR /bla
COPY . .

ENV CONTAINERROOT=/app
ENV DB_HOST=ubuntu_db_1
ENV DB_NAME=xx
ENV DB_USER=root
ENV DB_PASS=fscaz1

RUN ["apt-get", "update"]
RUN ["apt-get", "install", "-y", "nano"]

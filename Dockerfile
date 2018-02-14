FROM debian:9-slim

LABEL Maintainer="Ernesto Pérez <eperez@isotrol.com>" \
      Name="Forticlient_cli" \
      Description="Imágen con el servicio aptly api" \
      Version="0.2.0"

RUN set -x \
    && sed -i -- 's/main/main contrib non-free/g' /etc/apt/sources.list \
    && apt-get update && apt-get install -y \
    gnupg \
    ca-certificates \
    graphviz \
    && echo "deb http://repo.aptly.info/ squeeze main" \
     > /etc/apt/sources.list.d/aptly.list \
    && apt-key adv --keyserver keys.gnupg.net --recv-keys 9C7DE460 \
    && apt-get update && apt-get install -y \
    aptly

COPY rootfs/etc/aptly.conf /etc/

COPY rootfs/docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /

EXPOSE 8080
VOLUME ["/srv/aptly"]

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["aptly","api","serve","-no-lock"]

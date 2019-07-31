FROM debian:9-slim

LABEL Maintainer="Ernesto Pérez <eperez@isotrol.com>" \
      Name="Docker Aptly" \
      Description="Imágen con el servicio aptly api" \
      Version="0.2.0"

RUN set -x \
    && sed -i -- 's/main/main contrib non-free/g' /etc/apt/sources.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    gnupg \
    ca-certificates \
    graphviz \
    curl \
    dirmngr

RUN set -x \
    && echo "deb http://repo.aptly.info/ squeeze main" \
     > /etc/apt/sources.list.d/aptly.list \
    && apt-key adv --recv-keys ED75B5A4483DA07C \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    aptly \
    && rm -rf /var/lib/apt/lists/*

COPY rootfs/ /

RUN ln -s usr/local/bin/docker-entrypoint.sh /

EXPOSE 8080
VOLUME ["/srv/aptly"]

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["aptly","api","serve","-no-lock"]

FROM debian:bullseye-slim as build

ENV PACKAGES='build-essential make libevent-dev libssl-dev gcc curl ca-certificates openssl file pkg-config'

ARG PGBOUNCER_VERSION=1.16.1

RUN \
    apt update -y && \
    apt install -y --no-install-recommends ${PACKAGES} && \
    curl -LsSko  "/tmp/pgbouncer.tar.gz" "https://pgbouncer.github.io/downloads/files/${PGBOUNCER_VERSION}/pgbouncer-${PGBOUNCER_VERSION}.tar.gz" && \
        file "/tmp/pgbouncer.tar.gz" && \
        cd /tmp && \
        mkdir -p /tmp/pgbouncer && \
        tar -zxvf pgbouncer.tar.gz -C /tmp/pgbouncer --strip-components 1 && \
        cd /tmp/pgbouncer && \
        ./configure --prefix=/usr --without-cares --disable-evdns && \
        make

FROM debian:bullseye-slim

ENV USER=pgbouncer \
    INSTALL_PACKAGES='curl gnupg2' \
    PACKAGES="ca-certificates gettext openssl dnsutils postgresql-client libevent-2.1-7"

RUN \
    apt update -y && \
    apt install -y --no-install-recommends ${INSTALL_PACKAGES} && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    curl -LsSk https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg && \
    apt update -y && \
    apt install -y --no-install-recommends ${PACKAGES} && \
    apt purge -y ${INSTALL_PACKAGES} && \
    apt autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    useradd --no-create-home pgbouncer && \
    mkdir -p /etc/pgbouncer /var/log/pgbouncer /var/run/pgbouncer

ADD entrypoint.sh /
ADD auth_file.txt.tmpl pgbouncer.ini.tmpl /etc/pgbouncer/
COPY --from=build --chown=postgres ["/tmp/pgbouncer/pgbouncer", "/bin/pgbouncer"]

RUN chown -R ${USER}:${USER} /var/log/pgbouncer /var/run/pgbouncer /etc/pgbouncer /etc/ssl/certs

WORKDIR /

USER ${USER}:${USER}

ENTRYPOINT ["/entrypoint.sh"]
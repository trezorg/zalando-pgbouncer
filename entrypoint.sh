#!/bin/sh

set -ex

if [ "$PGUSER" = "postgres" ]; then
    echo "WARNING: pgbouncer will connect with a superuser privileges!"
    echo "You need to fix this as soon as possible."
fi

openssl req -nodes -new -x509 -subj /CN=spilo.dummy.org \
    -keyout /etc/ssl/certs/pgbouncer.key \
    -out /etc/ssl/certs/pgbouncer.crt

envsubst < /etc/pgbouncer/pgbouncer.ini.tmpl > /etc/pgbouncer/pgbouncer.ini
envsubst < /etc/pgbouncer/auth_file.txt.tmpl > /etc/pgbouncer/auth_file.txt

exec /bin/pgbouncer /etc/pgbouncer/pgbouncer.ini

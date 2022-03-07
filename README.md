# Information

Zalando debian 11 pgbouncer 1.16.1 docker image with libc-based resolver.

## Build docker

    docker build -t polymetr/zalando-pgbouncer:0.0.4 .

## Start with docker

    docker run --rm -it --env-file=env_example.env polymetr/zalando-pgbouncer:0.0.4

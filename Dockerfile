FROM python:2-alpine

ENV PGADMIN_VERSION=1.5 \
    PYTHONDONTWRITEBYTECODE=1

RUN set -ex \
 && apk update \
 && apk add --no-cache alpine-sdk postgresql-dev \
 && echo "https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v${PGADMIN_VERSION}/pip/pgadmin4-${PGADMIN_VERSION}-py2.py3-none-any.whl" > requirements.txt \
 && pip install --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt \
 && apk del alpine-sdk \
 && mkdir /tmp/postgres-apk \
 && cd /tmp/postgres-apk \
 && apk fetch postgresql \
 && tar xzf postgresql-*.apk \
 && cd $OLDPWD \
 && cp /tmp/postgres-apk/usr/bin/pg_dump /usr/local/bin \
 && cp /tmp/postgres-apk/usr/bin/pg_restore /usr/local/bin \
 && rm -rf /tmp/postgres-apk /var/cache/apk/* \
 && addgroup -g 50 -S pgadmin \
 && adduser -D -S -h /pgadmin -s /sbin/nologin -u 1000 -G pgadmin pgadmin \
 && mkdir -p /pgadmin/config /pgadmin/storage \
 && chown -R 1000:50 /pgadmin

EXPOSE 5050

COPY LICENSE config_local.py /usr/local/lib/python2.7/site-packages/pgadmin4/

USER pgadmin:pgadmin
CMD [ "python", "./usr/local/lib/python2.7/site-packages/pgadmin4/pgAdmin4.py" ]
VOLUME /pgadmin/

FROM nginx:stable-alpine-slim AS base

RUN set -ex; \
    apk upgrade --no-cache; \
    apk add --no-cache supervisor logrotate; \
    mv /etc/nginx /etc/nginx-orig;

# ----------

FROM base AS build

WORKDIR /build/
COPY ./build/ ./

RUN sh get-nginx-ui.sh

# ----------

FROM base AS final

COPY --from=build /build/extract/nginx-ui /usr/local/bin/nginx-ui
COPY ./docker/ /

EXPOSE 80 443 9000

LABEL   maintainer=starina \
        description="Nginx + Nginx UI as a Docker container" \
        org.opencontainers.image.vendor=starina \
        org.opencontainers.image.source=https://github.com/xstarina/nginx_nginx-ui \
        org.opencontainers.image.title=nginx_nginx-ui \
        org.opencontainers.image.description="Nginx + Nginx UI as a Docker container" \
        org.opencontainers.image.licenses=MIT

ENTRYPOINT ["sh", "/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]

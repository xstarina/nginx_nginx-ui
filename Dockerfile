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

LABEL org.opencontainers.image.title=nginx_nginx-ui \
      org.opencontainers.image.description="Nginx + Nginx-ui as a Docker container" \
      org.opencontainers.image.vendor=starina

EXPOSE 80 443 9000

ENTRYPOINT ["sh", "/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]

# edit 240402-01

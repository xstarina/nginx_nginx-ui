FROM nginx:stable-alpine

RUN set -x \
 && apk upgrade --no-cache \
 && apk add --no-cache logrotate bash openrc

COPY ./docker/nginx-ui/get-latest.sh /nginx-ui/
RUN set -x \
  && mv /etc/nginx /etc/nginx-orig \
  && bash /nginx-ui/get-latest.sh

COPY ./docker/ /
RUN set -x && chmod +x /etc/init.d/*

EXPOSE 80 443 9000

ENTRYPOINT ["bash", "/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]

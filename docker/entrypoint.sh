#!/bin/bash

set -e

UI_DIR=/etc/nginx-ui

create_configs() {
  local NGINX_CONF
  NGINX_CONF=/etc/nginx/nginx.conf
  sed -i 's/.*worker_processes.*;/worker_processes auto;/' $NGINX_CONF
  sed -i '/^http {/,/^}/!b;/^}/i\    include /etc/nginx/sites-enabled/*;' $NGINX_CONF
}

mkdir -p /etc/nginx
if [[ "$(ls -A /etc/nginx)" = "" ]]; then
  echo "Initialing Nginx config dir..."

  cp -rp /etc/nginx-orig/* /etc/nginx/
  mkdir -p /etc/nginx/sites-{enabled,available}
  create_configs

  echo "Nginx config dir is done"
fi

mkdir -p $UI_DIR
if [[ ! -f "${UI_DIR}/app.ini" ]]; then
  echo "Initialing Nginx UI config file..."

  cat > "${UI_DIR}/app.ini" << EOF
[server]
RunMode = release
HttpPort = 9000
HTTPChallengePort = 9180
EOF

  echo "Nginx UI config file is done"
fi

for SVC in nginx-ui cron; do service $SVC start; done

exec "$@"

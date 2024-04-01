#!/bin/sh

set -e

NGINX_DIR=/etc/nginx
UI_DIR=/etc/nginx-ui
NGINX_CONF=${NGINX_DIR}/nginx.conf

create_configs() {
  sed -i 's/.*worker_processes.*;/worker_processes auto;/' ${NGINX_CONF}
  sed -i "/^http {/,/^}/!b;/^}/i\    include ${NGINX_DIR}/sites-enabled/*;\n    include ${NGINX_DIR}/streams-enabled/*;" ${NGINX_CONF}
}

mkdir -p ${NGINX_DIR}
if [[ "$(ls -A ${NGINX_DIR})" = "" ]]; then
  echo 'Initialing Nginx config dir...'

  cp -rp /etc/nginx-orig/* ${NGINX_DIR}/
  for D1 in sites streams; do
    for D2 in enabled available; do
      mkdir -p ${NGINX_DIR}/${D1}-${D2}
    done
  done
  create_configs

  echo 'Nginx config dir is done'
fi

mkdir -p ${UI_DIR}
if [[ ! -f "${UI_DIR}/app.ini" ]]; then
  echo 'Initialing Nginx UI config file...'

  cat > ${UI_DIR}/app.ini << EOF
[server]
RunMode = release
HttpPort = 9000
HTTPChallengePort = 9180

[nginx]
AccessLogPath = /var/log/nginx/access.log
ErrorLogPath = /var/log/nginx/error.log
RestartCmd = /usr/bin/supervisorctl restart nginx
EOF

  echo 'Nginx UI config file is done'
fi

if grep -qF '[nginx_log]' ${UI_DIR}/app.ini; then
  echo "Migrating ${UI_DIR}/app.ini to a new format..."
  sed -i.bak "s/\[nginx_log\]/[nginx]\nRestartCmd = \/usr\/bin\/supervisorctl restart nginx/" ${UI_DIR}/app.ini
  echo 'Migrating done'
fi

if ! grep -qF '/streams-enabled/*;' ${NGINX_CONF}; then
  echo "Adding Nginx streams to ${NGINX_CONF}..."
  for D2 in enabled available; do
    mkdir -p ${NGINX_DIR}/streams-${D2}
  done
  sed -i.bak "/^http {/,/^}/!b;/^}/i\    include ${NGINX_DIR}/streams-enabled/*;" ${NGINX_CONF}
  echo 'Streams done'
fi

for L in access error; do
  LOG=/var/log/nginx/${L}.log
  [ -L $LOG ] && rm -f $LOG
done

exec "$@"

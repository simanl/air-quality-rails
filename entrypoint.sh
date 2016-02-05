#! /bin/bash
# Entrypoint script for the production-ready app container
set -e

: ${APP_PATH:="/usr/src/app"}

# 1: Especificar el comando por omisión:
if [ -z "$1" ]; then set -- /usr/bin/supervisord --configuration=${APP_PATH}/config/supervisord-web.conf "$@"; fi

# 3: Ejecutar el comando recibido, o el comando por omisión:
exec "$@"

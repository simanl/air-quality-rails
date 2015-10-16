#! /bin/bash

set -e

: ${APP_PATH:="/app"}
: ${APP_TEMP_PATH:="$APP_PATH/tmp"}
: ${APP_SETUP_LOCK:="$APP_TEMP_PATH/setup.lock"}
: ${APP_SETUP_WAIT:="5"}

# 1: Define the functions lock and unlock our app containers setup processes:
function lock_setup { mkdir -p $APP_TEMP_PATH && touch $APP_SETUP_LOCK; }
function unlock_setup { rm -rf $APP_SETUP_LOCK; }
function wait_setup { echo "Waiting for app setup to finish..."; sleep $APP_SETUP_WAIT; }

# 2: 'Unlock' the setup process if the script exits prematurely:
trap unlock_setup HUP INT QUIT KILL TERM

# 3: Wait until the setup 'lock' file no longer exists:
while [ -f $APP_SETUP_LOCK ]; do wait_setup; done

# 4: 'Lock' the setup process, to prevent a race condition when the project's
# app containers will try to install gems and setup the database concurrently:
lock_setup

# 5: Check if data tables exist, or download the initial data tables:
if [ ! -f ${APP_PATH}/tablas/series/tabla_maestra_imputada.RData ]; then
  echo "Downloading initial tables..."
  ${APP_PATH}/descargar-tablas-iniciales.sh
  echo "Finished!"
fi

# 6: 'Unlock' the setup process:
unlock_setup

# 7: Set the default command:
if [ -z "$1" ]; then set -- Rscript start.R "$@"; fi

# 8: Execute the given or default command:
exec "$@"

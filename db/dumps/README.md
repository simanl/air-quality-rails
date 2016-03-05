# Project Database Dumps

This directory is intended to store database dumps from any of the online
environments (staging, production), to be easily restored back in the dev
environment. It's configured in Git to ignore these dump files.

## 1: Obtaining a database dump:

You'll need to use the `pg_dump` command from the Postgres client tools to
generate a dump directly from the database. Keep in mind that running this
command requires an available postgres connection, which will add up to your
app's used connections while the command is running.

You can also use this method to generate a dump from the local database, if you
need to.

```bash
# Replace [HOSTNAME], [PORT], [USERNAME], [LOCAL_DUMP_FILE] and [DBNAME] with
# your desired values. Keep at hand your instance's password, as it will be
# promted:

# 1a: If your'e using Docker+Compose, you can use your postgres container to do
# that for you, specially useful if you haven't installed the postgres client
# libraries in your host. Check the container's name [PG_CONTAINER_NAME] as it
# may vary depending on the app's directory name:
docker exec -ti [PG_CONTAINER_NAME] pg_dump \
  --host=[HOSTNAME] --port=[PORT] --username=[USERNAME] --password \
  --compress=9 --no-privileges --no-owner --format=custom \
  --clean --file=db/dumps/staging.dump [DBNAME]

# 1b: If you have the Postgres client tools installed on your host, you can run
# the `pg_dump` command directly:
pg_dump --host=[HOSTNAME] --port=[PORT] --username=[USERNAME] --password \
  --compress=9 --no-privileges --no-owner --format=custom \
  --clean --file=[LOCAL_DUMP_FILE] [DBNAME]
```

## 2: Restoring the database from a local dump using the `pg_restore` command

Once you've got a database dump, you can restore it using the `pg_restore`
command from the Postgres client tools:

```bash

# 1a: If your'e using Docker+Compose, you can use the project's `restoredb`
# script to totally replace the given database with the given dump:
# (Replace "rts_postgres_1" depending of the directory name of the project)
docker exec -ti rts_postgres_1 restoredb rts_development db/dumps/staging.dump

# 1b: If you have the Postgres client tools installed on your host, you can run
# the `pg_restore` command directly:
pg_restore --host=[HOSTNAME] --port=[PORT] --username=[USERNAME] --password \
  --dbname=rts_development --clean --no-owner --no-privileges --verbose --jobs=2 \
  [LOCAL_DUMP_FILE]
```

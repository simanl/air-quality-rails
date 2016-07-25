# Air Quality Rails Production DB Dump/Restore:

## 1: Installar [GDrive](https://github.com/prasmussen/gdrive)

```bash
curl -o /usr/local/sbin/gdrive -L "https://docs.google.com/uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download"
```

## 2: Generar dumps:

```bash
DUMP_FILEPATH="/tmp/production-`date --utc +'%Y-%m-%d-%H%M%S%z'`.dump" \
  && pg_dump -U postgres --compress=9 --no-privileges --no-owner --format=custom --file=$DUMP_FILEPATH air_quality_production \
  && gdrive upload --parent 0BwCAD_sF1ReMNUNkeEExLV9YZDA $DUMP_FILEPATH
```

## 3: Cargar dumps:

```bash
gdrive download SOME_GDRIVE_FILE_ID

dropdb -U postgres -e --if-exists air_quality_production \
  && createdb -U postgres air_quality_production \
  && pg_restore -U postgres --dbname=air_quality_production \
     --clean --no-owner --no-privileges --verbose --jobs=2 \
     2016-07-24-150202+0000.dump
```

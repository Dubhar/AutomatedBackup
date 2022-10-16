#!/usr/bin/env ash

main()
{
  local DESTINATION="$(date +%Y%m%d)"

  bak_prepare
  bak_database
  bak_custom
  bak_compress
  bak_cleanup
}

bak_prepare()
{
  echo "Creating temporary backup directory"
  mkdir -p "${DESTINATION}"
}

bak_database()
{
  mkdir -p "${DESTINATION}/database"
  local DATABASES=$(env | grep '^BACKUP_')

  for DATABASE in $DATABASES; do
    # db name is between everything before the first "=" but after the first "_"
    local dbname=$(echo "${DATABASE}" | cut -d= -f1 | cut -d_ -f2-)
    # db username is assumed to match db name for now
    local dbuser="${dbname}"
    # db password is everything after the first "="
    local dbpass=$(echo "${DATABASE}" | cut -d= -f2-)
    local filename="${dbname}.sql"

    echo "Copying database '$dbname'"
    mysqldump --user "$dbuser" --password="$dbpass" --host "${DB_HOST}" "$dbname" > "${DESTINATION}/database/${filename}"
  done
}

bak_custom()
{
  for FILEPATH in $(find /custom -type f); do
    local filename=$(basename "${FILEPATH}")
    local dirname=$(dirname "${FILEPATH}")

    echo "Copying custom file ${FILEPATH}"
    mkdir -p "${DESTINATION}/${dirname}"
    cp "${FILEPATH}" "${DESTINATION}/${dirname}/${filename}"
  done
}

bak_compress()
{
  echo "Compressing backup"
  local ARCHIVE="$(basename "${DESTINATION}").tar.gz"
  tar -czf "${ARCHIVE}" "${DESTINATION}"
  mv "${ARCHIVE}" /backup/
}

bak_cleanup()
{
  echo "Clean up temporary files"
  rm -rf "${DESTINATION}"
  
  echo "Clean up files older than ${RETENTION_DAYS} days"
  find /backup -mtime "+${RETENTION_DAYS}" -delete
}

main "$@"


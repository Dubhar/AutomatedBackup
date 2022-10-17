# AutomatedBackup

This is a docker container that is used for daily exports of databases and given files as tar.gz archive.

## Usage

Just start the container and specify what to backup and where to back it up to via environment variables and mounts.

| Configuration | Description |
| --------------|-------------|
| ENV[RETENTION\_DAYS] | How many days the archives will be kept before they are deleted |
| ENV[DB\_HOST] | Hostname of the database server, must be reachable from within this container! |
| ENV[BACKUP\_<DB\_NAME>] | Name of the database to backup and corresponding password |
| mnt[/backup] | Directory to store the created archives in |
| mnt[/custom/\*] | Custom files and directories that shall be backed up |

At the moment it is assumed that database name and database user are the same!

Example configuration using docker-compose:
```
version: "3.7"

services:
  mariadb:
    image: mariadb:latest
    environment:
      - MYSQL_ROOT_PASSWORD=5up€rS€cr€tP4$$w0rd
    volumes:
      - '/media/MariaDbDrive:/var/lib/mysql'
    restart: unless-stopped
  automatedbackup:
    image: dubhar/automatedbackup:latest
    restart: unless-stopped
    environment:
      - "RETENTION_DAYS=15"
      - "DB_HOST=mariadb"
      - "BACKUP_owncloud=5up€rS€cr€tP4$$w0rd
      - "BACKUP_wordpress=5up€rS€cr€tP4$$w0rd
    volumes:
      - "/media/BackupDrive:/backup"
      - "./docker-compose.yml:/custom/docker-compose.yml:ro"
    depends_on:
      - mariadb
```


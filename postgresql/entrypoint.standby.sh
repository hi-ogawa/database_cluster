#!/bin/bash
set -e

if [ "$1" = 'postgres' ]; then
  mkdir -p "$PGDATA"
  chmod 700 "$PGDATA"
  chown -R postgres "$PGDATA"

  chmod g+s /run/postgresql
  chown -R postgres /run/postgresql

  cp /pg_hba.conf $PGDATA/pg_hba.conf
  cp /postgresql.conf $PGDATA/postgresql.conf
  cp /recovery.conf $PGDATA/recovery.conf

  exec gosu postgres postgres
fi

exec "$@"

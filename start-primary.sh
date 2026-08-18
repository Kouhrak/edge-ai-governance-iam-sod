#!/bin/bash
set -euo pipefail

# start-primary.sh — Start postgres then bootstrap replication user + slot
REPLICATION_USER="${REPLICATION_USER:-repl}"
REPLICATION_PASSWORD="${REPLICATION_PASSWORD:?REPLICATION_PASSWORD required}"
REPLICATION_SLOT="replica_slot"
PGDATA="/var/lib/postgresql/data"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_DB="${POSTGRES_DB:-edge_iam}"

# Start postgres in background
docker-entrypoint.sh postgres \
    -c wal_level=replica \
    -c max_wal_senders=10 \
    -c max_replication_slots=10 &
PGPID=$!

# Wait for it
until pg_isready -U "$POSTGRES_USER" -q; do sleep 2; done

# Create replication user (idempotent)
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c \
    "DO \$\$
     BEGIN
       IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '${REPLICATION_USER}') THEN
         CREATE ROLE ${REPLICATION_USER} WITH REPLICATION LOGIN PASSWORD '${REPLICATION_PASSWORD}';
       END IF;
     END
     \$\$;"

# Create replication slot (idempotent)
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c \
    "SELECT pg_create_physical_replication_slot('${REPLICATION_SLOT}');"

# Allow replication connections
if ! grep -q "replication" "$PGDATA/pg_hba.conf" 2>/dev/null; then
    echo "host replication ${REPLICATION_USER} 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"
    echo "host replication ${REPLICATION_USER} ::/0 md5" >> "$PGDATA/pg_hba.conf"
    echo "[primary] Added replication entries to pg_hba.conf"
fi

# Reload postgres so it picks up the pg_hba.conf changes
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT pg_reload_conf();"
echo "[primary] Config reloaded."

echo "[primary] Replication bootstrap complete. Postgres running."

# Stay alive
wait "$PGPID"

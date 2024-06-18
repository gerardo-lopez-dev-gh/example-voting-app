#!/bin/bash
#!/bin/bash
set -eo pipefail

host="$(hostname -i || echo '127.0.0.1')"
user="${POSTGRES_USER:-postgres}"
db="${POSTGRES_DB:-$POSTGRES_USER}"
export PGPASSWORD="${POSTGRES_PASSWORD:-}"

# Verificar si el directorio de datos ya existe
if [ -d "/var/lib/postgresql/data" ]; then
  echo "Database directory already exists, skipping initialization"
else
  echo "Initializing database"
  initdb -D /var/lib/postgresql/data
fi

# Verificar la conectividad de la base de datos
args=(
  # force postgres to not use the local unix socket (test "external" connectibility)
  --host "$host"
  --username "$user"
  --dbname "$db"
  --quiet --no-align --tuples-only
)

if select="$(echo 'SELECT 1' | psql "${args[@]}")" && [ "$select" = '1' ]; then
  exit 0
fi

exit 1

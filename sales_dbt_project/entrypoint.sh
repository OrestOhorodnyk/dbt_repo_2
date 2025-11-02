#!/bin/bash
set -e

# Create profiles directory if it doesn't exist (Cosmos uses /tmp/airflow_cosmos)
# Cosmos generates profiles.yml dynamically and sets DBT_PROFILES_DIR
PROFILES_DIR="${DBT_PROFILES_DIR:-/tmp/airflow_cosmos}"
if [ ! -d "$PROFILES_DIR" ]; then
    mkdir -p "$PROFILES_DIR"
fi

# Write profiles.yml if it doesn't exist or if forced
# Cosmos 1.11.0 doesn't automatically inject profiles in Kubernetes mode
PROFILES_FILE="$PROFILES_DIR/profiles.yml"
if [ ! -f "$PROFILES_FILE" ] || [ "${FORCE_WRITE_PROFILE:-false}" = "true" ]; then
    cat > "$PROFILES_FILE" <<EOF
postgres_profile:
  outputs:
    dev:
      type: postgres
      host: "${DBT_HOST:-postgres-service}"
      user: "${DBT_USER:-dbt}"
      password: "${DBT_PASS:-dbt}"
      port: ${DBT_PORT:-5432}
      dbname: "${DBT_DBNAME:-analytics}"
      schema: analytics
      threads: 4
  target: dev
EOF
    echo "Created profiles.yml at $PROFILES_FILE"
fi

# Forward all arguments to dbt command
# Cosmos passes arguments like: dbt seed --select orders --profile postgres_profile ...
# This script forwards them correctly instead of running hardcoded commands
exec "$@"


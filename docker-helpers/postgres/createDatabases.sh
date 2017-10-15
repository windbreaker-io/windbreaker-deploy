#!/bin/bash

set -e

function createDatabase () {
  local dbName=$1
  local user=$2
  local pass=$3

  echo "Creating database '$dbName'"
  psql -v ON_ERROR_STOP=1 --username "$user" --password "$pass"<<-EOL
    CREATE USER $user;
    CREATE DATABASE $dbName;
    GRANT ALL PRIVILEGES ON DATABASE $dbName TO $user;
EOL
  echo "Done creating '$dbName'"
}

IFS=',' read -ra dbNames <<< "$POSTGRES_DATABASES"
for dbName in "${dbNames[@]}"; do
  # trim leading/trailing whitespace
  dbName=$(echo "$dbName" | xargs)
  createDatabase $dbName $POSTGRES_USER $POSTGRES_PASSWORD
done

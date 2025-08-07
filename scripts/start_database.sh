#!/usr/bin/env bash
set -euo pipefail

POSTGRES_VOLUME="$HOME/.local/share/podman/volumes/postgres_data"
MYSQL_VOLUME="$HOME/.local/share/podman/volumes/mysql_data"

mkdir -p "$POSTGRES_VOLUME" "$MYSQL_VOLUME"

# PostgreSQL
if podman ps -a --format '{{.Names}}' | grep -q '^pg-dev$'; then
  if ! podman ps --format '{{.Names}}' | grep -q '^pg-dev$'; then
    echo "Iniciando container pg-dev"
    podman start pg-dev
  else
    echo "Container pg-dev já está rodando"
  fi
else
  echo "Criando e iniciando container pg-dev"
  podman run -d \
    --name pg-dev \
    -p 5432:5432 \
    -e "POSTGRES_USER=$USER" \
    -e "POSTGRES_PASSWORD=" \
    -e "POSTGRES_DB=$USER" \
    -v "$POSTGRES_VOLUME:/var/lib/postgresql/data:Z" \
    postgres:15
fi

# MySQL
if podman ps -a --format '{{.Names}}' | grep -q '^mysql-dev$'; then
  if ! podman ps --format '{{.Names}}' | grep -q '^mysql-dev$'; then
    echo "Iniciando container mysql-dev"
    podman start mysql-dev
  else
    echo "Container mysql-dev já está rodando"
  fi
else
  echo "Criando e iniciando container mysql-dev"
  podman run -d \
    --name mysql-dev \
    -p 3306:3306 \
    -e "MYSQL_ROOT_PASSWORD=" \
    -e "MYSQL_USER=$USER" \
    -e "MYSQL_PASSWORD=" \
    -e "MYSQL_DATABASE=$USER" \
    -v "$MYSQL_VOLUME:/var/lib/mysql:Z" \
    mysql:8
fi

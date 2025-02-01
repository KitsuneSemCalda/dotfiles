#!/usr/bin/env bash

# Global variable

# DRY RUN MODE IS ENABLE or not
DRY_RUN=true

# actually_date do be used globally
actually_date=$(date "+%d-%m-%Y")

# Directory base base
backup_dir="$HOME/Backups"

dropbox_dir="$HOME/Dropbox"

vault_directory="$HOME/Documentos/Study"

# Directories List Backup
xdg_dir_directories=(
  "$HOME/Documentos/"
  "$HOME/Imagens/"
)

folders_to_backup=(
  "$HOME/.ssh/"
  "$HOME/.netrc"
  "$HOME/Documentos/senhas"
)

# Auxiliar functions
#
# Dry or Run, check if global variable DRY RUN is enabled or not and show command or execute him
dry_or_run() {
  if [ "$DRY_RUN" = true ]; then
    echo "[Dry-run] $1"
  else
    eval "$1"
  fi
}

# Check and create, check if folder exists, and create him if not found
check_and_create() {
  directory=$1

  if [ ! -d "$directory" ]; then
    dry_or_run "mkdir -p \"$directory\""
  fi
}

# Backup dos diretórios XDG
backup_xdg_dir() {
  local backup_directory="$backup_dir/XDG_DIR"
  local dropbox_directory_xdg="$dropbox_dir/xdg_dir"
  local output_xdg_directory="$actually_date.zip"
  echo "==##== Iniciando Processo de Backup dos Diretórios XDG ==##=="

  check_and_create "$backup_directory"
  check_and_create "$dropbox_directory_xdg"

  for directory in "${xdg_dir_directories[@]}"; do
    if [ -d "$directory" ]; then
      dry_or_run "cp -r \"$directory\" \"$backup_directory/\""
    else
      echo "[Dry-run] Aviso: $directory não existe, ignorando."
    fi
  done

  dry_or_run "zip -r \"$output_xdg_directory\" \"$backup_directory\""
  dry_or_run "mv \"$output_xdg_directory\" \"$dropbox_directory_xdg\""

  echo "==##== Backup dos Diretórios XDG Finalizado ==##=="
}

# Backup de segurança (arquivos sensíveis)
backup_security() {
  local backup_security_dir="$backup_dir/Security"
  local output_security_directory="security-$actually_date.zip"

  echo "==##== Iniciando Processo de Backup de Segurança ==##=="

  check_and_create "$backup_security_dir"

  for folder in "${folders_to_backup[@]}"; do
    if [ -e "$folder" ]; then
      dry_or_run "cp -r \"$folder\" \"$backup_security_dir/\""
    else
      echo "[Dry-run] Aviso: $folder não encontrado, ignorando."
    fi
  done

  dry_or_run "zip -r \"$output_security_directory\" \"$backup_security_dir\""
  dry_or_run "mv \"$output_security_directory\" \"$HOME/Documentos/\""

  echo "==##== Backup de Segurança Finalizado ==##=="
}

# Backup do Vault
backup_vault() {
  local backup_vault_dir="$backup_dir/Vault"
  output_vault_directory="$actually_date.zip"
  local dropbox_directory_vault="$dropbox_dir/Backup_Projects"

  echo "==##== Iniciando Processo de Backup do Vault ==##=="

  check_and_create "$backup_vault_dir"

  if [ -d "$vault_directory" ]; then
    dry_or_run "cp -r \"$vault_directory\" \"$backup_vault_dir/\""
    dry_or_run "zip -r \"$output_vault_directory\" \"$backup_vault_dir\""
    dry_or_run "mv \"$output_vault_directory\" \"$dropbox_directory_vault\""
  else
    echo "[Dry-run] Aviso: Diretório do Vault não encontrado, ignorando."
  fi

  echo "==##== Backup do Vault Finalizado ==##=="
}

start_backup() {
  echo "=#= Iniciando Processo de Backup =#="

  backup_xdg_dir
  backup_vault
  backup_security

  echo "=#= Backup Finalizado =#="
}

start_backup

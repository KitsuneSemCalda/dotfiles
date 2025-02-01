#!/usr/bin/env bash

DRY_RUN=true

actually_date=$(date "+%d-%m-%Y")
backup_dir="$HOME/Backups"
dropbox_dir="$HOME/Dropbox"
vault_directory="$HOME/Documentos/Study"

dropbox_directory_xdg="$dropbox_dir/xdg_dir"
dropbox_directory_vault="$dropbox_dir/Backup_Projects"

directories_to_backup=(
  "$HOME/Documentos/"
  "$HOME/Imagens/"
)

sensitive_folders=(
  "$HOME/.ssh/"
  "$HOME/.netrc"
  "$HOME/Documentos/senhas"
)

dry_or_run() {
  if [ "$DRY_RUN" = true ]; then
    echo "[Dry-run] $1"
  else
    eval "$1"
  fi
}

check_and_create() {
  local directory="$1"
  if [ ! -d "$directory" ]; then
    dry_or_run "mkdir -p \"$directory\""
  fi
}

backup_xdg_dir() {
  local backup_directory="$backup_dir/XDG_DIR"
  local output_xdg_zip="$backup_directory/$actually_date.zip"

  echo "==##== Iniciando Backup dos Diretórios XDG ==##=="
  check_and_create "$backup_directory"
  check_and_create "$dropbox_directory_xdg"

  for directory in "${directories_to_backup[@]}"; do
    if [ -d "$directory" ]; then
      dry_or_run "cp -r \"$directory\" \"$backup_directory/\""
    else
      echo "[Dry-run] ⚠️ AVISO: O diretório '$directory' não existe, pulando."
    fi
  done

  (cd "$backup_directory" && dry_or_run "zip -r \"$output_xdg_zip\" .")
  dry_or_run "mv \"$output_xdg_zip\" \"$dropbox_directory_xdg\""
  echo "==##== Backup dos Diretórios XDG Finalizado ==##=="
}

# Backup de arquivos sensíveis
backup_security() {
  local backup_security_dir="$backup_dir/Security"
  local output_security_zip="$HOME/Documentos/$actually_date.zip"

  echo "==##== Iniciando Backup de Segurança ==##=="
  check_and_create "$backup_security_dir"

  for folder in "${sensitive_folders[@]}"; do
    if [ -e "$folder" ]; then
      dry_or_run "cp -r \"$folder\" \"$backup_security_dir/\""
      [[ "$folder" == *".netrc"* ]] && dry_or_run "chmod 600 \"$backup_security_dir/.netrc\""
    else
      echo "[Dry-run] ⚠️ AVISO: '$folder' não encontrado, ignorando."
    fi
  done

  (cd "$backup_security_dir" && dry_or_run "zip -r \"$output_security_zip\" .")
  echo "==##== Backup de Segurança Finalizado ==##=="
}

# Backup do Vault
backup_vault() {
  local backup_vault_dir="$backup_dir/Vault"
  local output_vault_zip="$backup_vault_dir/$actually_date.zip"

  echo "==##== Iniciando Backup do Vault ==##=="
  check_and_create "$backup_vault_dir"
  check_and_create "$dropbox_directory_vault"

  if [ -d "$vault_directory" ]; then
    dry_or_run "cp -r \"$vault_directory\" \"$backup_vault_dir/\""
    (cd "$backup_vault_dir" && dry_or_run "zip -r \"$output_vault_zip\" .")
    dry_or_run "mv \"$output_vault_zip\" \"$dropbox_directory_vault\""
  else
    echo "[Dry-run] ⚠️ AVISO: Diretório do Vault não encontrado, ignorando."
  fi
  echo "==##== Backup do Vault Finalizado ==##=="
}

start_backup() {
  echo "=#= Iniciando Processo de Backup em $(date '+%d-%m-%Y %H:%M:%S') =#="
  backup_xdg_dir
  backup_security
  backup_vault
  echo "=#= Backup Finalizado em $(date '+%d-%m-%Y %H:%M:%S') =#="
}

start_backup

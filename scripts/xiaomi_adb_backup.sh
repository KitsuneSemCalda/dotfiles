#!/usr/bin/env bash

set -e

if ! command -v adb &>/dev/null; then
  log "We need 'adb' to run this script."
  exit 1
fi

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

backup_xiaomi() {
  local backup_directory="$1"
  log "Initializing Xiaomi device backup process..."

  local device_count
  device_count=$(adb devices | grep -c "device")

  if [ "$device_count" -eq 0 ]; then
    log "ERROR: No Xiaomi device connected via ADB."
    exit 1
  fi

  log "Waiting for device authorization (check your phone)..."
  adb wait-for-device

  backup_dir="$backup_directory/xiaomi_backup_$(date '+%Y%m%d_%H%M%S')"
  mkdir -pv "$backup_dir"

  # Execute full backup: apps, shared data, no APKs to reduce size
  log "Starting backup. Please confirm the operation on your device screen..."
  adb backup -apk -shared -all -f "$backup_dir/backup.ab"

  log "Backup completed successfully. File saved at: $backup_dir/backup.ab"
}

export -f backup_xiaomi

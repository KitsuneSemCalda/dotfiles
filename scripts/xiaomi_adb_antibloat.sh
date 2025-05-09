#!/usr/bin/env bash

set -e

if ! command -v adb &>/dev/null; then
  log "We need 'adb' to run this script."
  exit 1
fi

if ! command -v gum &>/dev/null; then
  log "We need to 'gum' run this script."
  exit 1
fi

adb_exec() {
  adb shell "$@" >/dev/null 2>&1
}

abort() {
  exit 1
}

check_dependency() {
  command -v "$1" &>/dev/null || abort "Dependency '$1' not found. Please install it first."
}

log() { echo "[$(date +%H:%M:%S)] $1" | tee -a /tmp/android_tweaks.log; }

check_dependency adb
check_dependency gum

bloatware_list=(
  com.miui.cloudbackup
  com.miui.msa.global
  com.xiaomi.mipicks
  com.miui.videoplayer
  com.miui.player
)

remove_telemetry() {
  log "Disabling telemetry and data collection..."
  adb_exec settings put global xiaomi_concierge 0
  adb_exec settings put global send_system_log 0
  adb_exec settings put global send_usage_data 0
  adb_exec settings put global collect_location_data 0
  adb_exec settings put global miui_feedback 0
  log "Telemetry disabled!"
}

remove_bloatware() {
  for item in "${bloatware_list[@]}"; do
    if adb shell pm list packages | grep -q "$item"; then
      log "Removing bloatware: $item..."
      adb_exec pm uninstall --user 0 "$item"
    else
      log "Bloatware not found: $item"
    fi
  done
}

remove_permissions() {
  log "Resetting all app permissions..."
  adb_exec pm reset-permissions
  log "Permissions reset."
}

remove_animations() {
  log "Disabling animations..."
  adb_exec settings put global window_animation_scale 0.5
  adb_exec settings put global transition_animation_scale 0.5
  adb_exec settings put global animator_duration_scale 0.5
  log "Animations reduced!"
}

clean_cache() {
  log "Cleaning system cache..."
  adb_exec pm clear com.android.settings
  adb_exec rm -rf /data/dalvik-cache/*
  adb_exec rm -rf /cache/*
  log "Cache cleared!"
}

disable_xiaomi_store() {
  log "Disabling Xiaomi Store..."
  adb_exec pm disable-user --user 0 com.xiaomi.market
  adb_exec pm disable-user --user 10 com.xiaomi.market
  log "Xiaomi Store disabled!"
}

disable_app_recommendation() {
  log "Disabling app recommendations..."
  adb_exec settings put secure miui.app_recommendation 0
}

disable_mi_cloud_sync() {
  log "Disabling Mi Cloud sync..."
  adb_exec settings put global miui_cloud_sync 0
}

disable_autosuggestion() {
  log "Disabling autosuggestions and system prompts..."
  adb_exec settings put secure miui.notifications 0
  adb_exec settings put secure miui.help 0
  adb_exec settings put secure miui.recommend 0
  adb_exec settings put secure miui.banner 0
  log "Suggestions and notifications disabled!"
}

disable_auto_update_app() {
  log "Disabling automatic updates..."
  adb_exec settings put global auto_update_apps 0
  adb_exec settings put global auto_update_system 0
  log "Auto-updates disabled!"
}

declare -A actions=(
  ["Remove Bloatware"]="remove_bloatware"
  ["Reset Permissions"]="remove_permissions"
  ["Disable Animations"]="remove_animations"
  ["Clean Cache"]="clean_cache"
  ["Disable Xiaomi Store"]="disable_xiaomi_store"
  ["Disable Auto App Updates"]="disable_auto_update_app"
  ["Disable Keyboard Autosuggestions"]="disable_autosuggestion"
  ["Disable App Recommendations"]="disable_app_recommendation"
  ["Disable Mi Cloud Sync"]="disable_mi_cloud_sync"
  ["Remove Telemetry"]="remove_telemetry"
)

run_all() {
  for func in "${actions[@]}"; do
    "$func"
  done
}

# UI logic
choices=("${!actions[@]}" "➤ Run All")
selected=$(gum choose --no-limit --height=15 "${choices[@]}")

[[ -z "$selected" ]] && abort "Nothing selected. Bye."

gum style --bold --foreground cyan "🧾 You selected:"
while IFS= read -r item; do
  gum style --foreground yellow "  • $item"
done <<<"$selected"

gum confirm "Proceed with these changes?" || {
  gum style --italic "🛑 Operation aborted."
  exit 1
}

gum style --bold --foreground green "\n🚀 Running tweaks...\n"

if grep -q "➤ Run All" <<<"$selected"; then
  run_all
else
  while IFS= read -r line; do
    line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    func="${actions[$line]}"
    if [[ -n "$func" ]]; then
      "$func"
    else
      log "⚠️ Unknown selection: '$line'"
    fi
  done <<<"$selected"
fi

gum style --bold --foreground green "\n✅ Done. Your phone is now less evil."

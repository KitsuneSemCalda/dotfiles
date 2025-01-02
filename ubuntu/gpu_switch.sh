#!/bin/bash

# TODO: adding some comments about each part of logic

set -e

GPU_SWITCH_CONFIG="/etc/gpu_swith.conf"
LOG_FILE="/var/log/gpu_switch.log"
CURRENT_GPU="intel"
LOCKFILE="/tmp/gpu_switch.lock"
MAX_LOCK_TIME=600

log_message() {
  local message="$1"
  local timestamp
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "$timestamp - $message" >>"$LOG_FILE"

  if [ $(stat --printf="%s" "$LOG_FILE") -gt 5242880 ]; then
    mv "$LOG_FILE" "$LOG_FILE.old"
    echo "$(date "+%Y-%m-%d %H:%M:%S") - Log rotated" >"$LOG_FILE"
  fi
}

check_command() {
  command -v "$1" &>/dev/null
  if [ $? -ne 0 ]; then
    log_message "Error: command $1 not found!"
    exit 1
  fi
}

check_lockfile() {
  if [ -e "$LOCKFILE" ]; then
    local lock_time=$(stat --format=%Y "$LOCKFILE")
    local current_time=$(date +%s)
    local time_diff=$((current_time - lock_time))

    if [ $time_diff -gt $MAX_LOCK_TIME ]; then
      log_message "Lockfile expired. Proceeding with script execution."
    else
      log_message "Script is already running. Exiting..."
      exit 1
    fi
  fi
}

check_cpupower() {
  if [ ! -d "/sys/devices/system/cpu/cpufreq" ]; then
    log_message "Error: cpupower not available. CPU frequency adjustment is not supported."
    exit 1
  fi
}

save_config() {
  echo "$CURRENT_GPU" >"$GPU_SWITCH_CONFIG"
  log_message "GPU config saved as $CURRENT_GPU"
}

save_profile() {
  >~/.config/gpu_switch_profile

  grep -q "DRI_PRIME" ~/.config/gpu_switch_profile || echo "export DRI_PRIME=$dri_prime" >>~/.config/gpu_switch_profile
  grep -q "__GLX_VENDOR_LIBRARY_NAME" ~/.config/gpu_switch_profile || echo "export __GLX_VENDOR_LIBRARY_NAME=$glx_vendor" >>~/.config/gpu_switch_profile
  grep -q "__VK_LAYER_NV_optimus" ~/.config/gpu_switch_profile || echo "export __VK_LAYER_NV_optimus=$vk_layer" >>~/.config/gpu_switch_profile

  notify-send "Save GPU profile to persistency"
  log_message "GPU profile saved in ~/.config/gpu_switch_profile"
}

read_config() {
  if [ -f "$GPU_SWITCH_CONFIG" ]; then
    CURRENT_GPU=$(cat "$GPU_SWITCH_CONFIG")
    log_message "GPU config read as: $CURRENT_GPU"
  else
    CURRENT_GPU="intel"
    log_message "GPU config is not found, use integrated GPU as default"
  fi
}

adjust_energy_economy() {
  inotifywait -e modify /sys/class/power_supply/AC/online /sys/class/power_supply/BAT/status >/dev/null

  if cat /sys/class/power_supply/AC/online | grep -q "1" && cat /sys/class/power_supply/BAT/status | grep -q "Charging"; then
    log_message "Power Supply is connected: disable energy charge"
    echo 0 >/sys/class/power_supply/BAT/charge_control_start_threshold
  else
    echo "Power Supply is disconnected: enable energy charge"
    echo 100 >/sys/class/power_supply/BAT/charge_control_start_threshold
  fi
}

adjust_settings() {
  local gpu=$1
  local cpu_governor=$2
  local max_freq=$3
  local turbo_mode=$4
  local prime_options=$5
  local glx_vendor=$6
  local vk_layer=$7
  local dri_prime=$8

  if [ "$CURRENT_GPU" == "$gpu" ]; then
    log_message "GPU $gpu already configured. No changes needed."
    return
  fi

  prime-select "$prime_options" || {
    log_message "Failed to switch to $gpu using prime-select"
    return
  }

  cpupower frequency-set --governor "$cpu_governor"
  cpupower frequency-set --max "$max_freq"
  cpupower frequency-set --turbo "$turbo_mode"

  export DRI_PRIME=$dri_prime
  export __GLX_VENDOR_LIBRARY_NAME=$glx_vendor
  export __VK_LAYER_NV_optimus=$vk_layer

  CURRENT_GPU=$gpu
  save_config
  save_profile
  add_source_to_dotprofile

  log_message "Settings adjusted for $gpu"
  notify-send "GPU $gpu ativada" "Configurações de desempenho aplicadas"
}

use_intel_gpu() {
  adjust_settings "intel" "powersave" "1.2GHz" "0" "intel" "mesa" "" "0"
  adjust_energy_economy
}

use_nvidia_gpu() {
  adjust_settings "nvidia" "performance" "3.5Ghz" "0" "nvidia" "nvidia" "NVIDIA_ONLY" "1"
  adjust_energy_economy
}

add_source_to_dotprofile() {
  if ! grep -q "source ~/.config/gpu_switch_profile" ~/.profile; then
    echo "source ~/.config/gpu_switch_profile" >>~/.profile
    log_message "Added source to ~/.config/gpu_switch_profile from .profile"
  fi
}

check_app_categorie() {
  local app_desktop_file="$1"
  if [ "$CURRENT_GPU" == "nvidia" ]; then
    if grep -q "Category=Game" "$app_desktop_file" || grep -q "Category=AudioVideo" "$app_desktop_file"; then
      use_nvidia_gpu
      log_message "Game or Media app detected, using NVIDIA GPU"
    elif grep -q "Category=Office" "$app_desktop_file" || grep -q "Category=Utility" "$app_desktop_file"; then
      use_intel_gpu
      log_message "Productivity or Utility app detected, using INTEL GPU"
    else
      use_nvidia_gpu # Padrão
      log_message "Can't detect app category: using NVIDIA as default"
    fi
  else
    use_intel_gpu
    log_message "NVIDIA GPU not active, keeping INTEL as default"
  fi
}

monitoring_egpu() {
  local timeout=5
  local elapsed=0
  while true; do
    if ! inotifywait -q -e create -e delete /sys/class/drm/; then
      log_message "Error: inotifywait failed in monitoring_egpu. Retrying..."
      sleep 5
      continue
    fi

    # Aguardando a eGPU ser detectada
    DEVICE=$(boltctl list | grep -i "NVIDIA" | awk '{print $1}')

    if [ -n "$DEVICE" ]; then
      use_nvidia_gpu
      log_message "eGPU NVIDIA detected, switched to NVIDIA GPU"
      elapsed=0
    else
      if [ $elapsed -ge $timeout ]; then
        use_intel_gpu
        log_message "Timeout reached without detecting eGPU. Switched to Intel GPU"
        elapsed=0
      else
        ((elapsed += 5))
      fi
    fi
    sleep 5
  done
}

if [ -e "$LOCKFILE" ] && kill -0 "$(cat "$LOCKFILE")" 2>/dev/null; then
  check_lockfile
fi

echo $$ >"$LOCKFILE"
trap 'rm -f "$LOCKFILE"' EXIT

check_command "cpupower"
check_command "prime-select"
check_command "boltctl"

check_cpupower

read_config

monitoring_egpu &
wait

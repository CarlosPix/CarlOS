#!/bin/sh
cd $(dirname "$0")
APPDIR="$(dirname "$0")"
rom_name=$(basename "$1" .zip)

HOME="$APPDIR"

cd $HOME
PATH="/mnt/SDCARD/miyoo355/bin:$PATH"
LD_LIBRARY_PATH="$HOME:/mnt/SDCARD/miyoo355/lib:$LD_LIBRARY_PATH"

gptokeyb -k "fbneo" -c "$HOME/fbneo.gptk" &

echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1104000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 1 > /sys/devices/system/cpu/cpu3/online
echo 1 > /sys/devices/system/cpu/cpu2/online

./fbneo_dpad -joy -fullscreen -best "${rom_name}"

sync

pkill -9 gptokeyb

echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1104000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 0 > /sys/devices/system/cpu/cpu2/online
echo 0 > /sys/devices/system/cpu/cpu3/online

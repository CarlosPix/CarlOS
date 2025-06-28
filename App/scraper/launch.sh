#!/bin/sh
cd $(dirname "$0")
export HOME=/mnt/SDCARD
export PATH="/mnt/SDCARD/miyoo355/bin:${PATH}"
export LD_LIBRARY_PATH="/mnt/SDCARD/miyoo355/lib:${LD_LIBRARY_PATH}"

echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1416000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1416000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 1 > /sys/devices/system/cpu/cpu3/online
echo 1 > /sys/devices/system/cpu/cpu2/online

python3 ./scraper.py
sync

echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1104000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1104000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 0 > /sys/devices/system/cpu/cpu2/online
echo 0 > /sys/devices/system/cpu/cpu3/online

pkill -9 fbdisplay
theme_value=`grep '"theme":' "/mnt/SDCARD/system.json" | sed -e 's/^[^:]*://' -e 's/^[ \t]*//' -e 's/,$//' -e 's/^"//' -e 's/"$//'`
hdmipugin=`cat /sys/class/drm/card0-HDMI-A-1/status`
if [ "$hdmipugin" == "connected" ]; then
   fbdisplay /mnt/SDCARD/miyoo355/app/loading_1080p.png &
else
   if [ "$theme_value" == "./" ]; then
      fbdisplay /mnt/SDCARD/miyoo355/app/loading.png &
   else
      fbdisplay "${theme_value}skin/app_loading_bg.png" &
   fi
fi

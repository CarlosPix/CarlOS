#!/bin/sh
cd $(dirname "$0")
export HOME=/mnt/SDCARD
export PATH="/mnt/SDCARD/miyoo355/bin:${PATH}"
export LD_LIBRARY_PATH="/mnt/SDCARD/miyoo355/lib:${LD_LIBRARY_PATH}"
python3 ./ssh.py
sync

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

#!/bin/sh
cd $(dirname "$0")
GAMEDIR="$(dirname "$0")"

HOME="$GAMEDIR"

cd $HOME
LD_LIBRARY_PATH="$HOME/lib:/mnt/SDCARD/miyoo355/lib:$LD_LIBRARY_PATH"
PATH="$HOME/bin:/mnt/SDCARD/miyoo355/bin:$PATH"

echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1104000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1104000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 0 > /sys/devices/system/cpu/cpu3/online
echo 0 > /sys/devices/system/cpu/cpu2/online
echo dmc_ondemand > /sys/class/devfreq/dmc/governor

if [ ! -f "$HOME"/bin/pico8_64 ]; then
   hdmipugin=`cat /sys/class/drm/card0-HDMI-A-1/status`
   if [ "$hdmipugin" == "connected" ]; then
      fbdisplay /mnt/SDCARD/App/Pico8/warning_1080.png &
   else
      fbdisplay /mnt/SDCARD/App/Pico8/warning.png &
   fi
   sleep 15
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
   exit 0
else
pico8_64 -splore -root_path "/mnt/SDCARD/Roms/PICO8/" 2>&1 | tee $HOME/log.txt

src_dir="/mnt/SDCARD/App/Pico8/.lexaloffle/pico-8/bbs/carts"
dest_dir="/mnt/SDCARD/Roms/PICO8"
img_dir="/mnt/SDCARD/Roms/PICO8/media/images"
database="/mnt/SDCARD/Roms/PICO8/PICO8_cache6.db"

mkdir -p "$dest_dir" "$img_dir"

if [ -f "$database" ]; then
    rm -f "$database"
fi

for file in "$src_dir"/*.p8.png; do
    [ -e "$file" ] || continue

    base=$(basename "$file" .p8.png)
    dest="$dest_dir/$base.p8"
    img="$img_dir/$base.png"

    if [ ! -e "$dest" ]; then
        cp "$file" "$dest"
        cp "$file" "$img"
    fi
done

sync
fi
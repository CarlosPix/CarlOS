#!/bin/sh
cd $(dirname "$0")
GAMEDIR="$(dirname "$0")"

HOME="$GAMEDIR"

cd $HOME
LD_LIBRARY_PATH="$HOME/lib:$LD_LIBRARY_PATH"
PATH="$HOME"/bin:$PATH

echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1104000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1104000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 0 > /sys/devices/system/cpu/cpu3/online
echo 0 > /sys/devices/system/cpu/cpu2/online
echo dmc_ondemand > /sys/class/devfreq/dmc/governor

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

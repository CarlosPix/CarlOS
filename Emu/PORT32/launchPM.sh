#!/bin/bash
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1416000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1416000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 1 > /sys/devices/system/cpu/cpu2/online
echo 1 > /sys/devices/system/cpu/cpu3/online
echo performance > /sys/class/devfreq/dmc/governor

mkdir -p /mnt/SDCARD/Roms/PORTS/root
mount --bind /mnt/SDCARD/Roms/PORTS/root/ /root 

port="$1"

sed -i '
/^if \[\[ \$CFW_NAME == "TheRA" \]\]; then/,/^fi/ c\
raloc="/mnt/SDCARD/RetroArch"\
reconf="/mnt/SDCARD/RetroArch/.config/retroarch/retroarch.cfg"\
export HOME="/mnt/SDCARD/RetroArch"
' "$port"

sed -i 's|\$raloc/retroarch\([[:space:]]\)|\$raloc/retroarch.flip\1|' "$port"

sed -i 's|/\$directory/ports/|\$directory/|g' "$port"
sed -i 's|/\$directory/ports|\$directory/|g' "$port"

sync

export HOME="/mnt/SDCARD/Roms/PORTS"
export controlfolder="/mnt/SDCARD/Roms/PORTS/PortMaster"
export directory="/mnt/SDCARD/Roms/PORTS"
export XDG_DATA_HOME=${HOME}
source "$controlfolder/funcs.txt"

cd "${directory}" && ./"$(basename "$port")"

sync

pkill -9 gptokeyb2
pkill -9 gptokeyb
pkill -9 oga_controls

mount | grep 'squashfs on /tmp/' | awk '{print $3}' | xargs -r -I{} sh -c 'umount -l "{}" || true'
mount | grep 'squashfs on /mnt/sdcard/Roms/PORTS/' | awk '{print $3}' | xargs -r -I{} sh -c 'umount -l "{}" || true'
mount | grep 'on /mnt/sdcard/Roms/PORTS/' | awk '{print $3}' | xargs -r -I{} sh -c 'umount -l "{}" || true'
umount /root
sync

echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1104000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1104000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 0 > /sys/devices/system/cpu/cpu2/online
echo 0 > /sys/devices/system/cpu/cpu3/online
echo dmc_ondemand > /sys/class/devfreq/dmc/governor


unset HOME
unset controlfolder
unset directory
unset XDG_DATA_HOME
unset PATH
unset LD_LIBRARY_PATH
unset LD_PRELOAD

#!/bin/sh
echo $0 $*
progdir=`dirname "$0"`
cd $progdir
export PATH="/mnt/SDCARD/miyoo355/bin:${PATH}"
export LD_LIBRARY_PATH="/mnt/SDCARD/miyoo355/lib:${LD_LIBRARY_PATH}"

echo "=============================================="
echo "==================== PPSSPP  ================="
echo "=============================================="

echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1416000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

export HOME=$progdir
#export SDL_AUDIODRIVER=dsp   //disable 20231031 for sound suspend issue
./PPSSPPSDL "$*"

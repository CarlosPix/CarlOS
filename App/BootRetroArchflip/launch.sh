#!/bin/sh
echo $0 $*
progdir=/mnt/sdcard/Apps/BootRetroArch

echo performance /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1416000 /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 1 > /sys/devices/system/cpu/cpu2/online
echo 1 > /sys/devices/system/cpu/cpu3/online

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$progdir

RA_DIR=/mnt/sdcard/RetroArch
cd $RA_DIR/

$RA_DIR/retroarch.sh -v

echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1104000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 0 > /sys/devices/system/cpu/cpu2/online
echo 0 > /sys/devices/system/cpu/cpu3/online

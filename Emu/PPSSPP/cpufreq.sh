#!/bin/sh

CONFIG_FILE="/userdata/cpuconfig.cfg"
progdir="$(dirname "$0")"

if [ -f "$progdir/cpuconfig.cfg" ]; then
    . "$progdir/cpuconfig.cfg"
elif [ -f /userdata/cpuconfig.cfg ]; then
    . /userdata/cpuconfig.cfg
fi


echo $CPU_GOVERNOR > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo $CPU_MAX > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo $CPU_MIN > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo $CPU_0 > /sys/devices/system/cpu/cpu0/online
echo $CPU_1 > /sys/devices/system/cpu/cpu1/online
echo $CPU_2 > /sys/devices/system/cpu/cpu2/online
echo $CPU_3 > /sys/devices/system/cpu/cpu3/online
echo $GPU_GOVERNOR > /sys/class/devfreq/dmc/governor


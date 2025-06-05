#!/bin/sh
echo $0 $*
progdir=`dirname "$0"`/drastic2
cd $progdir

echo "=============================================="
echo "==================== DRASTIC v1.9============="
echo "=============================================="

echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1416000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 1 > /sys/devices/system/cpu/cpu2/online
echo 1 > /sys/devices/system/cpu/cpu3/online

mkdir -p ./cheats
mkdir -p ./input_record
mkdir -p ./mnt
mkdir -p ./profiles
mkdir -p ./savestates
mkdir -p ./scripts
mkdir -p ./slot2

./launch.sh "$1"

echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1104000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 0 > /sys/devices/system/cpu/cpu2/online
echo 0 > /sys/devices/system/cpu/cpu3/online

#!/bin/sh
echo $0 $*
progdir=`dirname "$0"`
cd $progdir
export PATH="/mnt/SDCARD/miyoo355/bin:${PATH}"
export LD_LIBRARY_PATH="/mnt/SDCARD/miyoo355/lib:$progdir:${LD_LIBRARY_PATH}"

#echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
#swapon /mnt/SDCARD/App/swap/swap.img
./OpenBOR "$1"
#swapoff /mnt/SDCARD/App/swap/swap.img

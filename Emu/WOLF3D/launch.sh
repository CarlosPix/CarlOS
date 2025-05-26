#!/bin/sh
echo $0 $*
progdir=`dirname "$0"`
export PATH="/mnt/SDCARD/miyoo355/bin:${PATH}"
export LD_LIBRARY_PATH="/mnt/SDCARD/miyoo355/lib:${LD_LIBRARY_PATH}"

RA_DIR=$progdir/../../RetroArch
EMU_DIR=$progdir


$EMU_DIR/cpufreq.sh


cd $RA_DIR/

#disable netplay
NET_PARAM=

HOME=$RA_DIR/ $RA_DIR/retroarch.flip -v $NET_PARAM -L $RA_DIR/.config/retroarch/cores/ecwolf_libretro.so "$*"



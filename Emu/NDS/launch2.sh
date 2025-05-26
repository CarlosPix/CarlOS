#!/bin/sh
echo $0 $*
progdir=`dirname "$0"`/drastic
cd $progdir
export PATH="/mnt/SDCARD/miyoo355/bin:${PATH}"
export LD_LIBRARY_PATH="$progdir/lib:/mnt/SDCARD/miyoo355/lib:${LD_LIBRARY_PATH}"

echo "=============================================="
echo "==================== DRASTIC  ================="
echo "=============================================="

../cpufreq.sh

export HOME=/mnt/SDCARD
#export SDL_AUDIODRIVER=dsp
./drastic "$*"


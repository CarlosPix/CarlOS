#!/bin/sh
progdir=`dirname "$0"`
export LD_LIBRARY_PATH="$progdir:${LD_LIBRARY_PATH}"

RA_DIR=$progdir/../../RetroArch
EMU_DIR=$progdir

cd $RA_DIR/

$EMU_DIR/cpufreq.sh

HOME=$RA_DIR/ $RA_DIR/ra64.miyoo -L $EMU_DIR/ffmpeg_libretro.so "$*"

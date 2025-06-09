#!/bin/sh
cd $(dirname "$0")
export HOME=/mnt/SDCARD
export PATH="/mnt/SDCARD/miyoo355/bin:${PATH}"
export LD_LIBRARY_PATH="/mnt/SDCARD/miyoo355/lib:${LD_LIBRARY_PATH}"
python3 ./configurator.py >> cpu.log 2>&1
sync

fbdisplay /mnt/sdcard/miyoo355/app/loading.png &

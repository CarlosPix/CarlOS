#!/bin/sh
cd $(dirname "$0")
export HOME=/mnt/SDCARD
export PATH="/mnt/SDCARD/miyoo355/bin:${PATH}"
export LD_LIBRARY_PATH="/mnt/SDCARD/miyoo355/lib:${LD_LIBRARY_PATH}"
python3 ./ssh.py
sync

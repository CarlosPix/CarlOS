#!/bin/bash

killall -9 keymon
killall -9 btmanager
killall -9 hardwareservice
killall -9 miyoo_inputd

umount -l /media/sdcard1

if [ -b /dev/mmcblk1p1 ]; then
    umount -l /media/sdcard0
fi

mount -t vfat /dev/mmcblk2p1 /media/sdcard0

if [ -b /dev/mmcblk1p1 ]; then
    mount -t vfat /dev/mmcblk1p1 /media/sdcard1
fi

/mnt/SDCARD/miyoo355/app/MainUI &
exit
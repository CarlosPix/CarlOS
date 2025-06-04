#!/bin/bash

/etc/init.d/S60mainui stop
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

sleep 0.5
sync

export PATH="/mnt/SDCARD/miyoo355/bin:/usr/miyoo/bin:/usr/bin:/usr/sbin"
export LD_LIBRARY_PATH="/mnt/SDCARD/miyoo355/lib:/usr/miyoo/lib:/usr/lib"

/etc/init.d/S60mainui start
sync
sleep 0.5
exit 0


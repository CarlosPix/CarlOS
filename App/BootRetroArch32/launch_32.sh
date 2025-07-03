#!/bin/bash

MAINSDROOT="$(dirname $0)/../.."
ROMROOT="$(dirname $1)/../.."
ROMNAME="$1"
BASEROMNAME=${ROMNAME##*/}
ROMNAMETMP=${BASEROMNAME%.*}
$(dirname "$0")/cpufreq.sh
    cd $MAINSDROOT/Emu/PORT32
    mkdir -p ./mnt
    mount -t squashfs miyoo355_rootfs_32.img mnt
    mount --bind /sys mnt/sys
    mount --bind /dev mnt/dev
    mount --bind /proc mnt/proc
    mount --bind /var/run mnt/var/run
    mount --bind "$MAINSDROOT/" mnt/sdcard
    mount --bind "$MAINSDROOT/../sdcard1" mnt/media/sdcard1
    mount --bind "$MAINSDROOT/BIOS" mnt/sdcard/RetroArch32/.config/retroarch/system
    mount --bind "$MAINSDROOT/RetroArch/.config/retroarch/shaders" mnt/sdcard/RetroArch32/.config/retroarch/shaders
    mount --bind "$MAINSDROOT/Savefiles" mnt/sdcard/RetroArch32/.config/retroarch/saves
    mount --bind "$MAINSDROOT/Savestates" mnt/sdcard/RetroArch32/.config/retroarch/states
    mount --bind "$MAINSDROOT/Screenshots" mnt/sdcard/RetroArch32/.config/retroarch/screenshots
    mount --bind "$MAINSDROOT/RetroArch/.config/retroarch/assets" mnt/sdcard/RetroArch32/.config/retroarch/assets
    mount --bind "$MAINSDROOT/RetroArch/.config/retroarch/cheats" mnt/sdcard/RetroArch32/.config/retroarch/cheats
    mount --bind "$MAINSDROOT/RetroArch/.config/retroarch/autoconfig" mnt/sdcard/RetroArch32/.config/retroarch/autoconfig
    chroot mnt /bin/sh -c "/mnt/sdcard/App/BootRetroArch32/run '$1'"
    umount mnt/sdcard/RetroArch32/.config/retroarch/system
    umount mnt/sdcard/RetroArch32/.config/retroarch/shaders
    umount mnt/sdcard/RetroArch32/.config/retroarch/saves
    umount mnt/sdcard/RetroArch32/.config/retroarch/states
    umount mnt/sdcard/RetroArch32/.config/retroarch/screenshots
    umount mnt/sdcard/RetroArch32/.config/retroarch/assets
    umount mnt/sdcard/RetroArch32/.config/retroarch/cheats
    umount mnt/sdcard/RetroArch32/.config/retroarch/autoconfig
    umount mnt/sdcard/
    umount mnt/media/sdcard1
    umount mnt/var/run
    umount mnt/proc
    umount mnt/sys
    umount mnt/dev
    umount mnt

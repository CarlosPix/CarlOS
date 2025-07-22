#!/bin/sh
MAINSDROOT="$(dirname $0)/../.."
ROMROOT="$(dirname $1)/../.."
ROMNAME="$1"
BASEROMNAME=${ROMNAME##*/}
ROMNAMETMP=${BASEROMNAME%.*}
ROMPATH=${ROMNAME%.*}

export HOME="/mnt/SDCARD/Roms/PORTS"

get_connected_audio_bt_mac() {
    if ! pgrep -x bluetoothd > /dev/null; then
        return 1
    fi    for mac in $(bluetoothctl devices | awk '{print $2}'); do
        if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
            name=$(bluetoothctl info "$mac" | grep "Name" | cut -d ' ' -f2-)
            icon=$(bluetoothctl info "$mac" | grep "Icon" | awk '{print $2}')
            if echo "$name" | grep -iqE "headset|speaker|audio|earbud|headphone"; then
                echo "$mac"
                return 0
            fi
            if [[ "$icon" == "audio-headset" || "$icon" == "audio-card" || "$icon" == "audio-headphones" ]]; then
                echo "$mac"
                return 0
            fi
        fi
    done
    return 1
}

mac=$(get_connected_audio_bt_mac)
ASOUND_CONF="$HOME/.asoundrc"

if [ -n "$mac" ]; then
    cat > "$ASOUND_CONF" <<EOF
pcm.!default {
    type plug
    slave.pcm {
        type bluealsa
        device "$mac"
        profile "a2dp"
        delay 64
    }
}
ctl.!default {
    type hw
    card 0
}
EOF
else
    if [ -f "$ASOUND_CONF" ]; then
        rm "$ASOUND_CONF"
    fi
fi

    cd $(dirname $0)
	mkdir -p /mnt/SDCARD/Emu/PORT32/mnt
    mount -t squashfs miyoo355_rootfs_32.img mnt
    mount --bind /sys mnt/sys
    mount --bind /dev mnt/dev
    mount --bind /proc mnt/proc
    mount --bind /var/run mnt/var/run
    mount --bind "$MAINSDROOT/" mnt/sdcard
    if [[ "$ROMNAME" == *"sdcard1"* ]]; then
    mount --bind "$ROMROOT" mnt/media/sdcard1
    fi
    chroot mnt /bin/sh -c "${ROMNAME}"
    umount mnt/sdcard
    umount mnt/media/sdcard1
    umount mnt/var/run
    umount mnt/proc
    umount mnt/sys
    umount mnt/dev
    umount mnt

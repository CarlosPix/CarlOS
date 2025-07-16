#!/bin/sh
MYDIR=`dirname "$0"`
MYFS=$MYDIR/tmp

export HOME=$MYDIR
export SDL_VIDEODRIVER=NDS
export LD_LIBRARY_PATH=$MYDIR/lib:$LD_LIBRARY_PATH

get_connected_audio_bt_mac() {
    for mac in $(bluetoothctl devices | awk '{print $2}'); do
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
    }
}
EOF
else
    if [ -f "$ASOUND_CONF" ]; then
        rm "$ASOUND_CONF"
    fi
fi

sv=`cat /proc/sys/vm/swappiness`
echo 10 > /proc/sys/vm/swappiness
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

if [ ! -d /usr/lib32 ]; then
    mkdir -p $MYFS
    mount -o loop $MYDIR/overlayfs.img $MYFS
    mount -t overlay overlay -o ro,lowerdir=/usr,upperdir=$MYFS/usr/upper,workdir=$MYFS/usr/work $MYFS/usr/merged_usr
    mount --bind $MYFS/usr/merged_usr /usr
fi

export ALSA_PLUGIN_PATH=/usr/lib32/alsa-lib

cd $MYDIR
./drastic "$1" > std.log 2>&1
sync

echo $sv > /proc/sys/vm/swappiness
echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

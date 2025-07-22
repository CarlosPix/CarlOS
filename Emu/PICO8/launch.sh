#!/bin/sh
echo $0 $*
progdir=`dirname "$0"`
export PATH="/mnt/SDCARD/miyoo355/bin:${PATH}"
export LD_LIBRARY_PATH="/mnt/SDCARD/miyoo355/lib:${LD_LIBRARY_PATH}"
export rompath="$1"
export filename=$(basename "$rompath")
RA_DIR=$progdir/../../RetroArch
EMU_DIR=$progdir
HOME=$RA_DIR/

get_connected_audio_bt_mac() {
    if ! pgrep -x bluetoothd > /dev/null; then
        return 1
    fi
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

$EMU_DIR/cpufreq.sh

#disable netplay
NET_PARAM=

if [ "${filename##*.}" = "png" ]; then
    new_rompath="${rompath%.png}"  # Elimina .png
    rompath="$new_rompath"
fi

# Ejecutar con Fake08 en RetroArch
cd "$RA_DIR"
"$RA_DIR/retroarch.flip" -v -L "$RA_DIR/.config/retroarch/cores/fake08_libretro.so" "$rompath"
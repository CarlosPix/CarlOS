#!/bin/sh
echo $0 $*
EMU_DIR=/mnt/SDCARD/Emu/SS

#$EMU_DIR/cpuswitch.sh
$EMU_DIR/performance.sh

cd $EMU_DIR
export LD_LIBRARY_PATH=$EMU_DIR/lib:$LD_LIBRARY_PATH
export HOME="$EMU_DIR"

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

    BIOS_FILE="$EMU_DIR/saturn_bios.bin"

./gptokeyb -k "yabasanshiro" -c "keys.gptk" &
./yabasanshiro -r 3 -i "$@" -b "$BIOS_FILE" 2>log.txt
$ESUDO kill -9 $(pidof gptokeyb)

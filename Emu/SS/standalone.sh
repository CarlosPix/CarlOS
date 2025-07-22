#!/bin/sh
echo $0 $*
EMU_DIR=/mnt/SDCARD/Emu/SS

$EMU_DIR/performance.sh

cd $EMU_DIR
export HOME="$EMU_DIR"

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

if grep -i "dowork 0x" "/tmp/log/messages" | tail -n 1 | grep -iq "(HLE BIOS)"; then
    BIOS_FILE=""
    echo "Using Yabasanshiro HLE BIOS"
else
    BIOS_FILE="/mnt/SDCARD/RetroArch/.config/retroarch/system/saturn_bios.bin"
    if [ ! -f "$BIOS_FILE" ]; then
        echo "BIOS file not found, falling back to HLE BIOS"
    else
        echo "Using real Saturn BIOS"
    fi
fi

#./gptokeyb "yabasanshiro" -c "keys.gptk" -k yabasanshiro &
./yabasanshiro -r 3 -i "$@" -b "$BIOS_FILE"
$ESUDO kill -9 $(pidof gptokeyb)

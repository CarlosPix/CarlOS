#!/bin/sh
echo $0 $*
progdir=`dirname "$0"`
GAMEDIR=$progdir/FFPLAY

HOME=$GAMEDIR/

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

cd $GAMEDIR

if [ -f "/storage/.config/SDL-GameControllerDB/gamecontrollerdb.txt" ]; then

export SDL_GAMECONTROLLERCONFIG_FILE="/storage/.config/SDL-GameControllerDB/gamecontrollerdb.txt"
./gptokeyb -k "ffplay" -c "$GAMEDIR/ffplay.gptk" &
HOME=./ LD_LIBRARY_PATH="lib:$LD_LIBRARY_PATH" $GAMEDIR/ffplay -fs -autoexit -codec:v h264_rkmpp -i "$1"
kill -9 $(pidof gptokeyb)
else

export SDL_GAMECONTROLLERCONFIG_FILE="../../../App/PortMaster/gamecontrollerdb.txt"
./gptokeyb -k "ffplay" -c "$GAMEDIR/ffplay.gptk" &
HOME=./ LD_LIBRARY_PATH="lib:$LD_LIBRARY_PATH" SDL_GAMECONTROLLERCONFIG_FILE="/opt/inttools/gamecontrollerdb.txt" $GAMEDIR/ffplay -fs -autoexit -codec:v h264_rkmpp -i "$1"
kill -9 $(pidof gptokeyb)
fi
kill -9 $(pidof gptokeyb)

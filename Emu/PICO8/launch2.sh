#!/bin/sh

EMU_DIR="/mnt/SDCARD/Emu/PICO8"
GAMEDIR="/mnt/SDCARD/App/Pico8"

#$EMU_DIR/cpufreq.sh
#$EMU_DIR/cpuswitch1.sh

HOME="$GAMEDIR"

cd $HOME

LD_LIBRARY_PATH="$HOME/lib2:/mnt/SDCARD/miyoo355/lib:$LD_LIBRARY_PATH"
PATH="$HOME/bin:/mnt/SDCARD/miyoo355/bin:$PATH"

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

echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1104000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1104000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 0 > /sys/devices/system/cpu/cpu3/online
echo 0 > /sys/devices/system/cpu/cpu2/online
echo dmc_ondemand > /sys/class/devfreq/dmc/governor

if [ ! -f "$HOME"/bin/pico8_64 ]; then
   hdmipugin=`cat /sys/class/drm/card0-HDMI-A-1/status`
   if [ "$hdmipugin" == "connected" ]; then
      fbdisplay /mnt/SDCARD/App/Pico8/warning_1080.png &
   else
      fbdisplay /mnt/SDCARD/App/Pico8/warning.png &
   fi
   sleep 15
   pkill -9 fbdisplay
   theme_value=`grep '"theme":' "/mnt/SDCARD/system.json" | sed -e 's/^[^:]*://' -e 's/^[ \t]*//' -e 's/,$//' -e 's/^"//' -e 's/"$//'`
   hdmipugin=`cat /sys/class/drm/card0-HDMI-A-1/status`
   if [ "$hdmipugin" == "connected" ]; then
       fbdisplay /mnt/SDCARD/miyoo355/app/loading_1080p.png &
   else
       if [ "$theme_value" == "./" ]; then
         fbdisplay /mnt/SDCARD/miyoo355/app/loading.png &
       else
         fbdisplay "${theme_value}skin/app_loading_bg.png" &
       fi
   fi
   exit 0
else
resolution=$(fbset | grep 'geometry' | awk '{print $2,$3}')
width=$(echo $resolution | awk '{print $1}')
height=$(echo $resolution | awk '{print $2}')

draw_rect="-draw_rect 0,0,${width},${height}"

pico8_64 $draw_rect -run "$1" 2>&1 | tee $HOME/log.txt
fi
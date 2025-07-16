#!/bin/bash
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1416000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1416000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 1 > /sys/devices/system/cpu/cpu2/online
echo 1 > /sys/devices/system/cpu/cpu3/online
echo performance > /sys/class/devfreq/dmc/governor

mkdir -p /mnt/SDCARD/Roms/PORTS/root
mount --bind /mnt/SDCARD/Roms/PORTS/root/ /root 

port="$1"

sed -i '
/^if \[\[ \$CFW_NAME == "TheRA" \]\]; then/,/^fi/ c\
raloc="/mnt/SDCARD/RetroArch"\
reconf="/mnt/SDCARD/RetroArch/.config/retroarch/retroarch.cfg"\
export HOME="/mnt/SDCARD/RetroArch"
' "$port"

sed -i 's|\$raloc/retroarch\([[:space:]]\)|\$raloc/retroarch.flip\1|' "$port"

sed -i 's|/\$directory/ports/|\$directory/|g' "$port"
sed -i 's|/\$directory/ports|\$directory/|g' "$port"

sed -i 's/\[\[ "\$CFW_NAME" =~ \^ArkOS\.\* \]\] \&\& cp "\${GAMEDIR}\/asoundrc" "\${HOME}\/\.asoundrc"/\[\[ "\$CFW_NAME" =~ \^Miyoo\* \]\] \&\& cp "\${GAMEDIR}\/asoundrc" "\${HOME}\/\.asoundrc"/' "$port"

sync

export HOME="/mnt/SDCARD/Roms/PORTS"
export controlfolder="/mnt/SDCARD/Roms/PORTS/PortMaster"
export directory="/mnt/SDCARD/Roms/PORTS"
export XDG_DATA_HOME=${HOME}
source "$controlfolder/funcs.txt"

ASOUND_CONF="$HOME/.asoundrc"

get_connected_audio_bt_mac() {
    for mac in $(bluetoothctl devices | awk '{print $2}'); do
        info=$(bluetoothctl info "$mac")
        if echo "$info" | grep -q "Connected: yes"; then
            name=$(echo "$info" | grep "Name" | head -n1 | cut -d ' ' -f2-)
            icon=$(echo "$info" | grep "Icon" | awk '{print $2}')
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

ctl.!default { type hw card 0 }
EOF
else
    cat > "$ASOUND_CONF" <<EOF
pcm.!default {
    type plug
    slave.pcm "dmixer"
}

pcm.dmixer  {
    type dmix
    ipc_key 1024
    slave {
        pcm "hw:0,0"
        period_time 0
        period_size 1024
        buffer_size 4096
        rate 44100
    }
    bindings {
        0 0
        1 1
    }
}

ctl.!default { type hw card 0 }
EOF
fi

cd "${directory}" && ./"$(basename "$port")"

sync

pkill -9 gptokeyb2
pkill -9 gptokeyb
pkill -9 oga_controls

mount | grep 'squashfs on /tmp/' | awk '{print $3}' | xargs -r -I{} sh -c 'umount -l "{}" || true'
mount | grep 'squashfs on /mnt/sdcard/Roms/PORTS/' | awk '{print $3}' | xargs -r -I{} sh -c 'umount -l "{}" || true'
mount | grep 'on /mnt/sdcard/Roms/PORTS/' | awk '{print $3}' | xargs -r -I{} sh -c 'umount -l "{}" || true'
umount /root
sync

echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1104000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1104000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 0 > /sys/devices/system/cpu/cpu2/online
echo 0 > /sys/devices/system/cpu/cpu3/online
echo dmc_ondemand > /sys/class/devfreq/dmc/governor


unset HOME
unset controlfolder
unset directory
unset XDG_DATA_HOME
unset PATH
unset LD_LIBRARY_PATH
unset LD_PRELOAD

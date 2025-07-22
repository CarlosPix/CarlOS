#!/bin/sh

progdir=$(dirname "$0")
export PATH="/mnt/SDCARD/miyoo355/bin:${PATH}"
export LD_LIBRARY_PATH="/mnt/SDCARD/miyoo355/lib:${LD_LIBRARY_PATH}"
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

cd $RA_DIR/

$EMU_DIR/cpufreq.sh

ROM_PATH="$1"
ROM_NAME=$(basename "$ROM_PATH")

# Core por defecto
CORE_NAME="snes9x"

# Limpiar cualquier carácter extraño (como CR) en el nombre del ROM
ROM_NAME_CLEANED=$(echo "$ROM_NAME" | tr -d '\r')

# Mapeo de ROMs a cores
declare -A ROM_CORES

ROM_CORES["Marvelous.7z"]="snes9x2010"
ROM_CORES["Virtual Bart.7z"]="snes9x2002"
ROM_CORES["Super Ghouls'n Ghosts.7z"]="snes9x2002"
ROM_CORES["Kirby's Dream Land 3.7z"]="snes9x2010"
ROM_CORES["SMW 2 - Yoshi's Island - Kamek's Revenge [HACK].7z"]="snes9x2010"
ROM_CORES["Super Mario World 2 - Yoshi's Island 2+2 [HACK].7z"]="snes9x2010"
ROM_CORES["Super Mario World 2 - Yoshi's Island 2+[HACK].7z"]="snes9x2010"
ROM_CORES["Super Mario World 2 - Yoshi's Island.7z"]="snes9x2010"
ROM_CORES["Super Mario World 30TH Aniversary Edition.7z"]="mednafen_supafaust"

# Verificar si el ROM está en el mapeo
if [[ -n "${ROM_CORES[$ROM_NAME_CLEANED]}" ]]; then
  CORE_NAME="${ROM_CORES[$ROM_NAME_CLEANED]}"
  echo "Core seleccionado para $ROM_NAME_CLEANED: $CORE_NAME"
else
  echo "No se encontró el ROM en el listado. Usando core por defecto: $CORE_NAME"
fi

CORE_LIB="${CORE_NAME}_libretro.so"

$RA_DIR/retroarch.flip -v -L $RA_DIR/.config/retroarch/cores/$CORE_LIB "$ROM_PATH"

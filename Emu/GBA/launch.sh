#!/bin/sh

progdir=$(dirname "$0")
export PATH="/mnt/SDCARD/miyoo355/bin:${PATH}"
export LD_LIBRARY_PATH="/mnt/SDCARD/miyoo355/lib:${LD_LIBRARY_PATH}"

RA_DIR=$progdir/../../RetroArch
EMU_DIR=$progdir

cd "$RA_DIR"

$EMU_DIR/cpufreq.sh

ROM_PATH="$1"
ROM_NAME=$(basename "$ROM_PATH")

# Core por defecto
CORE_NAME="mgba"

# Limpiar cualquier carácter extraño (como CR) en el nombre del ROM
ROM_NAME_CLEANED=$(echo "$ROM_NAME" | tr -d '\r')

# Mapeo de ROMs a cores
declare -A ROM_CORES

ROM_CORES["Pokemon Hoenn Adventures.7z"]="gpsp"
ROM_CORES["Hamtaro - Ham-Ham Heartbreak.7z"]="vba_next"
ROM_CORES["Watman.7z"]="gpsp"
ROM_CORES["Kururin Paradise.7z"]="gpsp"
ROM_CORES["Pokemon Lets Go Pikachu.7z"]="gpsp"
ROM_CORES["WarioWare Twisted.7z"]="vba_next"
ROM_CORES["Yoshis Universal Gravitation.7z"]="vba_next"
ROM_CORES["Pokemon Brillo Purpura.7z"]="gpsp"
ROM_CORES["Pokemon Espada y Escudo.7z"]="vbam"
ROM_CORES["Pokemon Lets Go Eevee.7z"]="gpsp"


# Verificar si el ROM está en el mapeo
if [[ -n "${ROM_CORES[$ROM_NAME_CLEANED]}" ]]; then
  CORE_NAME="${ROM_CORES[$ROM_NAME_CLEANED]}"
  echo "Core seleccionado para $ROM_NAME_CLEANED: $CORE_NAME"
else
  echo "No se encontró el ROM en el listado. Usando core por defecto: $CORE_NAME"
fi

CORE_LIB="${CORE_NAME}_libretro.so"

HOME=$RA_DIR/ $RA_DIR/retroarch.flip -v -L $RA_DIR/.config/retroarch/cores/$CORE_LIB "$ROM_PATH"

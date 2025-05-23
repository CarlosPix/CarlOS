#!/bin/sh

progdir=$(dirname "$0")
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$progdir

RA_DIR=$progdir/../../RetroArch
EMU_DIR=$progdir

cd "$RA_DIR"

$EMU_DIR/cpuswitch.sh
$EMU_DIR/cpufreq.sh

ROM_PATH="$1"
ROM_NAME=$(basename "$ROM_PATH")

# Core por defecto
CORE_NAME="fbalpha2012_cps1"

# Limpiar cualquier carácter extraño (como CR) en el nombre del ROM
ROM_NAME_CLEANED=$(echo "$ROM_NAME" | tr -d '\r')

# Mapeo de ROMs a cores
declare -A ROM_CORES

ROM_CORES["forgottn.zip"]="fbneo"


# Verificar si el ROM está en el mapeo
if [[ -n "${ROM_CORES[$ROM_NAME_CLEANED]}" ]]; then
  CORE_NAME="${ROM_CORES[$ROM_NAME_CLEANED]}"
  echo "Core seleccionado para $ROM_NAME_CLEANED: $CORE_NAME"
else
  echo "No se encontró el ROM en el listado. Usando core por defecto: $CORE_NAME"
fi

CORE_LIB="${CORE_NAME}_libretro.so"

HOME=$RA_DIR/ $RA_DIR/retroarch.flip -v -L $RA_DIR/.config/retroarch/cores/$CORE_LIB "$ROM_PATH"

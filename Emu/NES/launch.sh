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
CORE_NAME="nestopia"

# Limpiar cualquier carácter extraño (como CR) en el nombre del ROM
ROM_NAME_CLEANED=$(echo "$ROM_NAME" | tr -d '\r')

# Mapeo de ROMs a cores
declare -A ROM_CORES

ROM_CORES["Startropics.7z"]="fceumm"
ROM_CORES["Kirby's Adventure.7z"]="fceumm"
ROM_CORES["Kid Dracula.7z"]="quicknes"
ROM_CORES["Elite.7z"]="nestopia"
ROM_CORES["TurboRacing.7z"]="nestopia"
ROM_CORES["Little Nemo - The Dream Master.7z"]="fceumm"
ROM_CORES["Contra.7z"]="fceumm"
ROM_CORES["Akumajou Densetsu.7z"]="fceumm"
ROM_CORES["Getsu Fuuma Den.7z"]="fceumm"
ROM_CORES["B-Wings.7z"]="fceumm"
ROM_CORES["Bee 52.7z"]="quicknes"
ROM_CORES["Blaster Master.7z"]="fceumm"
ROM_CORES["Crisis Force.7z"]="fceumm"
ROM_CORES["Double Dragon II - The Revenge.7z"]="fceumm"
ROM_CORES["Dragon Ball - Shenron no Nazo.7z"]="fceumm"
ROM_CORES["Dragon Ball Z - Assault of the Saiyans.7z"]="fceumm"
ROM_CORES["Dragon warrior 4.7z"]="fceumm"
ROM_CORES["Ganbare Goemon 2.7z"]="fceumm"
ROM_CORES["Ganbare Goemon Gaiden.7z"]="fceumm"
ROM_CORES["Ghostbusters.7z"]="quicknes"
ROM_CORES["Gradius II.7z"]="fceumm"
ROM_CORES["Gryzor.7z"]="fceumm"
ROM_CORES["Guerrilla War.7z"]="fceumm"
ROM_CORES["Ikari 3 - The Rescue.7z"]="fceumm"
ROM_CORES["Ikari Warriors II - Victory Road.7z"]="fceumm"
ROM_CORES["Knight Rider.7z"]="fceumm"
ROM_CORES["Mega Man.7z"]="fceumm"
ROM_CORES["Mega Man 4.7z"]="fceumm"
ROM_CORES["Mega Man 5.7z"]="fceumm"
ROM_CORES["Mega Man 5 - Protoman Edition Second Strike [HACK].7z"]="fceumm"
ROM_CORES["Mega Man 5 - Protoman Edition First Strike [HACK].7z"]="fceumm"
ROM_CORES["Mega Man 6.7z"]="fceumm"
ROM_CORES["Metroid.7z"]="fceumm"
ROM_CORES["Mission Cobra.7z"]="fceumm"
ROM_CORES["NARC.7z"]="fceumm"
ROM_CORES["Nintendo World Cup.7z"]="fceumm"
ROM_CORES["Paperboy 2.7z"]="fceumm"
ROM_CORES["Parodius.7z"]="quicknes"
ROM_CORES["RC Pro-Am II.7z"]="quicknes"
ROM_CORES["RoboCop vs The Terminator.7z"]="fceumm"
ROM_CORES["Son Son.7z"]="fceumm"
ROM_CORES["StarTropics.7z"]="fceumm"
ROM_CORES["Super Pitfall.7z"]="fceumm"
ROM_CORES["Super Spy Hunter.7z"]="fceumm"
ROM_CORES["Vice - Project Doom.7z"]="fceumm"
ROM_CORES["Wacky Races.7z"]="fceumm"
ROM_CORES["Wai Wai World 2 - SOS!! Paseri Jou.7z"]="quicknes"
ROM_CORES["Werewolf - The Last Warrior.7z"]="fceumm"
ROM_CORES["Xevious.7z"]="fceumm"
ROM_CORES["Zen Intergalactic Ninja.7z"]="fceumm"
ROM_CORES["Famicom Grand Prix II - 3D Hot Rally.7z"]="fceumm"
ROM_CORES["Aliens - Alien 2.7z"]="fceumm"
ROM_CORES["Megaman 1-The New Lands Remastered.7z"]="fceumm"
ROM_CORES["Startropics.7z"]="fceumm"
ROM_CORES["Celeste Mario Zap & Dash!.7z"]="fceumm"
ROM_CORES["Full Quiet.7z"]="fceumm"
ROM_CORES["Basse Def Adventures.7z"]="fceumm"
ROM_CORES["Bobby Six Seven.7z"]="fceumm"
ROM_CORES["Courier.7z"]="fceumm"
ROM_CORES["SD Gundam Gaiden - Knight Gundam Monogatari.7z"]="fceumm"



# Verificar si el ROM está en el mapeo
if [[ -n "${ROM_CORES[$ROM_NAME_CLEANED]}" ]]; then
  CORE_NAME="${ROM_CORES[$ROM_NAME_CLEANED]}"
  echo "Core seleccionado para $ROM_NAME_CLEANED: $CORE_NAME"
else
  echo "No se encontró el ROM en el listado. Usando core por defecto: $CORE_NAME"
fi

CORE_LIB="${CORE_NAME}_libretro.so"

HOME=$RA_DIR/ $RA_DIR/retroarch.flip -v -L $RA_DIR/.config/retroarch/cores/$CORE_LIB "$ROM_PATH"

#!/bin/sh
echo $0 $*
progdir=`dirname "$0"`
export PATH="/mnt/SDCARD/miyoo355/bin:${PATH}"
export LD_LIBRARY_PATH="/mnt/SDCARD/miyoo355/lib:${LD_LIBRARY_PATH}"
picodir=/mnt/SDCARD/App/PICO8
export rompath="$1"
export filename=$(basename "$rompath")

RA_DIR=$progdir/../../RetroArch
EMU_DIR=$progdir

cd $picodir
    if [ "$filename" = "~Run PICO-8 with Splore.p8" ]; then
      ./launch.sh
    fi

$EMU_DIR/cpufreq.sh

cd $RA_DIR/

#disable netplay
NET_PARAM=

HOME=$RA_DIR/ $RA_DIR/retroarch.flip -v $NET_PARAM -L $RA_DIR/.config/retroarch/cores/fake08_libretro.so "$*"
        tar el .png para que Fake08 lo reconozca
if [ "${filename##*.}" = "png" ]; then
    new_rompath="${rompath%.png}"  # Elimina .png
    rompath="$new_rompath"
fi

# Ajustar frecuencia de CPU (si es necesario)
"$EMU_DIR/cpufreq.sh"

# Ejecutar con Fake08 en RetroArch
cd "$RA_DIR"
HOME="$RA_DIR" "$RA_DIR/retroarch.flip" -v -L "$RA_DIR/.config/retroarch/cores/fake08_libretro.so" "$rompath"
#!/bin/bash

export HOME=/mnt/SDCARD
export PATH="/mnt/SDCARD/miyoo355/bin:${PATH}"
export LD_LIBRARY_PATH="/mnt/SDCARD/miyoo355/lib:${LD_LIBRARY_PATH}"
fbdisplay /mnt/SDCARD/App/arcadegames/working.png &

ALIAS_FILE="/mnt/SDCARD/App/arcadegames/alias.txt"
ROMS_ROOT="/mnt/SDCARD/Roms"

valid_systems=("ARCADE" "MAME" "NEOGEO" "NEOCD" "FBNEO" "CPS1" "CPS2" "CPS3" "ATOMIS" "PGM2" "NAOMI")

find "$ROMS_ROOT" -mindepth 1 -maxdepth 1 -type d | while read -r SUBDIR; do
    system=$(basename "$SUBDIR")
    
    if [[ " ${valid_systems[@]} " =~ " $system " ]]; then
        CACHE_FILE="$SUBDIR/${system}_cache6.db"
        [ -f "$CACHE_FILE" ] && rm -f "$CACHE_FILE"

        OUTPUT="$SUBDIR/gamelist.xml"
        echo '<?xml version="1.0" encoding="UTF-8"?>' > "$OUTPUT"
        echo '<gameList>' >> "$OUTPUT"

        find "$SUBDIR" -maxdepth 1 -type f \( -iname "*.zip" -o -iname "*.7z" \) | while read -r ROM; do
            BASENAME=$(basename "$ROM")
            BASENAME_NOEXT="${BASENAME%.*}"

            AMIGABLE=$(grep -m1 "^$BASENAME_NOEXT=" "$ALIAS_FILE" | cut -d'=' -f2- | sed 's/^ //')
            [ -z "$AMIGABLE" ] && AMIGABLE="$BASENAME_NOEXT"

            IMAGE_PATH="./Imgs/${BASENAME_NOEXT}.png"

            echo "  <game>" >> "$OUTPUT"
            echo "    <path>$BASENAME</path>" >> "$OUTPUT"
            echo "    <name>$AMIGABLE</name>" >> "$OUTPUT"
            echo "    <image>$IMAGE_PATH</image>" >> "$OUTPUT"
            echo "  </game>" >> "$OUTPUT"
        done

        echo '</gameList>' >> "$OUTPUT"
        echo "Generado: $OUTPUT"
    else
        echo "Omitido: $SUBDIR (sistema no permitido)"
    fi
done

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

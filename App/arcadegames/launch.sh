#!/bin/bash

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

            IMAGE_PATH="./media/images/${BASENAME_NOEXT}.png"

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

/mnt/SDCARD/miyoo355/bin/pkill -9 fbdisplay
hdmipugin=`cat /sys/class/drm/card0-HDMI-A-1/status`
if [ "$hdmipugin" == "connected" ] ; then
  /mnt/SDCARD/miyoo355/bin/fbdisplay /mnt/SDCARD/miyoo355/app/loading_1080p.png &
else
  /mnt/SDCARD/miyoo355/bin/fbdisplay /mnt/SDCARD/miyoo355/app/loading.png &
fi

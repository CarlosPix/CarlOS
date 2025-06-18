#!/bin/bash
export HOME=/mnt/SDCARD/Roms/PORTS
export PYSDL2_DLL_PATH=/mnt/SDCARD/App/PortMaster/lib
export PATH="/mnt/SDCARD/miyoo355/bin:$PATH"
export LD_LIBRARY_PATH="/mnt/SDCARD/miyoo355/lib:$LD_LIBRARY_PATH"

SH_FILE="/mnt/SDCARD/Roms/PORTS/PortMaster/PortMaster.sh"
SH_FILE_MIYOO="/mnt/SDCARD/Roms/PORTS/PortMaster/miyoo/PortMaster.txt"
DIALOG_FILE="/mnt/SDCARD/Roms/PORTS/PortMaster/PortMasterDialog.txt"
CONTROL_FILE="/mnt/SDCARD/Roms/PORTS/PortMaster/control.txt"
CONTROL_FILE_MIYOO="/mnt/SDCARD/Roms/PORTS/PortMaster/miyoo/control.txt"
CONTROL_FILE_ROOT="/mnt/SDCARD/Roms/PORTS/root/home/.local/share/PortMaster/control.txt"
PLATFORM_FILE="/mnt/SDCARD/Roms/PORTS/PortMaster/pylibs/harbourmaster/platform.py"
CONFIG_FILE="/mnt/SDCARD/Roms/PORTS/PortMaster/pylibs/harbourmaster/config.py"
PORTOLD="/mnt/SDCARD/App/PortMaster/patchs/PORTOLD.txt"
PORTNEW="/mnt/SDCARD/App/PortMaster/patchs/PORTNEW.txt"
CONTROLOLD="/mnt/SDCARD/App/PortMaster/patchs/CONTROLOLD.txt"
CONTROLNEW="/mnt/SDCARD/App/PortMaster/patchs/CONTROLNEW.txt"
CONFIGOLD="/mnt/SDCARD/App/PortMaster/patchs/CONFIGOLD.txt"
CONFIGNEW="/mnt/SDCARD/App/PortMaster/patchs/CONFIGNEW.txt"

replace_block() {
    local file="$1"
    local old_file="$2"
    local new_file="$3"
    
    [ ! -f "$file" ] && { echo "Error: $file no existe" >&2; return 1; }
    [ ! -f "$old_file" ] && { echo "Error: $old_file no existe" >&2; return 1; }
    [ ! -f "$new_file" ] && { echo "Error: $new_file no existe" >&2; return 1; }

    /mnt/SDCARD/miyoo355/bin/gawk -v old="$(<"$old_file")" -v new="$(<"$new_file")" '
        BEGIN { RS = "\0"; ORS = "" }
        { 
            idx = index($0, old)
            while (idx > 0) {
                printf "%s%s", substr($0, 1, idx-1), new
                $0 = substr($0, idx + length(old))
                idx = index($0, old)
            }
            print
        }
    ' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
}

for f in "$SH_FILE" "$SH_FILE_MIYOO"; do
    replace_block "$f" "$PORTOLD" "$PORTNEW"
done

/mnt/SDCARD/miyoo355/bin/gawk '
    /# HarbourMaster pipe commands/,/export PYSDL2_DLL_PATH="\/usr\/lib"/ {
        if (!done) {
            print "# HarbourMaster pipe commands"
            print "PM_PIPE=\"/dev/shm/portmaster/pm_input\""
            print "PM_DONE=\"/dev/shm/portmaster/pm_done\""
            print "PM_PID=\"\""
            print "export PYSDL2_DLL_PATH=\"/mnt/SDCARD/App/PortMaster/lib\""
            done = 1
            next
        }
        next
    }
    { print }
' "$DIALOG_FILE" > "$DIALOG_FILE.tmp" && mv "$DIALOG_FILE.tmp" "$DIALOG_FILE"

for f in "$CONTROL_FILE" "$CONTROL_FILE_MIYOO" "$CONTROL_FILE_ROOT"; do
    replace_block "$f" "$CONTROLOLD" "$CONTROLNEW"
done

/mnt/SDCARD/miyoo355/bin/gawk '
    /Path\("\/roms\/ports\/PortMaster\/control.txt"\)/ {
        sub(/\/roms\/ports\/PortMaster\/control.txt/, "/mnt/SDCARD/Roms/PORTS/PortMaster/control.txt")
    }
    { print }
' "$PLATFORM_FILE" > "$PLATFORM_FILE.tmp" && mv "$PLATFORM_FILE.tmp" "$PLATFORM_FILE"

replace_block "$CONFIG_FILE" "$CONFIGOLD" "$CONFIGNEW"

mkdir -p /mnt/SDCARD/Roms/PORTS/root
mount --bind /mnt/SDCARD/Roms/PORTS/root/ /root 

cd /mnt/SDCARD/Roms/PORTS/PortMaster
./PortMaster.sh

rm -f "/mnt/SDCARD/Roms/PORTS/PORTS_cache6.db"

sh_folder="/mnt/SDCARD/Roms/PORTS/"
img_folder="/mnt/SDCARD/Roms/PORTS/media/images/"

mkdir -p "$img_folder"

total=0
success=0
failures=0

for sh_file in "${sh_folder}"*.sh; do
    ((total++))
    echo -e "\n\e[1;36mProcesando: $(basename "$sh_file")\e[0m"
    
    NBGSH=$(basename "$sh_file" .sh)
    target_png="${img_folder}${NBGSH}.png"
    
    if [ -f "$target_png" ]; then
        echo -e "\e[33mImagen existente: $target_png\e[0m"
        ((success++))
        continue
    fi

    port_dir=""
    real_dir=""
    
    if portmaster_line=$(grep -m1 '^# PORTMASTER:' "$sh_file"); then
        echo "Línea PORTMASTER: $portmaster_line"
        port_dir=$(echo "$portmaster_line" | awk -F'[:, ]+' '{print $3}' | sed 's/\.zip$//')
        echo "Intento 1 - port_dir desde PORTMASTER: $port_dir"
        
        real_dir=$(find "$sh_folder" -maxdepth 1 -type d -iname "*${port_dir}*" | head -n1)
    fi

    if [ -z "$real_dir" ]; then
        if gamedir_line=$(grep -m1 '^GAMEDIR=' "$sh_file"); then
            echo "Línea GAMEDIR: $gamedir_line"
            port_dir=$(echo "$gamedir_line" | awk -F'=' '{print $2}' | tr -d '"'"'" | awk -F'/' '{print $NF}')
            echo "Intento 2 - port_dir desde GAMEDIR: $port_dir"
            real_dir=$(find "$sh_folder" -maxdepth 1 -type d -iname "*${port_dir}*" | head -n1)
        fi
    fi

    if [ -z "$real_dir" ]; then
        echo "Intento 3 - Búsqueda por nombre de script"
        port_dir=$(basename "$sh_file" .sh | tr '[:upper:]' '[:lower:]')
        real_dir=$(find "$sh_folder" -maxdepth 1 -type d -iname "*${port_dir}*" | head -n1)
        echo "Intento 3 - port_dir: $port_dir"
    fi

    if [ -n "$real_dir" ] && [ -d "$real_dir" ]; then
        echo -e "\e[32mDirectorio encontrado: $real_dir\e[0m"
    else
        echo -e "\e[31mError: No se encontró directorio para $NBGSH\e[0m"
        ((failures++))
        continue
    fi

    if [ -f "${real_dir}/cover.png" ]; then
        cp -v "${real_dir}/cover.png" "$target_png"
        ((success++))
    elif [ -f "${real_dir}/cover.jpg" ]; then
        cp -v "${real_dir}/cover.jpg" "$target_png"
        ((success++))
    elif [ -f "${real_dir}/screenshot.jpg" ]; then
        cp -v "${real_dir}/screenshot.jpg" "$target_png"
        ((success++))
    elif [ -f "${real_dir}/screenshot.png" ]; then
        cp -v "${real_dir}/screenshot.png" "$target_png"
        ((success++))
    else
        echo -e "\e[31mError: No hay imágenes en ${real_dir##*/}\e[0m"
        ((failures++))
    fi
done

echo -e "\n\e[1;35mResumen final:\e[0m"
echo "Total procesados: $total"
echo -e "\e[32mÉxitos: $success\e[0m"
echo -e "\e[31mFallos: $failures\e[0m"

umount /root

unset HOME
unset PYSDL2_DLL_PATH

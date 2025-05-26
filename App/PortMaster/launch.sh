#!/bin/bash
export HOME=/mnt/SDCARD/Roms/PORTS
export PYSDL2_DLL_PATH=/mnt/SDCARD/App/PortMaster/lib
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

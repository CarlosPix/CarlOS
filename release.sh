#!/bin/bash

# Uso: ./copiar-cambios.sh <etiqueta-release> <ruta-destino>
# Ejemplo: ./copiar-cambios.sh v1.2.3 /ruta/a/carpeta_externa 

LAST_RELEASE_TAG="$1"
DEST_FOLDER="$2"

if [ -z "$LAST_RELEASE_TAG" ] || [ -z "$DEST_FOLDER" ]; then
  echo "Uso: $0 <último-release-tag> <carpeta-destino>"
  exit 1
fi

if [ ! -d "$DEST_FOLDER" ]; then
  echo "La carpeta destino no existe."
  exit 1
fi

CURRENT_COMMIT=$(git rev-parse HEAD)
CHANGED_FILES=$(git diff --name-only $LAST_RELEASE_TAG $CURRENT_COMMIT)

for file in $CHANGED_FILES; do
  if [ -f "$file" ]; then
    cp --parents "$file" "$DEST_FOLDER"
  fi
done

echo "Archivos copiados a $DEST_FOLDER de los cambios entre $LAST_RELEASE_TAG y $CURRENT_COMMIT"

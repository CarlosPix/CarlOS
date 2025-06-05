#!/bin/bash

ROMS_DIR="$(dirname "$0")/../../Roms"

# Dictionary of extensions by system
declare -A EXTENSIONS

EXTENSIONS["AMIGA"]="adf uae ipf dms dmz adz lha hdf exe m3u zip 7z"
EXTENSIONS["ARCADE"]="zip 7z"
EXTENSIONS["ARDUBOY"]="hex"
EXTENSIONS["ATARI2600"]="zip 7z bin a26"
EXTENSIONS["ATARI5200"]="rom xfd atr atx cdm cas car bin a52 xex zip 7z"
EXTENSIONS["ATARI7800"]="a78 bin zip 7z"
EXTENSIONS["ATARI800"]="xfd atr dcm cas bin a52 zip atx car rom com xex m3u 7z"
EXTENSIONS["C64"]="d64 d81 crt prg tap t64 m3u zip 7z"
EXTENSIONS["CPC"]="dsk sna tap cdt voc m3u zip 7z"
EXTENSIONS["CPS1"]="zip 7z"
EXTENSIONS["CPS2"]="zip 7z"
EXTENSIONS["CPS3"]="zip 7z"
EXTENSIONS["DC"]="chd cue cdi gdi m3u"
EXTENSIONS["DOOM"]="wad iwad pwad gzdoom"
EXTENSIONS["DOS"]="pc dos squashfs dosz m3u iso cue exe bat zip 7z"
EXTENSIONS["EASYRPG"]="rpg zip 7z"
EXTENSIONS["FBNEO"]="zip 7z"
EXTENSIONS["FC"]="nes fds unf unif zip 7z"
EXTENSIONS["FDS"]="nes fds unf unif zip 7z"
EXTENSIONS["GB"]="gb gbc zip 7z"
EXTENSIONS["GBA"]="gba agb gbz zip 7z"
EXTENSIONS["GBC"]="gb gbc zip 7z"
EXTENSIONS["INTELL"]="zip int bin rom 7z"
EXTENSIONS["LOWRES"]="nx zip 7z"
EXTENSIONS["MAME"]="zip 7z"
EXTENSIONS["MD"]="bin gen md smd 32x zip 7z"
EXTENSIONS["MS"]="sms rom gg sg zip 7z"
EXTENSIONS["MSU1"]="sfc"
EXTENSIONS["MSX"]="dsk mx2 rom zip 7z cas m3u"
EXTENSIONS["MUGEN"]="mgn 7z"
EXTENSIONS["N64"]="n64 v64 zip 7z z64"
EXTENSIONS["NEOCD"]="cue iso chd"
EXTENSIONS["NEOGEO"]="zip 7z"
EXTENSIONS["NES"]="nes fds unf unif zip 7z"
EXTENSIONS["NGP"]="ngc ngp zip 7z"
EXTENSIONS["OPENBOR"]="pak Pak PAK 7z"
EXTENSIONS["PCE"]="pce cue zip chd 7z"
EXTENSIONS["PCECD"]="pce cue ccd iso img chd"
EXTENSIONS["PGM"]="zip 7z"
EXTENSIONS["POKE"]="min zip 7z"
EXTENSIONS["PS"]="bin cue img mdf pbp toc cbn m3u chd 7z"
EXTENSIONS["PSP"]="pbp cso iso"
EXTENSIONS["SCUMMVM"]="scummvm squashfs"
EXTENSIONS["SEGACD"]="cue iso chd m3u"
EXTENSIONS["SFC"]="smc sfc gd3 gd7 dx2 bsx swc zip 7z"
EXTENSIONS["SG1000"]="bin sg zip 7z"
EXTENSIONS["SG32X"]="cue iso chd zip 7z"
EXTENSIONS["SNES"]="smc fig sfc gd3 gd7 dx2 bsx swc zip 7z"
EXTENSIONS["SPICO"]="zip"
EXTENSIONS["SS"]="cue chd iso 7z"
EXTENSIONS["SUPERVISION"]="sv zip 7z"
EXTENSIONS["TIC80"]="tic"
EXTENSIONS["VB"]="vb zip 7z json"
EXTENSIONS["WOLF3D"]="ecwolf pk3 squashfs"
EXTENSIONS["WS"]="wsc zip 7z ws"

# Delete all *_cache6.db files
find "$ROMS_DIR" -type f -name '*_cache6.db' -exec rm -f {} +

for SYSTEM_DIR in "$ROMS_DIR"/*; do
  [ -d "$SYSTEM_DIR" ] || continue
  SYSTEM_NAME=$(basename "$SYSTEM_DIR")

  EXTS="${EXTENSIONS[$SYSTEM_NAME]}"
  [ -z "$EXTS" ] && continue

  GAMELIST="$SYSTEM_DIR/gamelist.xml"
  TMPGAMELIST="$SYSTEM_DIR/gamelist.xml.tmp"
  LISTED="$SYSTEM_DIR/.listed.txt"

  [ ! -f "$GAMELIST" ] && {
    echo '<?xml version="1.0"?>' > "$GAMELIST"
    echo '<gameList>' >> "$GAMELIST"
    echo '</gameList>' >> "$GAMELIST"
  }

  grep "<path>" "$GAMELIST" | sed -e 's|.*<path>\(.*\)</path>.*|\1|' -e 's/&amp;/\&/g' > "$LISTED"
  head -n -1 "$GAMELIST" > "$TMPGAMELIST"

  for ext in $EXTS; do
    # Find all files with the given extension in SYSTEM_DIR and its subdirectories
    while IFS= read -rd '' file; do
      [ -e "$file" ] || continue

      # Compute the relative path from SYSTEM_DIR
      rel_filename="${file#$SYSTEM_DIR/}"
      # Strip trailing slash if present
      rel_filename="${rel_filename%%/}"

      grep -Fxq "$rel_filename" "$LISTED" && continue

      filename=$(basename "$file")
      name="${filename%.*}"

      # respect subfolders for images
      image_rel_name="${rel_filename%.*}"

      echo "  <game>" >> "$TMPGAMELIST"
      echo "    <path>$rel_filename</path>" >> "$TMPGAMELIST"
      echo "    <name>$name</name>" >> "$TMPGAMELIST"
      echo "    <image>./media/images/$image_rel_name.png</image>" >> "$TMPGAMELIST"
      echo "  </game>" >> "$TMPGAMELIST"
    done < <(find "$SYSTEM_DIR" -type f -name "*.$ext" -print0)
  done

  echo '</gameList>' >> "$TMPGAMELIST"
  mv "$TMPGAMELIST" "$GAMELIST" >/dev/null 2>&1
  rm -f "$LISTED" >/dev/null 2>&1
done

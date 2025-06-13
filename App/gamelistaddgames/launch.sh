#!/bin/bash

ROMS_DIR="$(dirname "$0")/../../Roms"

# Dictionary of extensions by system
declare -A EXTENSIONS

EXTENSIONS["AMIGA"]="adf adz dms fdi ipf hdf hdz lha slave info cue ccd nrg exe mds iso chd uae m3u zip 7z rp9"
EXTENSIONS["ARCADE"]="zip 7z"
EXTENSIONS["ARDUBOY"]="hex arduboy"
EXTENSIONS["ATARI2600"]="zip 7z bin a26"
EXTENSIONS["ATARI5200"]="rom xfd atr atx cdm cas car bin a52 xex zip 7z"
EXTENSIONS["ATARI7800"]="a78 cdf bin zip 7z"
EXTENSIONS["ATARI800"]="xfd atr dcm cas bin a52 zip atx car rom com xex m3u 7z"
EXTENSIONS["ATOMIS"]="chd cdi elf bin cue gdi lst zip dat 7z m3u"
EXTENSIONS["C64"]="d64 d71 d80 d81 d82 g64 g41 x64 t64 tap prg p00 crt bin gz d6z d7z d8z g6z g4z x6z cmd m3u vfl vsf nib nbz d2m d4m zip 7z"
EXTENSIONS["CPC"]="dsk sna zip tap cdt voc cpr m3u zip 7z"
EXTENSIONS["CPS1"]="zip 7z"
EXTENSIONS["CPS2"]="zip 7z"
EXTENSIONS["CPS3"]="zip 7z"
EXTENSIONS["COLECO"]="bin col rom zip 7z"
EXTENSIONS["DC"]="chd cdi elf bin cue gdi lst zip dat 7z m3u"
EXTENSIONS["DOOM"]="wad iwad pwad gzdoom"
EXTENSIONS["DOS"]="pc dos squashfs zip dosz exe com bat iso chd cue ins img ima vhd jrc tc m3u m3u8 conf 7z"
EXTENSIONS["EASYRPG"]="rpg zip 7z"
EXTENSIONS["FBNEO"]="zip 7z"
EXTENSIONS["FC"]="nes fds unf unif zip 7z"
EXTENSIONS["FDS"]="nes fds unf unif zip 7z"
EXTENSIONS["GB"]="gb gbc dmg zip 7z"
EXTENSIONS["GBA"]="gba agb gbz zip 7z"
EXTENSIONS["GBC"]="gb gbc dmg zip 7z"
EXTENSIONS["INTELL"]="zip int bin rom 7z"
EXTENSIONS["JAVA"]="jar"
EXTENSIONS["LOWRES"]="nx zip 7z"
EXTENSIONS["MAME"]="zip 7z"
EXTENSIONS["MD"]="bin gen smd md 32x cue iso chd sms gg sg sc m3u 68k sgd pco zip 7z"
EXTENSIONS["MS"]="sms rom gg sg zip 7z"
EXTENSIONS["MSU1"]="smc fig sfc gd3 gd7 dx2 bsx swc zip 7z"
EXTENSIONS["MSX"]="rom ri mx1 mx2 dsk col sg sc sf cas m3u zip 7z"
EXTENSIONS["MUGEN"]="mgn 7z"
EXTENSIONS["N64"]="n64 v64 z64 bin u1 ndd zip 7z"
EXTENSIONS["NAOMI"]="chd cdi elf bin cue gdi lst zip dat 7z m3u"
EXTENSIONS["NEOCD"]="cue iso chd"
EXTENSIONS["NEOGEO"]="zip 7z"
EXTENSIONS["NES"]="nes fds unf unif zip 7z"
EXTENSIONS["NGP"]="ngc ngp zip 7z"
EXTENSIONS["ODYSSEYTWO"]="bin"
EXTENSIONS["OPENBOR"]="pak Pak PAK 7z"
EXTENSIONS["PCE"]="pce sgx cue ccd chd toc m3u zip 7z"
EXTENSIONS["PCECD"]="pce sgx cue ccd chd iso img"
EXTENSIONS["PPSSPP"]="chd pbp cso iso"
EXTENSIONS["PGM"]="zip 7z"
EXTENSIONS["PICO8"]="p8"
EXTENSIONS["POKE"]="min zip 7z"
EXTENSIONS["PORTS"]="sh"
EXTENSIONS["PS"]="bin cue img mdf pbp toc cbn m3u ccd chd iso exe zip 7z"
EXTENSIONS["PSP"]="chd pbp cso iso"
EXTENSIONS["SCUMMVM"]="scummvm squashfs"
EXTENSIONS["SEGACD"]="bin cue iso chd m3u"
EXTENSIONS["SFC"]="smc fig sfc gd3 gd7 dx2 bsx swc zip 7z"
EXTENSIONS["SG1000"]="mdx md smd gen bin cue iso sms bms gg sg 68k sgd chd m3u zip 7z"
EXTENSIONS["SG32X"]="bin gen 32x cue iso chd zip 7z"
EXTENSIONS["SNES"]="smc fig sfc gd3 gd7 dx2 bsx swc zip 7z"
EXTENSIONS["SPICO"]="zip"
EXTENSIONS["SS"]="bin ccd chd cue iso mds zip 7z"
EXTENSIONS["SUPERVISION"]="bin sv zip 7z"
EXTENSIONS["TIC80"]="tic"
EXTENSIONS["VB"]="bin vb zip 7z"
EXTENSIONS["WOLF3D"]="ecwolf pk3 squashfs"
EXTENSIONS["WS"]="ws wsc pc2 pcv2 zip 7z"


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
    for file in "$SYSTEM_DIR"/*."$ext"; do
      [ -e "$file" ] || continue
      filename=$(basename "$file")
      name="${filename%.*}"

      grep -Fxq "$filename" "$LISTED" && continue

      echo "  <game>" >> "$TMPGAMELIST"
      echo "    <path>$filename</path>" >> "$TMPGAMELIST"
      echo "    <name>$name</name>" >> "$TMPGAMELIST"
      echo "    <image>./media/images/$name.png</image>" >> "$TMPGAMELIST"
      echo "  </game>" >> "$TMPGAMELIST"
    done
  done

  echo '</gameList>' >> "$TMPGAMELIST"
  mv "$TMPGAMELIST" "$GAMELIST" >/dev/null 2>&1
  rm -f "$LISTED" >/dev/null 2>&1
done
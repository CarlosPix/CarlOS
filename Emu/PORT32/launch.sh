#!/bin/sh

# --- Path Configuration ---
LAUNCHERS_DIR="/mnt/SDCARD/Emu/PORT32"

# --- Full path of the game to launch ---
GAME_NAME=$(basename "$1")

# --- Launcher Selection (CASE) ---
case "$GAME_NAME" in
    "AM2R.sh"|"ShovelKnight.sh"|"sorr.sh" )
        LAUNCHER="$LAUNCHERS_DIR/launchP32.sh"
        ;;
    *)  # All other games (default PortMaster launcher)
        LAUNCHER="$LAUNCHERS_DIR/launchPM.sh"
        ;;
esac

# --- Execution ---
"$LAUNCHERS_DIR/cpufreq.sh"
"$LAUNCHER" "$1"

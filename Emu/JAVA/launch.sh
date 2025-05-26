#!/bin/sh
echo $0 $*
progdir=`dirname "$0"`
cd $progdir
#mount -t squashfs localejava.img tools/share/locale
#mount --bind tools/share /usr/share
export PATH="/mnt/SDCARD/miyoo355/bin:${PATH}"
export LD_LIBRARY_PATH="$progdir/lib:/mnt/SDCARD/miyoo355/lib:${LD_LIBRARY_PATH}"
export LOCPATH="tools/share/locale"
export HOME=$progdir

JAVA_HOME="$HOME/jdk"
echo 1 >  /sys/devices/system/cpu/cpu2/online
echo 1 >  /sys/devices/system/cpu/cpu3/online
export FONTCONFIG_PATH=/mnt/sdcard/Emu/JAVA/fonts
export FONTCONFIG_FILE=/mnt/sdcard/Emu/JAVA/fonts.conf

#mount "$progdir/jdk.img" "$progdir/jdk"

export JAVA_HOME
PATH="$JAVA_HOME/bin:$PATH"
export PATH

export LANG="zh_CN.UTF-8"
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8

mkdir -p ./.java/.systemPrefs
mkdir -p ./.java/.userPrefs
chmod -R 755 ./.java

#JAVA_TOOL_OPTIONS='-Xverify:none -Djava.util.prefs.systemRoot=/storage/roms/savestates/j2me/ -Djava.util.prefs.userRoot=/storage/roms/savestates/j2me/ -Djava.awt.headless=true -Dsun.jnu.encoding=UTF-8 -Dfile.encoding=UTF-8 -Djava.library.path=/storage/java/lib'
JAVA_TOOL_OPTIONS='-Xverify:none -Djava.awt.headless=true -Dsun.jnu.encoding=UTF-8 -Dfile.encoding=UTF-8 -Djava.library.path=/mnt/sdcard/Emu/JAVA/lib  -Djava.util.prefs.systemRoot=/mnt/sdcard/Emu/JAVA/jdk -Djava.util.prefs.userRoot=//mnt/sdcard/Emu/JAVA/jdk'
export JAVA_TOOL_OPTIONS

gamedir=`dirname "$1"`

if echo $gamedir | grep "240x320" > /dev/null
then
	# echo "240*320" >>0.txt
	java -jar $progdir/freej2me-sdl.jar "$1" 240 320 100

elif echo $gamedir | grep "320x240" > /dev/null
then
	# echo "320*240" >>0.txt
	java -jar $progdir/freej2me-sdl.jar "$1" 320 240 100

elif echo $gamedir | grep "128x128" > /dev/null
then
	# echo "128*128" >>0.txt
	java -jar $progdir/freej2me-sdl.jar "$1" 128 128 100
	
elif echo $gamedir | grep "176x208" > /dev/null
then
	# echo "128*128" >>0.txt
	java -jar $progdir/freej2me-sdl.jar "$1" 176 208 100

elif echo $gamedir | grep "176x220" > /dev/null
then
	# echo "128*128" >>0.txt
	java -jar $progdir/freej2me-sdl.jar "$1" 176 220 100

elif echo $gamedir | grep "360x640" > /dev/null
then
	# echo "128*128" >>0.txt
	java -jar $progdir/freej2me-sdl.jar "$1" 360 640 100

elif echo $gamedir | grep "640x360" > /dev/null
then
	# echo "640*360" >>0.txt
	java -jar $progdir/freej2me-sdl.jar "$1" 640 360 100

else
	echo "none"
	java -jar $progdir/freej2me-sdl.jar "$1" 320 240 100
fi
#umount /usr/share
#umount $progdir/tools/share/locale
#i

# Carl OS
![CarlOS_logo_SM](https://github.com/user-attachments/assets/cdaaf3c4-4bce-4764-8104-382edcf1f3a0)

# StockMod of Miyoo Flip OS
# 1.- Introduction
CarlOS is a Stock MOD of the Operating System created for the Miyoo Flip by Miyoo themselves. Unlike the original, it includes a vast number of emulation systems not originally planned in the factory OS—up to 67 different systems.

Highlights:

Home Computers: Amiga, Commodore 64, Amstrad CPC, MSX, MS-DOS, ScummVM, X68000, and ZX Spectrum.

Arcades: ARCADE (Unified with Automatic Core Selection), CPS1, CPS2, CPS3, MUGEN, OpenBOR, and PGM (PolyGame Master).

Virtual Consoles: Arduboy, Pico-8, TIC-80, LowRES.

Home Consoles: Intellivision, Sega Pico, Vectrex, and N64 Standalone.

Handhelds: Atari Lynx, Pokémon Mini, Watara Supervision, Game & Watch.
# 2.- How to install
## [[MANDATORY INSTALL FIRMWARE 20250521 FIRST]]

Before installing Carl OS, it is important to install first the firmware included with Carl OS release. It's preferable to use a blank SD card formatted as FAT32 with 32KB cluster size.

After extracting the firmware package, copy the 'miyoo355_fw.img' file directly to the main directory (root) of your micro SD card. With a charged battery, insert the SD card into your console, turn it on, and allow the installation process to finish. Then delete de miyoo355_fw.img from SD card.



## 2.1.- Install Carl OS (Burning option)
You have two options to install CarlOS: either by burning an image or simply by downloading the SD card contents and copying them.

If you choose the burning method, you can use Rufus, Balena Etcher, Win32DiskImager, or similar software. Note that after burning, you'll need to expand the FAT32 partition using specialized software like DiskGenius, EaseUS Partition Master, or similar tools designed for this purpose.

## 2.2.- Install Carl OS (Copy & Paste option) 
Burning the image is faster but involves more steps. If you want to keep things simple, download the SD contents, extract them, and copy to your card formatted as FAT32 with 32KB cluster size.

This method is slower but completely straightforward.

# 3.- How to install Games
## 3.1.- How to add Games using gamelist method
Each system has a corresponding info_XXX.txt file inside its folder, which lists the compatible ROM extensions for that system. 

The system can work with gamelists generated by www.screenscraper.fr, but they need to be adapted for CarlOS. 

### Repair Gamelist (SCRIPT)

In the App section, there is a script that fixes these gamelists by formatting them to meet the system's requirements (It takes about 1 minute to complete, depending on how many systems and ROMs you have).

### Add games to gamelist (SCRIPT)

If you want to add some games but don't want to regenerate a gamelist.xml using ScreenScraper, you can do it directly from the console using a script called "add games to gamelist". This script fills in the basic information missing from your gamelist.xml for a specific system, adding essential details like the path, name, and location of the game's image.

Keep in mind that if your new game is named something like "MaRs InvASIOn [EU]-SPA.zip", the information will be added with this exact name. Therefore, it's highly recommended to format the name beforehand to match how you want it to appear in your games list. The game file and its cover image must have EXACTLY the same name, including uppercase and lowercase letters.

### Keep in mind that if you choose to use gamelists for your game collections but don't add the games to them, these games won't appear in each system's list.
### You can choose not to use gamelists if you find this process troublesome

## 3.2.- How to add Games without use gamelist

If you choose not to use gamelist.xml, the game cover images must still be placed in the system's /media/images folder.

### Whether you use gamelists or not, the image files for each game must be placed inside the corresponding system folder under /media/images, with the exact same name as the game file for them to be recognized.

## 3.3.- BIOS FILES (not included)
### The BIOS must go in the root of the SDCARD/BIOS directory. 


# 4.- PortMaster

PortMaster must be launched from the Apps section, NOT from the Ports system folder.
### It is very important NOT TO UPDATE PortMaster, as it may stop working.

# 5.- PICO 8 Splore

You need download the oficial pico8 files for raspberry pi and put PICO_64 and PICO.DAT onto SDCARD/App/Pico8/bin
https://www.lexaloffle.com/pico-8.php 

# 6.- Hotkeys

### 6.1.- System Hotkeys:

• Menu + Dpad Up = Increase screen brightness

• Menu + Dpad Down = Decrease screen brightness

• Select + Start + L1 + R1 = Force close process (if everything else fails)

• Menu + Start = Exit any application


### 6.2.- RetroArch Hotkeys:

• MENU + START = Exit games

• MENU + X = RetroArch Menu

• MENU + B = Toggle FAST FORWARD

• MENU + A = Pause Game

• MENU + Y = toggle Show FPS

• MENU + R1 = SAVE STATE (Save at any time)

• MENU + L1 = LOAD STATE (Load at any time)

• MENU + R2 = INCREASE SAVE STATE SLOT (Select save slot)

• SELECT + L2 = DECREASE SAVE STATE SLOT (Select save slot)

• MENU + R3 = Reset game

• L3 + DESIRED BUTTON = Enable button turbo


### 6.3.- Drastic Hotkeys


• L2 BUTTON - SWITCH SCREENS

• R2 BUTTON - TOGGLE PENCIL MODE

• MENU + LEFT D-PAD - PREVIOUS OVERLAY

• MENU + RIGHT D-PAD - NEXT OVERLAY

• MENU + A BUTTON - SWITCH TO MAIN SCREEN ONLY

• MENU + START - EMULATOR QUICK MENU

• MENU + SELECT - EMULATOR ADVANCED MENU

• MENU + L2 - LOAD SAVESTATE

• MENU + R2 - SAVE SAVESTATE

• MENU + B BUTTON - SMOOTHING / PIXEL MODE

• MENU + L1 - EXIT DRASTIC


# 7.- Complete systems list
Sega 32X, Commodore Amiga, Arcade, Arduboy, Atari 2600, Atari 5200, Atari 7800, Atari 800, Commodore 64, Amstrad CPC, Capcom Play System, Capcom Play System II, Capcom Play System III, Sega Dreamcast, Doom, DOS, EasyRPG, FinalBurn Neo, Nintendo Entertainment System, Famicom Disk System, Game Boy, Game Boy Advance, Game Boy Color, Sega Game Gear, Game & Watch, Intellivision, LowRes, Atari Lynx, MAME, Sega Mega Drive, Sega Master System, MSU-1, MSX, MUGEN, Nintendo 64, Nintendo DS, Neo Geo CD, Neo Geo, Nintendo Entertainment System, Neo Geo Pocket, Neo Geo Pocket Color, Odyssey2, ONScripter, OpenBOR, PC Engine, PC Engine CD-ROM², PGM, PICO-8, Pokémon Mini, Portmaster, Sony PlayStation, Sony PlayStation Portable, ScummVM, Sega CD, Super Famicom, SG-1000, Super Nintendo Entertainment System, Sega Pico, Sega Saturn, Watara Supervision, TIC-80, Virtual Boy, Wolfenstein 3D, WonderSwan, WonderSwan Color, Sharp X68000, ZX Spectrum

# 8.- Credits

![ROGUE_TEAM](https://github.com/user-attachments/assets/b3bc6fac-a594-4495-8ce1-abf5a13f6066)


CarlosPixel Project creator, system integration, scripting & creative direction

Juanma for sourcing materials, motivating the project, assisting with testing, and much more.

Thundertwin and K4rNyX for testing systems.

Ninoh-FOX "BLOSTE MASTER DEV" for providing System Hotkeys and the custom RetroArch build for this console, including N64 Standalone (Mupen64+) and PortMaster support. Founder of ROGUE TEAM.

Brumagix Gamer for behind-the-scenes support.

AlexisToretto for system testing and invaluable help with CarlOS theme design and other design tweaks.

# We thank Miyoo (Shenzhen le miyou technology co., ltd.) for providing the resources that made this project possible


# 🛠️ Made with ♥ (and caffeine) ☕  

This **Custom Firmware** is a **passion project**, built in our free time. Enjoy it? Consider [buying us a coffee](https://ko-fi.com/rogueteam)!  

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/rogueteam)

Thanks for being awesome! 🙌✨


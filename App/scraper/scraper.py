#!/usr/bin/env python3

import os
import io
import struct
import pygame
import json
import threading
import requests
import sys
import atexit
import signal
import hashlib
import binascii
import base64
from urllib.parse import quote
from PIL import Image
from concurrent.futures import ThreadPoolExecutor, as_completed

os.environ["SDL_NOMOUSE"] = "1"

INPUT_DEVICE = "/dev/input/event5"
ROMS_ROOT = "/mnt/SDCARD/Roms"
CONFIG_DIR = "/mnt/SDCARD/App/scraper/config"
CONFIG_PATH = os.path.join(CONFIG_DIR, "scraper.json")
EXT_PATH = "/mnt/SDCARD/App/gamelistaddgames/all_extensions.txt"
LOCK_PATH = "/tmp/scraper_py.lock"
KEY_PATH = "/userdata/keyscraper.txt"
ICONS_PATH = "/mnt/SDCARD/App/scraper/icons"

try:
    with open(KEY_PATH, "r") as f:
        KEY = f.read().strip().encode()
except Exception:
    KEY = b""

def xor_decrypt(enc, key):
    data = base64.b64decode(enc)
    return ''.join(chr(b ^ key[i % len(key)]) for i, b in enumerate(data))

ENCRYPTED_DEVID = "OwEKHAIoKzc="
ENCRYPTED_DEVPASSWORD = "QAIDRx8IEhUnMFc="
DEVID = xor_decrypt(ENCRYPTED_DEVID, KEY)
DEVPASSWORD = xor_decrypt(ENCRYPTED_DEVPASSWORD, KEY)
SOFTNAME = "Carl-OS"

MEDIA_TYPES = [
    ("mixrbv1", "Recalbox Mix"),
    ("mixrbv2", "Mix 4"),
    ("sstitle", "Title Screen"),
    ("ss", "Game Screen"),
    ("box-3D", "3D Box"),
    ("support-2D", "2D Support"),
    ("support-texture", "Cover"),
]
MEDIA_TYPE_TO_LABEL = dict(MEDIA_TYPES)
MEDIA_TYPE_KEYS = [k for k, v in MEDIA_TYPES]

ICON_FILES = {
    "mixrbv1": "mixrbv1.png",
    "mixrbv2": "mix4.png",
    "sstitle": "sstitle.png",
    "ss": "ss.png",
    "box-3D": "box-3D.png",
    "support-2D": "support-2D.png",
    "support-texture": "support-texture.png",
}

REGIONS = ["auto", "wor", "eu", "us", "jp", "ss", "cn", "asi", "fr", "sp", "de", "it"]
REGION_LABELS_EN = {
    "auto": "Auto",
    "wor": "World",
    "eu": "Europe",
    "us": "USA",
    "jp": "Japan",
    "ss": "ScreenScraper",
    "cn": "China",
    "asi": "Asia",
    "fr": "France",
    "sp": "Spain",
    "de": "Germany",
    "it": "Italy"
}

COLORS = {
    'bg': (18, 26, 38),
    'card_bg': (32, 48, 75),
    'card_border': (60, 120, 180),
    'accent': (0, 200, 255),
    'text_primary': (255, 255, 255),
    'text_secondary': (160, 180, 200),
    'selected': (255, 215, 0),
    'progress_red': (220, 40, 40),
    'progress_green': (40, 220, 80),
    'success': (80, 255, 80),
    'fail': (255, 80, 80),
    'existing': (180, 255, 180),
    'popup_bg': (30, 30, 60, 230)
}

cancel_scraping = threading.Event()
MAX_MOTORS = 1

def get_max_motors(user, password):
    global MAX_MOTORS
    try:
        url = (
            "https://www.screenscraper.fr/api2/ssuserInfos.php?"
            f"devid={DEVID}&devpassword={DEVPASSWORD}"
            f"&softname={SOFTNAME}&output=json"
        )
        if user and password:
            url += f"&ssid={user}&sspassword={password}"
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            data = response.json()
            max_threads = data.get("response", {}).get("ssuser", {}).get("maxthreads", "1")
            MAX_MOTORS = int(max_threads)
        else:
            MAX_MOTORS = 1
    except Exception:
        MAX_MOTORS = 1
    return MAX_MOTORS

def check_and_create_lock():
    if os.path.exists(LOCK_PATH):
        try:
            with open(LOCK_PATH, "r") as f:
                old_pid = int(f.read().strip())
            if old_pid != os.getpid() and os.path.exists(f"/proc/{old_pid}"):
                sys.exit(1)
        except Exception:
            os.remove(LOCK_PATH)
    with open(LOCK_PATH, "w") as f:
        f.write(str(os.getpid()))
    def cleanup(*args):
        try:
            if os.path.exists(LOCK_PATH):
                os.remove(LOCK_PATH)
        except Exception:
            pass
    atexit.register(cleanup)
    signal.signal(signal.SIGTERM, cleanup)
    signal.signal(signal.SIGINT, cleanup)
check_and_create_lock()

def clean_temp():
    tmp_paths = ["/tmp/scraper_py.lock", "/tmp/rundl.sh"]
    for p in tmp_paths:
        try:
            if os.path.exists(p):
                os.remove(p)
        except Exception:
            pass
clean_temp()

def get_systems():
    try:
        return sorted([d for d in os.listdir(ROMS_ROOT)
                       if os.path.isdir(os.path.join(ROMS_ROOT, d)) and not d.startswith('.')])
    except Exception:
        return []

def get_extensions(system):
    try:
        with open(EXT_PATH) as f:
            for line in f:
                if line.startswith(f'EXTENSIONS["{system.upper()}"]'):
                    return line.split('"')[3].split()
        return []
    except Exception:
        return []

def save_config(system, media, region, user, password, motors=1):
    os.makedirs(CONFIG_DIR, exist_ok=True)
    config = {
        "ScreenscraperSystem": system,
        "ScreenscraperMediaType": media,
        "ScreenscraperRegion": region,
        "screenscraper_username": user,
        "screenscraper_password": password,
        "motors": motors
    }
    with open(CONFIG_PATH, "w") as f:
        json.dump(config, f, indent=2)

def load_config():
    if not os.path.exists(CONFIG_PATH):
        return None
    try:
        with open(CONFIG_PATH, "r") as f:
            return json.load(f)
    except Exception:
        return None

def get_ssSystemID(system):
    mapping = {
        "AMIGA": "64", "ARCADE": "75", "ARDUBOY": "263", "ATARI2600": "26", "ATARI5200": "40", "ATARI7800": "41",
        "ATOMIS": "75", "C64": "66", "COLECO": "183", "CPC": "65", "CPS1": "6", "CPS2": "7", "CPS3": "8",
        "DC": "23", "DOOM": "", "DOS": "135", "EASYRPG": "231", "FBNEO": "75", "FC": "3", "FDS": "106",
        "FFMPEG": "", "GB": "9", "GBA": "12", "GBC": "10", "GG": "21", "GW": "52", "INTELL": "115", "JAVA": "",
        "LOWRES": "", "LYNX": "28", "MAME": "75", "MD": "1", "MS": "2", "MSU1": "4", "MSX": "113", "MUGEN": "",
        "N64": "14", "NAOMI": "23", "NDS": "15", "NEOCD": "70", "NEOGEO": "142", "NES": "3", "NGP": "25",
        "ODYSSEY2": "104", "ONS": "", "OPENBOR": "214", "PCE": "31", "PCECD": "114", "PGM": "75", "PGM2": "75",
        "PICO8": "", "PICO8F": "", "POKE": "", "PORTS": "137", "PS": "57", "PSP": "13", "SCUMMVM": "123",
        "SEGACD": "20", "SG1000": "109", "SG32X": "19", "SFC": "4", "SGB": "127", "SNES": "4", "SPICO": "",
        "SS": "22", "SUPERVISION": "207", "TIC80": "222", "VB": "11", "VECTREX": "102", "WOLF3D": "", "WS": "45",
        "X68000": "79", "ZX": "76"
    }
    sid = mapping.get(system.upper(), "")
    return sid

def get_hashes(filepath):
    crc32 = 0
    md5 = hashlib.md5()
    sha1 = hashlib.sha1()
    with open(filepath, "rb") as f:
        while True:
            data = f.read(65536)
            if not data:
                break
            crc32 = binascii.crc32(data, crc32)
            md5.update(data)
            sha1.update(data)
    crc32 = format(crc32 & 0xFFFFFFFF, '08X')
    md5 = md5.hexdigest().upper()
    sha1 = sha1.hexdigest().upper()
    return crc32, md5, sha1

def load_image_type_icons():
    icons = {}
    for key, filename in ICON_FILES.items():
        path = os.path.join(ICONS_PATH, filename)
        if os.path.exists(path):
            img = pygame.image.load(path).convert_alpha()
            if img.get_width() != 75 or img.get_height() != 75:
                img = pygame.transform.smoothscale(img, (75, 75))
            icons[key] = img
        else:
            icons[key] = None
    return icons

class VirtualKeyboard:
    def __init__(self, font):
        self.font = font
        self.rows = [
            "ABCDEFGHIJKLMNO",
            "PQRSTUVWXYZ-_?¿",
            "abcdefghijklmno",
            "pqrstuvwxyz,;.:",
            "0123456789@#*+/"
        ]
        self.special = ["Space", "Del", "OK"]
        self.cursor = [0, 0]
        self.input_text = ""
        self.done = False
        self.result = ""

    def draw(self, screen, prompt="Enter text:"):
        screen.fill(COLORS['bg'])
        prompt_surface = self.font.render(prompt, True, COLORS['selected'])
        screen.blit(prompt_surface, (40, 30))
        input_surface = self.font.render(self.input_text, True, COLORS['text_primary'])
        screen.blit(input_surface, (40, 70))
        key_w, key_h = 36, 48
        start_x = 16
        start_y = 120
        for rowidx, row in enumerate(self.rows):
            for colidx, ch in enumerate(row):
                x = start_x + colidx * key_w
                y = start_y + rowidx * key_h
                color = COLORS['selected'] if [rowidx, colidx] == self.cursor else COLORS['text_secondary']
                surf = self.font.render(ch, True, color)
                pygame.draw.rect(screen, (60, 80, 120), (x-2, y-2, key_w, key_h), 0 if [rowidx, colidx] == self.cursor else 1)
                screen.blit(surf, (x+8, y+7))
        y = start_y + len(self.rows)*key_h + 10
        for idx, label in enumerate(self.special):
            x = start_x + idx * (key_w*5 + 10)
            color = (255, 100, 100) if [len(self.rows), idx] == self.cursor else (180, 180, 255)
            surf = self.font.render(label, True, color)
            pygame.draw.rect(screen, (60, 80, 120), (x-2, y-2, key_w*5, key_h), 0 if [len(self.rows), idx] == self.cursor else 1)
            screen.blit(surf, (x+20, y+7))
        pygame.display.flip()

    def run(self, screen, dev, prompt="Enter text:"):
        self.input_text = ""
        self.done = False
        self.result = ""
        self.cursor = [0, 0]
        max_row = len(self.rows)
        while not self.done:
            self.draw(screen, prompt)
            data = dev.read(24)
            if len(data) < 24:
                continue
            _, _, evtype, code, value = struct.unpack("llHHi", data)
            if evtype == 1 and value == 1:
                if code == 305:  # A
                    row, col = self.cursor
                    if row < max_row:
                        if col < len(self.rows[row]):
                            char = self.rows[row][col]
                            if char != " ":
                                self.input_text += char
                    else:
                        if col == 0:
                            self.input_text += " "
                        elif col == 1:
                            self.input_text = self.input_text[:-1]
                        elif col == 2:
                            self.done = True
                            self.result = self.input_text
                            return self.input_text
                elif code == 304:  # B
                    self.done = True
                    self.result = None
                    return None
            elif evtype == 3:
                row, col = self.cursor
                if code == 16 and value != 0:
                    if row < max_row:
                        col = (col + (1 if value == 1 else -1)) % len(self.rows[row])
                    else:
                        col = (col + (1 if value == 1 else -1)) % 3
                    self.cursor = [row, col]
                elif code == 17 and value != 0:
                    row = (row + (1 if value == 1 else -1)) % (max_row + 1)
                    if row < max_row:
                        col = min(self.cursor[1], len(self.rows[row])-1)
                    else:
                        col = min(self.cursor[1], 2)
                    self.cursor = [row, col]
        return self.result

def process_rom(rom, system, mediatype, region, user, password, resultados, total, progress_callback):
    romspath = os.path.join(ROMS_ROOT, system)
    imgdir = os.path.join(romspath, "media", "images")
    romname, romext = os.path.splitext(rom)
    imgpath = os.path.join(imgdir, f"{romname}.png")

    if os.path.exists(imgpath):
        resultados["existing"] += 1
        current = resultados["success"] + resultados["fail"] + resultados["existing"]
        progress_callback(current / total, resultados)
        return

    romfile_path = os.path.join(romspath, rom)
    try:
        rom_size = os.path.getsize(romfile_path)
        crc32, md5, sha1 = get_hashes(romfile_path)
    except Exception:
        resultados["fail"] += 1
        current = resultados["success"] + resultados["fail"] + resultados["existing"]
        progress_callback(current / total, resultados)
        return

    romnom = quote(rom)
    url = (
        "https://www.screenscraper.fr/api2/jeuInfos.php?"
        f"devid={DEVID}&devpassword={DEVPASSWORD}"
        f"&softname={SOFTNAME}"
        f"&output=json"
        f"&systemeid={get_ssSystemID(system)}"
        f"&crc={crc32}&md5={md5}&sha1={sha1}"
        f"&romnom={romnom}"
        f"&romtaille={rom_size}"
        f"&romtype=rom"
    )
    if user and password:
        url += f"&ssid={user}&sspassword={password}"

    medias = []
    try:
        r = requests.get(url, timeout=20)
        if r.status_code == 200:
            data = r.json()
            medias = data.get("response", {}).get("jeu", {}).get("medias", [])
    except Exception:
        pass

    if not medias:
        url_nameonly = (
            "https://www.screenscraper.fr/api2/jeuInfos.php?"
            f"devid={DEVID}&devpassword={DEVPASSWORD}"
            f"&softname={SOFTNAME}"
            f"&output=json"
            f"&systemeid={get_ssSystemID(system)}"
            f"&romnom={romnom}"
            f"&romtype=rom"
        )
        if user and password:
            url_nameonly += f"&ssid={user}&sspassword={password}"
        try:
            r2 = requests.get(url_nameonly, timeout=20)
            if r2.status_code == 200:
                data2 = r2.json()
                medias = data2.get("response", {}).get("jeu", {}).get("medias", [])
        except Exception:
            pass

    if not medias:
        rombase = quote(os.path.splitext(rom)[0])
        url_base = (
            "https://www.screenscraper.fr/api2/jeuInfos.php?"
            f"devid={DEVID}&devpassword={DEVPASSWORD}"
            f"&softname={SOFTNAME}"
            f"&output=json"
            f"&systemeid={get_ssSystemID(system)}"
            f"&romnom={rombase}"
            f"&romtype=rom"
        )
        if user and password:
            url_base += f"&ssid={user}&sspassword={password}"
        try:
            r3 = requests.get(url_base, timeout=20)
            if r3.status_code == 200:
                data3 = r3.json()
                medias = data3.get("response", {}).get("jeu", {}).get("medias", [])
        except Exception:
            pass

    imgurl = None
    if region == "auto":
        region_prios = REGIONS[1:]
    else:
        region_prios = [region] + [r for r in REGIONS if r != region and r != "auto"]

    for reg in region_prios:
        for media in medias:
            if media.get("type") == mediatype and media.get("region") == reg:
                imgurl = media.get("url")
                break
        if imgurl:
            break

    if not imgurl:
        print(f"FAIL {rom}: No image found for type {mediatype} in any region (tried: {region_prios})")
        resultados["fail"] += 1
        current = resultados["success"] + resultados["fail"] + resultados["existing"]
        progress_callback(current / total, resultados)
        return

    headers = {
        "User-Agent": "Mozilla/5.0 (compatible; Carl-OS/1.0; +https://www.screenscraper.fr)"
    }
    
    try:
        response = requests.get(imgurl, timeout=20, headers=headers)
        if response.status_code == 200 and response.headers.get("Content-Type", "").startswith("image"):
            try:
                img = Image.open(io.BytesIO(response.content))
                img = img.convert("RGBA")
                
                if mediatype in ("mixrbv1", "mixrbv2"):
                    img.thumbnail((320, 320), Image.LANCZOS)
                else:
                    img.thumbnail((320, 240), Image.LANCZOS)
                
                img.save(imgpath, "PNG")
                resultados["success"] += 1
            except Exception as e:
                resultados["fail"] += 1
        else:
            resultados["fail"] += 1
        
        current = resultados["success"] + resultados["fail"] + resultados["existing"]
        progress_callback(current / total, resultados)
        return
    except Exception as e:
        resultados["fail"] += 1
        current = resultados["success"] + resultados["fail"] + resultados["existing"]
        progress_callback(current / total, resultados)
        return

def real_scraper(system, mediatype, region, user, password, num_motors, progress_callback):
    global cancel_scraping
    ssSystemID = get_ssSystemID(system)
    if not ssSystemID:
        print(f"Skipping system '{system}' as it has no valid systemeid.")
        return
    
    romspath = os.path.join(ROMS_ROOT, system)
    imgdir = os.path.join(romspath, "media", "images")
    os.makedirs(imgdir, exist_ok=True)
    
    extensions = get_extensions(system)
    romfiles = [f for f in os.listdir(romspath)
                if os.path.isfile(os.path.join(romspath, f)) and
                os.path.splitext(f)[1][1:].lower() in extensions and not f.startswith('.')]
    
    total = len(romfiles)
    resultados = {"success": 0, "fail": 0, "existing": 0}
    
    with ThreadPoolExecutor(max_workers=num_motors) as executor:
        futures = []
        for rom in romfiles:
            if cancel_scraping.is_set():
                break
            futures.append(executor.submit(
                process_rom, rom, system, mediatype, region, user, password, 
                resultados, total, progress_callback
            ))
        
        for future in as_completed(futures):
            if cancel_scraping.is_set():
                for f in futures:
                    f.cancel()
                break
    
    progress_callback(1.0, resultados)
    cancel_scraping.clear()

def draw_card(surface, x, y, width, height, title, value, is_selected=False, icon=None):
    border_color = COLORS['selected'] if is_selected else COLORS['card_border']
    bg_color = COLORS['card_bg']
    pygame.draw.rect(surface, border_color, (x, y, width, height), 2)
    pygame.draw.rect(surface, bg_color, (x+2, y+2, width-4, height-4))
    icon_offset = 0
    if icon:
        surface.blit(icon, (x + 10, y + (height - icon.get_height()) // 2))
        icon_offset = icon.get_width() + 18
        
    if title == "Start Scraping":
        lines = value.split('\n')
        if len(lines) >= 1:
            line1 = font_medium.render(lines[0], True, COLORS['text_secondary'])
            surface.blit(line1, (x + 10 + icon_offset, y + 10))
        if len(lines) >= 2:
            line2 = font_medium.render(lines[1], True, COLORS['text_primary'])
            surface.blit(line2, (x + 10 + icon_offset, y + 48))
    else:
        title_surface = font_medium.render(title, True, COLORS['text_secondary'])
        surface.blit(title_surface, (x + 10 + icon_offset, y + 10))
        value_surface = font_medium.render(value, True, COLORS['text_primary'])
        surface.blit(value_surface, (x + 10 + icon_offset, y + 48))

def draw_progress_popup():
    rect_w, rect_h = 600, 220
    rect_x = (640 - rect_w) // 2
    rect_y = (480 - rect_h) // 2

    overlay = pygame.Surface((rect_w, rect_h), pygame.SRCALPHA)
    overlay.fill(COLORS['popup_bg'])
    screen.blit(overlay, (rect_x, rect_y))
    pygame.draw.rect(screen, (255, 255, 255), (rect_x, rect_y, rect_w, rect_h), 3)

    bar_x, bar_y, bar_w, bar_h = rect_x + 40, rect_y + 60, rect_w - 80, 36
    bar_color = COLORS['progress_green'] if progress >= 1.0 else COLORS['progress_red']
    pygame.draw.rect(screen, bar_color, (bar_x, bar_y, int(bar_w * progress), bar_h))
    pygame.draw.rect(screen, (200, 200, 200), (bar_x, bar_y, bar_w, bar_h), 2)

    pctxt = font_small.render(f"Progress: {int(progress*100):3d}%", True, COLORS['text_primary'])
    screen.blit(pctxt, (rect_x + rect_w//2 - pctxt.get_width()//2, bar_y + bar_h + 8))

    rtxt = font_small.render(
        f"Success: {resultados['success']:5d}  Fail: {resultados['fail']:5d}  Existing: {resultados['existing']:5d}",
        True, COLORS['text_primary']
    )
    screen.blit(rtxt, (rect_x + rect_w//2 - rtxt.get_width()//2, bar_y + bar_h + 38))

    if progress >= 1.0:
        msg = "Press A or B to close"
    else:
        msg = "Press B to cancel"
    msg_surface = font_small.render(msg, True, COLORS['accent'])
    msg_w, msg_h = msg_surface.get_size()
    msg_rect_w = msg_w + 60
    msg_rect_h = msg_h + 24
    msg_rect_x = rect_x + rect_w//2 - msg_rect_w//2
    msg_rect_y = rect_y + rect_h - msg_rect_h - 18

    msg_overlay = pygame.Surface((msg_rect_w, msg_rect_h), pygame.SRCALPHA)
    msg_overlay.fill((20, 20, 20, 220))
    screen.blit(msg_overlay, (msg_rect_x, msg_rect_y))
    pygame.draw.rect(screen, (100, 100, 100), (msg_rect_x, msg_rect_y, msg_rect_w, msg_rect_h), 2)
    screen.blit(msg_surface, (msg_rect_x + (msg_rect_w - msg_w)//2, msg_rect_y + (msg_rect_h - msg_h)//2))

    pygame.display.update(pygame.Rect(rect_x, rect_y, rect_w, rect_h))        
        
def draw_menu():
    screen.fill(COLORS['bg'])
    title_surface = font_large.render("ROM Scraper Utility", True, COLORS['accent'])
    screen.blit(title_surface, (30, 10))
    pygame.draw.line(screen, COLORS['accent'], (30, 80), (610, 80), 3)
    card_w, card_h = 280, 90
    x0, y0 = 40, 100
    x1 = x0 + card_w + 20
    y_step = card_h + 18
    positions = [
        (x0, y0),         # 0 ROM System
        (x1, y0),         # 1 Image Type
        (x0, y0 + y_step),# 2 Region
        (x1, y0 + y_step),# 3 Username
        (x0, y0 + 2*y_step), # 4 Password
        (x1, y0 + 2*y_step), # 5 Motors
        (x0, y0 + 3*y_step), # 6 Start Scraping
    ]
    for i, item in enumerate(menuitems):
        is_selected = (i == selected)
        icon = None
        if item["label"] == "Image Type":
            key = item["options"][item["index"]]
            icon = IMAGE_TYPE_ICONS.get(key, None)
            value = MEDIA_TYPE_TO_LABEL.get(key, key)
        else:
            value = item["value"]
        draw_card(screen, positions[i][0], positions[i][1], card_w, card_h, item["label"], value, is_selected, icon)
    help_surface = font_small.render("A: Edit/Start | B: Exit", True, COLORS['text_secondary'])
    screen.blit(help_surface, (40, 430))
            
    pygame.display.flip()
    
def wait_for_close_popup(dev):
    while True:
        data = dev.read(24)
        if len(data) < 24:
            continue
        _, _, evtype, code, value = struct.unpack("llHHi", data)
        if evtype == 1 and value == 1 and (code == 304 or code == 305):
            break

pygame.init()
screen = pygame.display.set_mode((640, 480))
pygame.display.set_caption("ROM Scraper Utility")
font_large = pygame.font.SysFont("monospace", 56, bold=True)
font_medium = pygame.font.SysFont("monospace", 32, bold=True)
font_small = pygame.font.SysFont("monospace", 28)
pygame.mouse.set_visible(False)

IMAGE_TYPE_ICONS = load_image_type_icons()

systems = get_systems()
menuitems = [
    {"label": "ROM System", "options": systems, "index": 0, "value": systems[0] if systems else ""},
    {"label": "Image Type", "options": MEDIA_TYPE_KEYS, "index": 0, "value": MEDIA_TYPE_TO_LABEL[MEDIA_TYPE_KEYS[0]]},
    {"label": "Region", "options": REGIONS, "index": 0, "value": REGION_LABELS_EN[REGIONS[0]]},
    {"label": "Username", "options": [""], "index": 0, "value": ""},
    {"label": "Password", "options": [""], "index": 0, "value": ""},
    {
        "label": "Start Scraping",
        "options": [],
        "index": 0,
        "value": "Press A to Start\nMotors: 1 of 1",
        "motors": 1,
        "max_motors": 1
    },
]

selected = 0
progress = 0
resultados = {"success": 0, "fail": 0, "existing": 0}
show_progress_popup = False

config = load_config()
if config:
    if config.get("ScreenscraperSystem") in systems:
        menuitems[0]["index"] = systems.index(config["ScreenscraperSystem"])
        menuitems[0]["value"] = config["ScreenscraperSystem"]
    if config.get("ScreenscraperMediaType") in MEDIA_TYPE_KEYS:
        menuitems[1]["index"] = MEDIA_TYPE_KEYS.index(config["ScreenscraperMediaType"])
        menuitems[1]["value"] = MEDIA_TYPE_TO_LABEL[config["ScreenscraperMediaType"]]
    if config.get("ScreenscraperRegion") in REGIONS:
        menuitems[2]["index"] = REGIONS.index(config["ScreenscraperRegion"])
        menuitems[2]["value"] = REGION_LABELS_EN[config["ScreenscraperRegion"]]
    menuitems[3]["options"][0] = config.get("screenscraper_username", "")
    menuitems[3]["value"] = config.get("screenscraper_username", "")
    menuitems[4]["options"][0] = "*" * len(config.get("screenscraper_password", ""))
    menuitems[4]["value"] = "*" * len(config.get("screenscraper_password", ""))
    menuitems[4]["real"] = config.get("screenscraper_password", "")
    menuitems[5]["motors"] = config.get("motors", 1)
    
    if config.get("screenscraper_username") and config.get("screenscraper_password"):
        max_motors = get_max_motors(
            config["screenscraper_username"],
            config["screenscraper_password"]
        )
        menuitems[5]["max_motors"] = max_motors
    else:
        menuitems[5]["max_motors"] = 1
    
    menuitems[5]["value"] = f"Press A to Start\nMotors: {menuitems[5]['motors']} of {menuitems[5]['max_motors']}"

keyboard = VirtualKeyboard(font_medium)

def progress_callback(p, r):
    global progress, resultados, show_progress_popup
    progress = p
    resultados = r
    show_progress_popup = True
    draw_progress_popup()
    
with open(INPUT_DEVICE, "rb") as dev:
    running = True
    draw_menu()
    while running:
        data = dev.read(24)
        if len(data) < 24:
            continue
        _, _, evtype, code, value = struct.unpack("llHHi", data)
        if progress == 1.0 and show_progress_popup == True:
            if evtype == 1 and value == 1 and (code == 304 or code == 305):
                show_progress_popup = False
                cancel_scraping.clear()
                progress = 0
                resultados = {"success": 0, "fail": 0, "existing": 0}
                continue
        if evtype == 1 and value == 1:
            if code == 305:  # A
                if selected == 3:  # Username
                    user = keyboard.run(screen, dev, prompt="Screenscraper username")
                    if user is not None:
                        menuitems[3]["options"][0] = user
                        menuitems[3]["value"] = user
                        password = menuitems[4].get("real", "")
                        if password:
                            max_motors = get_max_motors(user, password)
                            menuitems[5]["max_motors"] = max_motors
                            menuitems[5]["motors"] = min(menuitems[5].get("motors", 1), max_motors)
                            menuitems[5]["value"] = f"Press A to Start\nMotors: {menuitems[5]['motors']} of {max_motors}"
                            draw_menu()
                elif selected == 4:  # Password
                    password = keyboard.run(screen, dev, prompt="Screenscraper password")
                    if password is not None:
                        menuitems[4]["options"][0] = "*" * len(password)
                        menuitems[4]["value"] = "*" * len(password)
                        menuitems[4]["real"] = password
                        user = menuitems[3]["options"][0]
                        if user:
                            max_motors = get_max_motors(user, password)
                            menuitems[5]["max_motors"] = max_motors
                            menuitems[5]["motors"] = min(menuitems[5].get("motors", 1), max_motors)
                            menuitems[5]["value"] = f"Press A to Start\nMotors: {menuitems[5]['motors']} of {max_motors}"
                            draw_menu()
                elif selected == 5:  # Start Scraping
                    system = menuitems[0]["options"][menuitems[0]["index"]]
                    mediatype = menuitems[1]["options"][menuitems[1]["index"]]
                    region = menuitems[2]["options"][menuitems[2]["index"]]
                    user = menuitems[3]["options"][0]
                    password = menuitems[4].get("real", "")
                    num_motors = menuitems[5]["motors"]
                    save_config(system, mediatype, region, user, password, num_motors)
                    resultados = {"success": 0, "fail": 0, "existing": 0}
                    progress = 0
                    show_progress_popup = True
                    cancel_scraping.clear()
                    t = threading.Thread(target=real_scraper, args=(
                        system, mediatype, region, user, password, num_motors, progress_callback
                    ))
                    t.start()
                    while t.is_alive():
                        if dev.peek(24):
                            d = dev.read(24)
                            _, _, e, c, v = struct.unpack("llHHi", d)
                            if e == 1 and v == 1 and c == 304:  # B
                                cancel_scraping.set()
                            else:
                                continue
                        pygame.time.wait(100)
                    draw_progress_popup()
                    wait_for_close_popup(dev)
                    
                    show_progress_popup = False
                    cancel_scraping.clear()
                    progress = 0
                    resultados = {"success": 0, "fail": 0, "existing": 0}
                    draw_menu()
            elif code == 304:  # B
                    running = False
        elif evtype == 3 and value != 0:
            if code == 17:
                if value == -1:
                    selected = (selected - 1) % len(menuitems)
                elif value == 1:
                    selected = (selected + 1) % len(menuitems)
            elif code == 16:
                if selected == 5:
                    current_motors = menuitems[5]["motors"]
                    max_motors = menuitems[5]["max_motors"]
                    if value == -1:  # Izquierda
                        new_motors = max(1, current_motors - 1)
                    elif value == 1:  # Derecha
                        new_motors = min(max_motors, current_motors + 1)
                    menuitems[5]["motors"] = new_motors
                    menuitems[5]["value"] = f"Press A to Start\nMotors: {new_motors} of {max_motors}"
                    draw_menu()
                elif selected in [0, 1, 2]:
                    opts = menuitems[selected]["options"]
                    if not opts:
                        continue
                    idx = menuitems[selected]["index"]
                    if value == -1:
                        idx = (idx - 1) % len(opts)
                    elif value == 1:
                        idx = (idx + 1) % len(opts)
                    menuitems[selected]["index"] = idx
                    if selected == 1:
                        menuitems[selected]["value"] = MEDIA_TYPE_TO_LABEL[opts[idx]]
                    elif selected == 2:
                        menuitems[selected]["value"] = REGION_LABELS_EN[opts[idx]]
                    else:
                        menuitems[selected]["value"] = opts[idx]
        draw_menu()
        if cancel_scraping.is_set() and show_progress_popup and progress < 1.0:
            progress = 1.0
            draw_progress_popup()

pygame.display.quit()
pygame.quit()
sys.exit()

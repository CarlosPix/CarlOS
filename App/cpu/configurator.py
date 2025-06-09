#!/usr/bin/env python3
import pygame
import struct
import os

os.environ["SDL_NOMOUSE"] = "1"

INPUT_DEVICE = "/dev/input/event5"
CONFIG_PATH = "/userdata/cpuconfig.cfg"

def get_ra_core_set_values():
    base_dir = "/mnt/sdcard/Emu"
    omit_dirs = {"FFPLAY", "PPSSPP", "JAVA", "LOWRES", "NDS", "新建文件夹"}
    try:
        all_dirs = [d for d in os.listdir(base_dir) if os.path.isdir(os.path.join(base_dir, d))]
        filtered_dirs = [d for d in all_dirs if d not in omit_dirs]
        filtered_dirs.sort()
        return ["Generic"] + filtered_dirs
    except Exception:
        return ["Generic"]

menu = [
    {"key": "CPU_GOVERNOR", "label": "CPU Governor", "values": ["ondemand", "interactive", "performance"], "index": 0},
    {"key": "CPU_MAX", "label": "CPU max", "values": ["600000", "816000", "1104000", "1416000", "1608000", "1800000"], "index": 0},
    {"key": "CPU_MIN", "label": "CPU min", "values": ["600000", "816000", "1104000", "1416000", "1608000", "1800000"], "index": 0},
    {"key": "CPU_0", "label": "CPU 0", "values": ["ON", "OFF"], "index": 0},
    {"key": "CPU_1", "label": "CPU 1", "values": ["ON", "OFF"], "index": 0},
    {"key": "CPU_2", "label": "CPU 2", "values": ["ON", "OFF"], "index": 0},
    {"key": "CPU_3", "label": "CPU 3", "values": ["ON", "OFF"], "index": 0},
    {"key": "GPU_GOVERNOR", "label": "GPU Governor", "values": ["dmc_ondemand", "performance"], "index": 0},
    {"key": "SET_CORES", "label": "Set Cores", "values": ["1", "2", "3", "4"], "index": 3},  # por defecto 4 cores activos
    {"key": "RA_CORE_SET", "label": "RA CORE SET", "values": get_ra_core_set_values(), "index": 0}
]
SET_CORES_INDEX = 8
RA_CORE_INDEX = 9

KEYS = {
    304: "B",
    305: "A",
}

HATS = {
    (16, -1): "LEFT",
    (16, 1):  "RIGHT",
    (17, -1): "UP",
    (17, 1):  "DOWN"
}

COLORS = {
    'bg': (15, 25, 45),
    'card_bg': (25, 40, 70),
    'card_border': (50, 80, 120),
    'accent': (0, 200, 255),
    'text_primary': (255, 255, 255),
    'text_secondary': (150, 170, 200),
    'selected': (255, 215, 0),
    'cpu_active': (0, 255, 0),
    'cpu_inactive': (100, 100, 100),
    'cpu_red': (255, 60, 60),
    'cpu_gray': (160, 160, 160),
    'cpu_orange': (255, 140, 0),
    'gpu_color': (100, 200, 255),
    'ra_icon_bg': (0, 0, 0)
}

pygame.init()
screen = pygame.display.set_mode((640, 480))
pygame.display.set_caption("Carl-OS System Utility")
font_large = pygame.font.SysFont("monospace", 36, bold=True)
font_medium = pygame.font.SysFont("monospace", 26, bold=True)
font_small = pygame.font.SysFont("monospace", 18)
font_info = pygame.font.SysFont("monospace", 29, bold=True)
font_icon = pygame.font.SysFont("monospace", 18, bold=True)
font_dynamic = pygame.font.SysFont("monospace", 30, bold=True)
clock = pygame.time.Clock()
pygame.mouse.set_visible(False)

# Ahora todos los recuadros visibles, incluyendo SET_CORES y RA_CORE_SET
VISIBLE_INDICES = [0, 1, 2, SET_CORES_INDEX, 7, RA_CORE_INDEX]
selected_visible = 0

def draw_cpu_icon(surface, x, y, size, color):
    cpu_rect = pygame.Rect(x, y, size, size)
    pygame.draw.rect(surface, color, cpu_rect, 3)
    pin_size = 2
    for i in range(4, size-4, 6):
        pygame.draw.rect(surface, color, (x-3, y+i, pin_size, 4))
        pygame.draw.rect(surface, color, (x+size+1, y+i, pin_size, 4))
        pygame.draw.rect(surface, color, (x+i, y-3, 4, pin_size))
        pygame.draw.rect(surface, color, (x+i, y+size+1, 4, pin_size))
    text = font_icon.render("CPU", True, color)
    text_rect = text.get_rect(center=cpu_rect.center)
    surface.blit(text, text_rect)

def draw_gpu_icon(surface, x, y, size):
    color = COLORS['gpu_color']
    gpu_rect = pygame.Rect(x, y, size, size)
    pygame.draw.rect(surface, color, gpu_rect, 3)
    for i in range(8, size-8, 8):
        pygame.draw.rect(surface, color, (x+size+1, y+i, 6, 3))
    text = font_icon.render("GPU", True, color)
    text_rect = text.get_rect(center=gpu_rect.center)
    surface.blit(text, text_rect)

def draw_ra_icon(surface, x, y, size):
    ra_rect = pygame.Rect(x, y, size, size)
    pygame.draw.rect(surface, COLORS['ra_icon_bg'], ra_rect, 0)
    pygame.draw.rect(surface, COLORS['accent'], ra_rect, 2)
    text = font_icon.render("RA", True, COLORS['text_primary'])
    text_rect = text.get_rect(center=ra_rect.center)
    surface.blit(text, text_rect)

def draw_card(surface, x, y, width, height, title, value, unit="", icon_type="cpu", icon_color=None, is_selected=False):
    card_rect = pygame.Rect(x, y, width, height)
    border_color = COLORS['selected'] if is_selected else COLORS['card_border']
    bg_color = COLORS['card_bg']
    pygame.draw.rect(surface, border_color, card_rect, 2)
    inner_rect = pygame.Rect(x+2, y+2, width-4, height-4)
    pygame.draw.rect(surface, bg_color, inner_rect)
    icon_size = 32
    icon_x = x + 10
    icon_y = y + (height - icon_size) // 2
    if icon_type == "cpu":
        draw_cpu_icon(surface, icon_x, icon_y, icon_size, icon_color or COLORS['cpu_active'])
    elif icon_type == "gpu":
        draw_gpu_icon(surface, icon_x, icon_y, icon_size)
    elif icon_type == "ra":
        draw_ra_icon(surface, icon_x, icon_y, icon_size)
    title_surface = font_medium.render(title, True, COLORS['text_secondary'])
    surface.blit(title_surface, (x + icon_size + 20, y + 8))
    value_text = f"{value} {unit}".strip()
    value_surface = font_dynamic.render(value_text, True, COLORS['text_primary'])
    surface.blit(value_surface, (x + icon_size + 20, y + 32))

def draw_cpu_cores_status(surface):
    start_x = 80
    start_y = 70
    core_size = 48
    spacing = 70
    active_cores = int(menu[SET_CORES_INDEX]['values'][menu[SET_CORES_INDEX]['index']])
    for i in range(4):
        is_active = i < active_cores
        color = COLORS['cpu_active'] if is_active else COLORS['cpu_inactive']
        draw_cpu_icon(surface, start_x + i * spacing, start_y, core_size, color)
    cpu_gov_item = menu[0]
    gov_text = f"CPU x {active_cores}    {cpu_gov_item['values'][cpu_gov_item['index']]}"
    gov_surface = font_info.render(gov_text, True, COLORS['text_primary'])
    last_icon_right = start_x + 4 * spacing
    gov_rect = gov_surface.get_rect(midleft=(last_icon_right + 20, start_y + core_size // 2))
    surface.blit(gov_surface, gov_rect)

def format_frequency(freq_khz):
    try:
        freq_mhz = int(freq_khz) / 1000
        if freq_mhz >= 1000:
            return f"{freq_mhz/1000:.2f} GHz"
        else:
            return f"{freq_mhz:.0f} MHz"
    except Exception:
        return str(freq_khz)

def draw_menu():
    screen.fill(COLORS['bg'])
    title_surface = font_large.render("Carl-OS System Utility", True, COLORS['accent'])
    screen.blit(title_surface, (50, 15))
    pygame.draw.line(screen, COLORS['accent'], (50, 55), (590, 55), 2)
    draw_cpu_cores_status(screen)
    card_width = 250
    card_height = 70
    selected = VISIBLE_INDICES[selected_visible]

    cpu_gov_item = menu[0]
    cpu_gov_value = cpu_gov_item['values'][cpu_gov_item['index']]
    draw_card(screen, 50, 130, card_width, card_height,
              "CPU Governor", cpu_gov_value, "",
              "cpu", COLORS['cpu_active'], selected == 0)
    cpu_max_item = menu[1]
    cpu_freq = format_frequency(cpu_max_item['values'][cpu_max_item['index']])
    draw_card(screen, 340, 130, card_width, card_height,
              "CPU Max", cpu_freq.split()[0], cpu_freq.split()[1],
              "cpu", COLORS['cpu_red'], selected == 1)
    cpu_min_item = menu[2]
    cpu_min_freq = format_frequency(cpu_min_item['values'][cpu_min_item['index']])
    draw_card(screen, 50, 220, card_width, card_height,
              "CPU Min", cpu_min_freq.split()[0], cpu_min_freq.split()[1],
              "cpu", COLORS['cpu_gray'], selected == 2)
    set_cores_item = menu[SET_CORES_INDEX]
    set_cores_value = set_cores_item['values'][set_cores_item['index']]
    draw_card(screen, 340, 220, card_width, card_height,
              "Set Cores", set_cores_value, "",
              "cpu", COLORS['cpu_orange'], selected == SET_CORES_INDEX)
    gpu_gov_item = menu[7]
    gpu_governor = gpu_gov_item['values'][gpu_gov_item['index']]
    draw_card(screen, 50, 310, card_width, card_height,
              "GPU Governor", gpu_governor, "",
              "gpu", None, selected == 7)
    ra_core_item = menu[RA_CORE_INDEX]
    ra_core_value = ra_core_item['values'][ra_core_item['index']]
    draw_card(screen, 340, 310, card_width, card_height,
              "RA CORE SET", ra_core_value, "",
              "ra", COLORS['accent'], selected == RA_CORE_INDEX)

    help_surface = font_medium.render("B = EXIT    |    A = SAVE CONFIG", True, COLORS['text_secondary'])
    screen.blit(help_surface, (80, 420))
    pygame.display.flip()

def show_popup(screen, message, duration=2):
    popup_width, popup_height = 350, 90
    popup_x = (screen.get_width() - popup_width) // 2
    popup_y = (screen.get_height() - popup_height) // 2
    popup_rect = pygame.Rect(popup_x, popup_y, popup_width, popup_height)

    overlay = pygame.Surface((screen.get_width(), screen.get_height()), pygame.SRCALPHA)
    overlay.fill((0, 0, 0, 120))
    screen.blit(overlay, (0, 0))

    pygame.draw.rect(screen, (40, 80, 120), popup_rect)
    pygame.draw.rect(screen, (255, 215, 0), popup_rect, 4)

    popup_font = pygame.font.SysFont("monospace", 32, bold=True)
    text_surface = popup_font.render(message, True, (255, 255, 255))
    text_rect = text_surface.get_rect(center=popup_rect.center)
    screen.blit(text_surface, text_rect)

    pygame.display.flip()

    start = pygame.time.get_ticks()
    while pygame.time.get_ticks() - start < duration * 1000:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                exit()
        clock.tick(60)

def save_config():
    ra_core_item = menu[RA_CORE_INDEX]
    ra_core_value = ra_core_item['values'][ra_core_item['index']]
    if ra_core_value == "Generic":
        config_path = "/userdata/cpuconfig.cfg"
    else:
        config_path = f"/mnt/sdcard/Emu/{ra_core_value}/cpuconfig.cfg"
    try:
        os.makedirs(os.path.dirname(config_path), exist_ok=True)
        with open(config_path, "w") as f:
            for i, item in enumerate(menu):
                # Omitimos los cores y los elementos virtuales
                if item['key'] in ("RA_CORE_SET", "SET_CORES", "CPU_0", "CPU_1", "CPU_2", "CPU_3"):
                    continue
                value = item['values'][item['index']]
                f.write(f"{item['key']}={value}\n")
            # Guardar el estado de los cores según SET_CORES (como en el código funcional)
            num_cores = int(menu[SET_CORES_INDEX]['values'][menu[SET_CORES_INDEX]['index']])
            for i in range(4):
                f.write(f"CPU_{i}={'1' if i < num_cores else '0'}\n")
    except Exception as e:
        print("Error al guardar:", e)

def load_config():
    if not os.path.exists(CONFIG_PATH):
        return
    try:
        with open(CONFIG_PATH, "r") as f:
            config = {}
            for line in f:
                if "=" in line:
                    key, value = line.strip().split("=", 1)
                    config[key] = value
        for item in menu:
            if item['key'] in config:
                value = config[item['key']]
                if item['values'] == ["ON", "OFF"]:
                    value = "ON" if value == "1" else "OFF"
                if value in item['values']:
                    item['index'] = item['values'].index(value)
        # --- NUEVO: Ajustar Set Cores según los CPU_X ---
        core_on = 0
        for i in range(4):
            if config.get(f"CPU_{i}", "0") == "1":
                core_on += 1
        if core_on >= 1 and core_on <= 4:
            menu[SET_CORES_INDEX]['index'] = core_on - 1
        else:
            menu[SET_CORES_INDEX]['index'] = 3  # por defecto 4 cores
    except Exception as e:
        print("Error al cargar configuración:", e)
        
def load_config_file(path):
    if not os.path.exists(path):
        return
    try:
        with open(path, "r") as f:
            config = {}
            for line in f:
                if "=" in line:
                    key, value = line.strip().split("=", 1)
                    config[key] = value
        for item in menu:
            if item['key'] in config:
                value = config[item['key']]
                if item['values'] == ["ON", "OFF"]:
                    value = "ON" if value == "1" else "OFF"
                if value in item['values']:
                    item['index'] = item['values'].index(value)
        # Ajustar Set Cores según los CPU_X
        core_on = 0
        for i in range(4):
            if config.get(f"CPU_{i}", "0") == "1":
                core_on += 1
        if core_on >= 1 and core_on <= 4:
            menu[SET_CORES_INDEX]['index'] = core_on - 1
        else:
            menu[SET_CORES_INDEX]['index'] = 3
    except Exception as e:
        print("Error al cargar configuración:", e)


with open(INPUT_DEVICE, "rb") as dev:
    load_config()
    draw_menu()
    while True:
        data = dev.read(24)
        if len(data) < 24:
            continue
        _, _, ev_type, code, value = struct.unpack("llHHi", data[:32])
        if ev_type == 1:
            if code in KEYS:
                if value == 1:
                    if KEYS[code] == "A":
                        save_config()
                        show_popup(screen, "Configuration set")
                        draw_menu()
                    elif KEYS[code] == "B":
                        break
        elif ev_type == 3:
            if value == 0:
                continue
            if (code, value) in HATS:
                direction = HATS[(code, value)]
                if direction == "UP":
                    selected_visible = (selected_visible - 1) % len(VISIBLE_INDICES)
                elif direction == "DOWN":
                    selected_visible = (selected_visible + 1) % len(VISIBLE_INDICES)
                elif direction in ("LEFT", "RIGHT"):
                    selected = VISIBLE_INDICES[selected_visible]
                    if selected == SET_CORES_INDEX:
                        # Cambia solo Set Cores
                        idx = menu[SET_CORES_INDEX]['index']
                        if direction == "LEFT":
                            idx = max(0, idx - 1)
                        else:
                            idx = min(3, idx + 1)
                        menu[SET_CORES_INDEX]['index'] = idx
                    elif selected == RA_CORE_INDEX:
                        # Cambia solo RA CORE SET
                        idx = menu[RA_CORE_INDEX]['index']
                        if direction == "LEFT":
                            idx = (idx - 1) % len(menu[RA_CORE_INDEX]['values'])
                        else:
                            idx = (idx + 1) % len(menu[RA_CORE_INDEX]['values'])
                        menu[RA_CORE_INDEX]['index'] = idx
                        
                        core_name = menu[RA_CORE_INDEX]['values'][idx]
                        if core_name == "Generic":
                            load_config_file("/userdata/cpuconfig.cfg")
                        else:
                            load_config_file(f"/mnt/sdcard/Emu/{core_name}/cpuconfig.cfg")
                    elif selected == 1:
                        if direction == "LEFT":
                            menu[1]["index"] = (menu[1]["index"] - 1) % len(menu[1]["values"])
                        else:
                            menu[1]["index"] = (menu[1]["index"] + 1) % len(menu[1]["values"])
                        if menu[2]["index"] > menu[1]["index"]:
                            menu[2]["index"] = menu[1]["index"]
                    elif selected == 2:
                        max_index = menu[1]["index"]
                        if direction == "LEFT":
                            if menu[2]["index"] > 0:
                                menu[2]["index"] -= 1
                        else:
                            if menu[2]["index"] < max_index:
                                menu[2]["index"] += 1
                    else:
                        menu[selected]["index"] = (menu[selected]["index"] - 1) % len(menu[selected]["values"]) if direction == "LEFT" else (menu[selected]["index"] + 1) % len(menu[selected]["values"])
                draw_menu()
        clock.tick(60)

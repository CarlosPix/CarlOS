#!/usr/bin/env python3

import subprocess as SU
import sys
import time
import os
import shutil
import pygame
from pygame.locals import *
import pygame.gfxdraw
from os import listdir
from urllib.parse import quote_plus, unquote_plus  # Python 3

SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480

start_color = (0, 0, 0)
end_color = (80, 0, 0)
duration = 10 * 1000
steps = 100

def initialize_pygame():
    if not pygame.display.get_init():
        pygame.display.init()
    if not pygame.font.get_init():
        pygame.font.init()
    pygame.mouse.set_visible(False)
    return pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))

def calculate_color(start_color, end_color, duration, steps):
    colors = []
    r_step = float(end_color[0] - start_color[0]) / (steps / 2)
    g_step = float(end_color[1] - start_color[1]) / (steps / 2)
    b_step = float(end_color[2] - start_color[2]) / (steps / 2)
    for step in range(steps):
        if step < steps / 2:
            r = start_color[0] + int(r_step * step)
            g = start_color[1] + int(g_step * step)
            b = start_color[2] + int(b_step * step)
        else:
            r = end_color[0] - int(r_step * (step - steps / 2))
            g = end_color[1] - int(g_step * (step - steps / 2))
            b = end_color[2] - int(b_step * (step - steps / 2))
        colors.append((r, g, b))
    return colors

def get_ip_address():
    try:
        output = SU.check_output(["/sbin/ifconfig", "wlan0"], stderr=SU.DEVNULL).decode()
        for line in output.splitlines():
            line = line.strip()
            if line.startswith("inet ") or "inet addr" in line:
                # Python 3: 'inet addr:' para ifconfig antiguo, 'inet ' para moderno
                if "inet addr" in line:
                    ip = line.split()[1].split(":")[1]
                else:
                    ip = line.split()[1]
                return ip
    except Exception as e:
        pass
    return None

def display_data(screen, font):
    center_x = SCREEN_WIDTH // 2

    title_text = font.render("CarlOS SSH server", True, (255, 255, 255))
    title_text_rect = title_text.get_rect(center=(center_x, 30))
    screen.blit(title_text, title_text_rect)

    ip_address = get_ip_address()
    if ip_address is None:
        warning_text = font.render("Connect to a WiFi network", True, (255, 0, 0))
        warning_text_rect = warning_text.get_rect(center=(center_x, SCREEN_HEIGHT // 2))
        screen.blit(warning_text, warning_text_rect)
    else:
        ip_text = font.render(f'type "ssh carl-os@{ip_address}" in the terminal', True, (255, 255, 255))
        ip_password = font.render('password "Carl-OS"', True, (255, 255, 255))
        or_text = font.render('or', True, (255, 255, 255))
        root_text = font.render(f'type "ssh root@{ip_address}" in the terminal', True, (255, 255, 255))
        root_password = font.render('password "root"', True, (255, 255, 255))

        ip_text_rect = ip_text.get_rect(center=(center_x, SCREEN_HEIGHT // 2 - 50))
        ip_password_rect = ip_password.get_rect(center=(center_x, SCREEN_HEIGHT // 2 - 25))
        or_text_rect = or_text.get_rect(center=(center_x, SCREEN_HEIGHT // 2))
        root_text_rect = root_text.get_rect(center=(center_x, SCREEN_HEIGHT // 2 + 25))
        root_password_rect = root_password.get_rect(center=(center_x, SCREEN_HEIGHT // 2 + 50))

        screen.blit(ip_text, ip_text_rect)
        screen.blit(ip_password, ip_password_rect)
        screen.blit(or_text, or_text_rect)
        screen.blit(root_text, root_text_rect)
        screen.blit(root_password, root_password_rect)

    exit_text = font.render("Press menu button for exit", True, (255, 255, 255))
    exit_text_rect = exit_text.get_rect(midbottom=(center_x, SCREEN_HEIGHT - 10))
    screen.blit(exit_text, exit_text_rect)

def start_ssh_server():
    start_ssh_command = "dropbear -R -B -b /mnt/SDCARD/App/ssh/banner.txt"
    SU.Popen(start_ssh_command, shell=True)

def stop_ssh_server():
    try:
        with open('/var/run/dropbear.pid', 'r') as f:
            dropbear_pid = f.read().strip()
        stop_ssh_command = f"kill {dropbear_pid}"
        SU.Popen(stop_ssh_command, shell=True)
    except Exception as e:
        print(f"Error stopping SSH server: {e}")

def main():
    os.environ['SDL_NOMOUSE'] = '1'

    screen = initialize_pygame()
    font = pygame.font.SysFont(None, 30)
    start_ssh_server()
    colors = calculate_color(start_color, end_color, duration, steps)
    color_index = 0
    running = True

    pygame.joystick.init()
    joystick = None
    if pygame.joystick.get_count() > 0:
        joystick = pygame.joystick.Joystick(0)
        joystick.init()

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                stop_ssh_server()
                running = False
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    stop_ssh_server()
                    running = False
            elif event.type == pygame.JOYBUTTONDOWN:
                if event.button == 8:
                    stop_ssh_server()
                    running = False

        screen.fill(colors[color_index])
        color_index = (color_index + 1) % len(colors)
        display_data(screen, font)
        pygame.display.update()
        time.sleep(0.033)

    pygame.quit()
    sys.exit()

if __name__ == "__main__":
    main()

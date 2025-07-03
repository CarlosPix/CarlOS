import json
import os
import glob

SHOW_JSON = "/mnt/SDCARD/Emu/show.json"
EMU_BASE = "/mnt/SDCARD/Emu"
ROMS_BASE = "/mnt/SDCARD/Roms"

def main():
    if not os.path.exists(SHOW_JSON):
        show_data = []
        for system_dir in os.listdir(EMU_BASE):
            system_path = os.path.join(EMU_BASE, system_dir)
            if not os.path.isdir(system_path):
                continue
            config_path = os.path.join(system_path, "config.json")
            if not os.path.exists(config_path):
                continue
            try:
                with open(config_path, 'r', encoding='utf-8') as f:
                    content = f.read().strip()
                    if not content.startswith('{'):
                        lines = [line.strip().rstrip(',') for line in content.split('\n') if line.strip()]
                        config_str = '{' + ','.join(lines) + '}'
                    else:
                        config_str = content
                    try:
                        config = json.loads(config_str)
                    except json.JSONDecodeError:
                        continue
                label = config.get("label")
                if not label:
                    continue
                show_data.append({"label": label, "show": 1})
            except Exception:
                continue
        with open(SHOW_JSON, 'w', encoding='utf-8') as f:
            json.dump(show_data, f, indent=2)
        print("show.json creado desde cero.")

    with open(SHOW_JSON, 'r', encoding='utf-8') as f:
        show_data = json.load(f)

    label_to_system = {item["label"]: item for item in show_data}

    for system_dir in os.listdir(EMU_BASE):
        system_path = os.path.join(EMU_BASE, system_dir)
        if not os.path.isdir(system_path):
            continue
        config_path = os.path.join(system_path, "config.json")
        if not os.path.exists(config_path):
            continue
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                content = f.read().strip()
                if not content.startswith('{'):
                    lines = [line.strip().rstrip(',') for line in content.split('\n') if line.strip()]
                    config_str = '{' + ','.join(lines) + '}'
                else:
                    config_str = content
                try:
                    config = json.loads(config_str)
                except json.JSONDecodeError:
                    continue
            label = config.get("label")
            if not label:
                continue
            if label not in label_to_system:
                show_data.append({"label": label, "show": 1})
                label_to_system[label] = show_data[-1]
            if (label == "FFPLAY" or label == "MPV") and "rompathlist" in config:
                extensions = config.get("extlist", "").split('|')
                files = []
                for rompath_item in config["rompathlist"]:
                    rompath = rompath_item.get("rompath", "")
                    abs_rompath = os.path.abspath(os.path.join(system_path, rompath))
                    if not os.path.isdir(abs_rompath):
                        continue
                    for ext in extensions:
                        files.extend(glob.glob(os.path.join(abs_rompath, '**', f'*.{ext}'), recursive=True))
                        if files:
                            break
                    if files:
                        break
                label_to_system[label]["show"] = 1 if files else 0
            else:
                rompath = config.get("rompath", "")
                extlist = config.get("extlist", "")
                if not rompath or not extlist:
                    label_to_system[label]["show"] = 0
                    continue
                rom_folder = os.path.basename(rompath.rstrip('/'))
                abs_rompath = os.path.join(ROMS_BASE, rom_folder)
                if not os.path.isdir(abs_rompath):
                    label_to_system[label]["show"] = 0
                    continue
                extensions = extlist.split('|')
                files = []
                for ext in extensions:
                    files.extend(glob.glob(os.path.join(abs_rompath, '**', f'*.{ext}'), recursive=True))
                    if files:
                        break
                label_to_system[label]["show"] = 1 if files else 0
        except Exception:
            continue

    with open(SHOW_JSON, 'w', encoding='utf-8') as f:
        json.dump(show_data, f, indent=2)

if __name__ == "__main__":
    main()

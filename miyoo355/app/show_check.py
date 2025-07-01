import json
import os
import glob

SHOW_JSON = "/mnt/SDCARD/Emu/show.json"
EMU_BASE = "/mnt/SDCARD/Emu"
ROMS_BASE = "/mnt/SDCARD/Roms"

def main():
    with open(SHOW_JSON, 'r', encoding='utf-8') as f:
        show_data = json.load(f)

    for item in show_data:
        system_label = item["label"]
        system_dir = os.path.join(EMU_BASE, system_label.replace(" ", ""))

        config_path = os.path.join(system_dir, "config.json")
        if not os.path.exists(config_path):
            item["show"] = 0
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
                    item["show"] = 0
                    continue

            if system_label == "FFPLAY" and "rompathlist" in config:
                extensions = config.get("extlist", "").split('|')
                files = []
                for rompath_item in config["rompathlist"]:
                    rompath = rompath_item.get("rompath", "")
                    abs_rompath = os.path.abspath(os.path.join(system_dir, rompath))
                    if not os.path.isdir(abs_rompath):
                        continue
                    for ext in extensions:
                        files.extend(glob.glob(os.path.join(abs_rompath, '**', f'*.{ext}'), recursive=True))
                        if files: break
                    if files: break
                item["show"] = 1 if files else 0
            else:
                rompath = config.get("rompath", "")
                extlist = config.get("extlist", "")
                if not rompath or not extlist:
                    item["show"] = 0
                    continue

                abs_rompath = os.path.abspath(os.path.join(system_dir, rompath))
                if not os.path.isdir(abs_rompath):
                    item["show"] = 0
                    continue

                extensions = extlist.split('|')
                files = []
                for ext in extensions:
                    files.extend(glob.glob(os.path.join(abs_rompath, '**', f'*.{ext}'), recursive=True))
                    if files: break

                item["show"] = 1 if files else 0

        except Exception as e:
            item["show"] = 0
            continue

    with open(SHOW_JSON, 'w', encoding='utf-8') as f:
        json.dump(show_data, f, indent=2)

if __name__ == "__main__":
    main()

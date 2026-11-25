#!/usr/bin/env python3
"""Point app launchers whose icon WhiteSur doesn't cover (snap apps, AppImages,
apps with absolute icon paths) at a matching WhiteSur icon.

Overrides go to ~/.local/share/applications. Each changed file gets
X-Linux2macos-Original-Icon so restore.sh can undo it; launchers that already
lived there are also copied to ~/.config/linux2macos/backup/applications.
"""
import configparser
import glob
import os
import re
import shutil
import sys

HOME = os.path.expanduser("~")
LOCAL = f"{HOME}/.local/share/applications"
BACKUP = f"{HOME}/.config/linux2macos/backup/applications"
ICON_THEMES = [f"{HOME}/.local/share/icons/WhiteSur", f"{HOME}/.local/share/icons/WhiteSur-dark"]
# Highest precedence first: a launcher in LOCAL hides the system one with the same name.
SOURCES = [
    LOCAL,
    f"{HOME}/.local/share/flatpak/exports/share/applications",
    "/var/lib/flatpak/exports/share/applications",
    "/var/lib/snapd/desktop/applications",
    "/usr/share/applications",
]
# Launcher id or icon stem -> WhiteSur icon name, for names that don't match.
ALIASES = {
    "obs-studio": "com.obsproject.Studio",
    "firmware-updater": "org.gnome.Firmware",
    "ppsspp-emulator": "ppsspp",
    "studio": "android-studio",
    "app-center": "snap-store",
    "claude-desktop": "claude",
    "code": "visual-studio-code",
    "libreoffice": "libreoffice-startcenter",
}
MARK = "X-Linux2macos-Original-Icon"


def theme_icons():
    names = set()
    for t in ICON_THEMES:
        for root, _, files in os.walk(t):
            for f in files:
                names.add(os.path.splitext(f)[0])
    return names


def candidates(desktop_id, icon, name):
    stem = os.path.splitext(os.path.basename(icon))[0]
    stem = re.sub(r"\d+(\.\d+)*", "", stem).strip("-_.")  # libreoffice26.8-calc -> libreoffice-calc
    out = [stem, desktop_id]
    if "_" in desktop_id:  # snap: <snap>_<app>
        snap, app = desktop_id.split("_", 1)
        out += [app, snap, f"{snap}-{app}" if app != snap else snap]
        if snap == "libreoffice":
            out.insert(0, "libreoffice-startcenter" if app == "libreoffice" else f"libreoffice-{app}")
    out.append(name.lower().replace(" ", "-"))
    return [ALIASES.get(c, c) for c in out if c]


def main():
    icons = theme_icons()
    if not icons:
        sys.exit("Ikon WhiteSur belum terpasang; jalankan modul 'icons' dulu.")
    os.makedirs(LOCAL, exist_ok=True)
    seen, changed = set(), 0
    for src_dir in SOURCES:
        for path in sorted(glob.glob(f"{src_dir}/*.desktop")):
            fname = os.path.basename(path)
            if fname in seen:
                continue
            seen.add(fname)
            desktop_id = fname[: -len(".desktop")]
            # Browser web apps and Waydroid's Android apps keep their own icons.
            if re.match(r"^(chrome|brave|msedge|chromium)-[a-p]{32}", desktop_id) or desktop_id.startswith("waydroid."):
                continue
            cp = configparser.RawConfigParser(strict=False, interpolation=None)
            cp.optionxform = str
            try:
                cp.read(path, encoding="utf-8")
            except (configparser.Error, UnicodeDecodeError):
                continue
            if not cp.has_section("Desktop Entry"):
                continue
            e = cp["Desktop Entry"]
            if e.get("NoDisplay", "").lower() == "true" or e.get(MARK):
                continue
            icon = e.get("Icon", "")
            if not icon or (not icon.startswith("/") and icon in icons):
                continue
            target = next((c for c in candidates(desktop_id, icon, e.get("Name", "")) if c in icons), None)
            if not target:
                print(f"  - {e.get('Name', desktop_id)}: tidak ada ikon WhiteSur yang cocok")
                continue

            dst = f"{LOCAL}/{fname}"
            if os.path.exists(dst):
                os.makedirs(BACKUP, exist_ok=True)
                shutil.copy2(dst, f"{BACKUP}/{fname}")
            with open(path, encoding="utf-8") as fh:
                text = fh.read()
            text = re.sub(r"(?m)^Icon=.*$", f"Icon={target}", text)
            text = text.replace("[Desktop Entry]\n", f"[Desktop Entry]\n{MARK}={icon}\n", 1)
            with open(dst + ".tmp", "w", encoding="utf-8") as fh:
                fh.write(text)
            os.replace(dst + ".tmp", dst)
            changed += 1
            print(f"  + {e.get('Name', desktop_id)}: {target}")
    print(f"{changed} ikon aplikasi diseragamkan")


if __name__ == "__main__":
    main()

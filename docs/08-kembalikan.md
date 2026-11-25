# 8. Mengembalikan ke Tampilan Semula

## Restore pengaturan

```bash
./scripts/restore.sh
```

Yang dilakukan:

1. **Reset** semua kunci dconf yang pernah diubah linux2macos (lihat `DCONF_KEYS` dan `DCONF_DIRS` di `scripts/lib/common.sh`), lalu **memuat** snapshot `backup/original/dconf.ini`.
2. Melepas symlink tema di `~/.config/gtk-4.0`.
3. Menghapus blok Starship/fastfetch dari `~/.bashrc`.
4. Mengembalikan launcher aplikasi yang ikonnya diubah.
5. Mengembalikan `Preferences` Chrome/Brave (browser harus tertutup).

Lalu muat ulang GNOME Shell (X11: <kbd>Alt</kbd>+<kbd>F2</kbd> → `r`; Wayland: log out).

### Kenapa tidak cukup `dconf load`?

`dconf dump` hanya mencatat pengaturan yang **pernah diubah** dari bawaan. Pengaturan yang dulu masih default (misalnya posisi dock, kursor, tombol jendela) **tidak ada** di backup, sehingga `dconf load` saja tidak mengembalikannya. Karena itu `restore.sh` me‑*reset* dulu semua kunci yang disentuh, baru memuat backup.

## Hapus semua file sekaligus

```bash
./scripts/restore.sh --purge
```

Selain restore, juga menghapus tema, ikon, kursor, wallpaper WhiteSur, font Inter & JetBrainsMono Nerd, kelima ekstensi, `~/.local/bin/starship`, `~/.local/bin/fastfetch`, dan cache unduhan. `~/.config/starship.toml` dan folder backup tetap disimpan.

## Restore dari backup tertentu

Setiap kali `install.sh` dijalankan, backup baru dibuat:

```
~/.config/linux2macos/backup/
├── original -> 20261125-091000   # sebelum instalasi pertama (tidak pernah ditimpa)
├── latest   -> 20261126-080000   # backup terakhir
├── 20261125-091000/
│   ├── dconf.ini
│   ├── bashrc
│   └── gtk-4.0/
├── applications/                 # launcher asli yang ditimpa fix-app-icons
└── browser-prefs/                # Preferences asli Chrome/Brave
```

```bash
./scripts/restore.sh --from ~/.config/linux2macos/backup/latest
```

## Kembalikan sebagian saja

| Ingin mengembalikan | Perintah |
|---|---|
| Tema | `gsettings reset org.gnome.desktop.interface gtk-theme; gsettings reset org.gnome.desktop.interface color-scheme; rm ~/.config/gtk-4.0/{gtk.css,gtk-dark.css,assets}` |
| Ikon | `gsettings reset org.gnome.desktop.interface icon-theme` |
| Kursor | `gsettings reset org.gnome.desktop.interface cursor-theme` |
| Font | `gsettings reset org.gnome.desktop.interface font-name; gsettings reset org.gnome.desktop.interface document-font-name` |
| Dock | `dconf reset -f /org/gnome/shell/extensions/dash-to-dock/` |
| Tombol jendela | `gsettings reset org.gnome.desktop.wm.preferences button-layout` |
| Satu ekstensi | `gnome-extensions disable <uuid>` |
| Browser | `./scripts/browser-gtk.sh --undo` |
| Terminal | Hapus blok `# >>> linux2macos terminal >>>` di `~/.bashrc`; `dconf reset -f /org/gnome/terminal/legacy/profiles:/:<uuid>/` |

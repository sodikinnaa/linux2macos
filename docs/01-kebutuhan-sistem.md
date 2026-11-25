# 1. Kebutuhan Sistem

## Sistem operasi

| Komponen | Didukung | Catatan |
|---|---|---|
| Distro | **Ubuntu 24.04 LTS** (diuji) | Ubuntu 23.10/24.10/25.04, Pop!_OS, Zorin, Fedora GNOME kemungkinan besar jalan |
| Desktop | **GNOME Shell 45–47** | Diuji di GNOME 46. KDE, XFCE, Cinnamon **tidak** didukung |
| Sesi | **X11** (diuji) atau Wayland | Di Wayland, GNOME Shell tidak bisa dimuat ulang dengan Alt+F2 → r; harus log out |
| Arsitektur | x86_64 | Starship & fastfetch yang diunduh adalah build x86_64 |

Cek versi kamu:

```bash
lsb_release -d; gnome-shell --version; echo $XDG_SESSION_TYPE
```

## Hardware

| Komponen | Minimal | Disarankan |
|---|---|---|
| RAM | 4 GB | 8 GB+ |
| GPU | Intel HD 500‑an, driver Mesa | GPU dengan driver resmi (NVIDIA proprietary / Mesa terbaru) |
| Penyimpanan | ~400 MB kosong | 1 GB |

Efek blur dan Magic Lamp memakai GPU. Di GPU lemah, ikuti [Performa](06-performa.md).

## Paket yang harus ada

Biasanya sudah terpasang di Ubuntu Desktop. Kalau ada yang kurang:

```bash
sudo apt install -y git curl unzip python3 dconf-cli fontconfig gnome-shell-extension-prefs
```

| Perintah | Dipakai untuk |
|---|---|
| `git` | Mengunduh tema, ikon, kursor, wallpaper WhiteSur |
| `curl` | Mengunduh font, ekstensi, Starship, fastfetch |
| `unzip`, `tar` | Mengekstrak arsip |
| `python3` | Mengubah file `.desktop` dan Preferences browser |
| `dconf`, `gsettings` | Mengubah pengaturan GNOME |
| `gnome-extensions` | Memasang ekstensi (bagian dari GNOME Shell) |
| `fc-cache` | Mendaftarkan font baru |
| *Extension Manager* / *Extensions* (opsional) | Mengatur ekstensi lewat GUI |

**Tidak** perlu `sudo` untuk script ini. `sassc` juga tidak perlu karena tema memakai rilis WhiteSur yang sudah jadi.

## Koneksi internet

Total unduhan sekitar **250 MB**:

| Sumber | Ukuran kira‑kira |
|---|---|
| github.com/vinceliuice (WhiteSur gtk, icon, cursors, wallpapers) | ~120 MB (clone `--depth 1`) |
| github.com/ryanoasis/nerd-fonts (JetBrainsMono.zip) | ~130 MB |
| github.com/rsms/inter | ~5 MB |
| extensions.gnome.org (5 ekstensi) | ~1 MB |
| Starship + fastfetch | ~7 MB |

Hasil clone disimpan di `~/.cache/linux2macos/src`, jadi menjalankan ulang tidak mengunduh dari awal.

## Lokasi file yang dipasang

| Isi | Lokasi |
|---|---|
| Tema GTK/Shell | `~/.themes/WhiteSur-Dark`, `~/.themes/WhiteSur-Light` |
| Tema GTK4 (libadwaita) | symlink di `~/.config/gtk-4.0/` |
| Ikon & kursor | `~/.local/share/icons/WhiteSur`, `WhiteSur-dark`, `WhiteSur-cursors` |
| Logo Apple | `~/.local/share/icons/linux2macos/apple-logo.svg` |
| Wallpaper | `~/.local/share/backgrounds/WhiteSur*.jpg` |
| Font | `~/.local/share/fonts/Inter`, `~/.local/share/fonts/JetBrainsMonoNerd` |
| Ekstensi | `~/.local/share/gnome-shell/extensions/` |
| Override ikon aplikasi | `~/.local/share/applications/*.desktop` (bertanda `X-Linux2macos-Original-Icon`) |
| Starship & fastfetch | `~/.local/bin/` |
| Konfigurasi Starship | `~/.config/starship.toml` |
| Backup | `~/.config/linux2macos/backup/` |

## Sebelum mulai

1. **Simpan pekerjaan** di aplikasi yang terbuka. GNOME Shell akan dimuat ulang.
2. Pastikan `~/.local/bin` ada di `PATH` (default Ubuntu sudah). Cek: `echo $PATH | tr : '\n' | grep local/bin`.
3. Script membuat backup otomatis. Backup pertama disimpan sebagai `backup/original` dan **tidak pernah ditimpa**.

# linux2macos

Ubah tampilan **Ubuntu (GNOME)** agar terlihat dan terasa seperti **macOS**: tema WhiteSur, dock di bawah, logo Apple di pojok kiri atas, efek minimize *Magic Lamp*, blur, font mirip SF Pro, sampai tombol jendela merah‑kuning‑hijau di Chrome/Brave.

Semua dipasang di folder **home** kamu: **tanpa `sudo`**, bisa dijalankan per bagian, dan bisa **dikembalikan** dengan satu perintah.

> Diuji di **Ubuntu 24.04 LTS, GNOME Shell 46, X11**, NVIDIA GTX 1650 Super. Distro lain berbasis GNOME 45–47 kemungkinan besar jalan, lihat [Kebutuhan Sistem](docs/01-kebutuhan-sistem.md).

---

## Hasil akhir

| Bagian | Sebelum (Ubuntu) | Sesudah (linux2macos) |
|---|---|---|
| Tema jendela | Yaru | WhiteSur Dark (GTK3, GTK4/libadwaita, GNOME Shell) |
| Tombol jendela | Kanan: `– □ ×` | Kiri: ● ● ● (close, minimize, maximize) |
| Top bar | Titik workspace di kiri, jam di tengah | Logo Apple + menu di kiri, jam + hari di kanan, blur |
| Dock | Kiri, penuh tinggi layar | Bawah tengah, transparan + blur, auto‑hide, titik indikator, Launchpad di kiri |
| Animasi minimize | Bawaan GNOME | *Magic Lamp* (genie) 0,3 detik |
| Ikon & kursor | Yaru | WhiteSur (termasuk aplikasi snap/AppImage) |
| Font | Ubuntu Sans | Inter (pengganti SF Pro yang bebas lisensi) |
| Wallpaper | Ubuntu | WhiteSur (terang/gelap otomatis) |
| Terminal | Default | JetBrainsMono Nerd Font, warna pastel, prompt Starship, fastfetch |
| Chrome/Brave | Tombol bawaan Chrome | Tema GTK: tombol ikut WhiteSur |
| Login | Masuk ke Overview | Langsung ke desktop, jendela baru di tengah |

---

## Instalasi cepat

```bash
sudo apt install -y git curl unzip python3 python3-venv gnome-shell-extension-prefs
git clone https://github.com/sodikinnaa/linux2macos.git
cd linux2macos
./scripts/install.sh
```

Lalu muat ulang GNOME Shell:

- **X11**: tekan <kbd>Alt</kbd>+<kbd>F2</kbd>, ketik `r`, <kbd>Enter</kbd> (aplikasi tetap terbuka)
- **Wayland**: log out lalu login lagi

Terakhir, tutup penuh Chrome/Brave (<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Q</kbd>) lalu jalankan:

```bash
./scripts/browser-gtk.sh
```

Panduan lengkap ada di [docs/02-instalasi.md](docs/02-instalasi.md).

### Pasang sebagian saja

```bash
./scripts/install.sh --help              # daftar modul
./scripts/install.sh theme icons dock    # contoh: hanya tema, ikon, dock
```

| Modul | Isi |
|---|---|
| `theme` | Tema GTK & Shell WhiteSur Dark (top bar di-compile sesuai versi GNOME) |
| `icons` | Ikon WhiteSur |
| `cursors` | Kursor WhiteSur |
| `wallpaper` | Wallpaper WhiteSur sesuai resolusi layar |
| `fonts` | Inter + JetBrainsMono Nerd Font |
| `dock` | Dock ala macOS |
| `extensions` | User Themes, Blur my Shell, Magic Lamp, Logo Menu, Just Perfection |
| `window` | Tombol jendela di kiri, jendela baru di tengah |
| `app-icons` | Seragamkan ikon aplikasi snap/AppImage |
| `terminal` | Warna terminal, Starship, fastfetch |
| `browser` | Chrome/Brave/Chromium/Edge ke tema GTK |

## Kembalikan ke semula

```bash
./scripts/restore.sh            # kembalikan pengaturan
./scripts/restore.sh --purge    # sekaligus hapus semua file yang diunduh
```

Detail: [docs/08-kembalikan.md](docs/08-kembalikan.md).

---

## Dokumentasi

| # | Dokumen | Isi |
|---|---|---|
| 1 | [Kebutuhan Sistem](docs/01-kebutuhan-sistem.md) | OS, hardware, paket, koneksi, apa saja yang diunduh |
| 2 | [Instalasi](docs/02-instalasi.md) | Langkah demi langkah dengan script |
| 3 | [Panduan Manual](docs/03-panduan-manual.md) | Semua langkah tanpa script, perintah per perintah |
| 4 | [Ekstensi GNOME](docs/04-ekstensi-gnome.md) | Fungsi & pengaturan setiap ekstensi |
| 5 | [Browser & Terminal](docs/05-browser-terminal.md) | Tombol ala Mac di Chrome/Brave, terminal Starship |
| 6 | [Performa](docs/06-performa.md) | Agar tetap ringan & tidak ngelag |
| 7 | [Login & Boot (opsional, sudo)](docs/07-login-boot.md) | Layar login (GDM) dan animasi boot |
| 8 | [Kembalikan](docs/08-kembalikan.md) | Restore, purge, backup |
| 9 | [Troubleshooting & FAQ](docs/09-troubleshooting.md) | Masalah umum dan solusinya |
| 10 | [Kredit & Lisensi](docs/10-kredit.md) | Proyek pihak ketiga yang dipakai |

## Struktur repo

```
linux2macos/
├── README.md
├── docs/                    # panduan lengkap (Bahasa Indonesia)
└── scripts/
    ├── install.sh           # pemasang modular
    ├── restore.sh           # kembalikan pengaturan (+ --purge)
    ├── browser-gtk.sh       # Chrome/Brave → tema GTK (--wait, --undo)
    └── lib/
        ├── common.sh        # path, daftar ekstensi & kunci dconf yang diubah
        └── fix-app-icons.py # seragamkan ikon launcher aplikasi
```

## Catatan

- Proyek ini hanya **mengubah tampilan**; sistem tetap Ubuntu. Aplikasi macOS tidak bisa dijalankan.
- Logo Apple dan nama macOS adalah merek dagang Apple Inc. Logo diambil dari aset tema WhiteSur dan tidak disimpan di repo ini.
- Global menu bar (menu File/Edit di top bar) dan zoom ikon dock (*magnification*) **tidak** dipasang karena tidak stabil di GNOME 46. Lihat [FAQ](docs/09-troubleshooting.md#faq).

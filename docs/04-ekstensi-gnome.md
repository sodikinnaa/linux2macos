# 4. Ekstensi GNOME

Lima ekstensi dipasang dari [extensions.gnome.org](https://extensions.gnome.org) sesuai versi GNOME Shell kamu.

| Ekstensi | UUID | Fungsi |
|---|---|---|
| [User Themes](https://extensions.gnome.org/extension/19/user-themes/) | `user-theme@gnome-shell-extensions.gcampax.github.com` | Menerapkan tema WhiteSur ke top bar, menu, notifikasi, overview |
| [Blur my Shell](https://extensions.gnome.org/extension/3193/blur-my-shell/) | `blur-my-shell@aunetx` | Efek blur di top bar, dock, overview |
| [Compiz alike Magic Lamp Effect](https://extensions.gnome.org/extension/3740/compiz-alike-magic-lamp-effect/) | `compiz-alike-magic-lamp-effect@hermes83.github.com` | Animasi minimize "tersedot" ke dock (genie) |
| [Logo Menu](https://extensions.gnome.org/extension/4451/logo-menu/) | `logomenu@aryan_k` | Logo + menu di pojok kiri atas seperti menu Apple |
| [Just Perfection](https://extensions.gnome.org/extension/3843/just-perfection/) | `just-perfection-desktop@just-perfection` | Memindah jam ke kanan, menyembunyikan tombol Activities, dll. |

Ubuntu Dock, Desktop Icons (ding), AppIndicator, dan Tiling Assistant adalah ekstensi bawaan Ubuntu dan tetap aktif.

> Ekstensi baru hanya terbaca setelah GNOME Shell dimuat ulang. `gnome-extensions enable` sebelum itu akan menjawab *"does not exist"*. Itu normal. Script menambahkan UUID ke `enabled-extensions` sehingga ekstensi otomatis aktif setelah dimuat ulang.

---

## Pengaturan yang dipakai

Semua bisa diubah lewat aplikasi **Extensions** / **Extension Manager** (ikon ⚙ di tiap ekstensi), atau dengan perintah di bawah.

### User Themes

```bash
dconf write /org/gnome/shell/extensions/user-theme/name "'WhiteSur-Dark'"
```

### Blur my Shell

Blur **statis** dipakai di top bar & dock karena jauh lebih ringan dari blur dinamis. Blur di jendela aplikasi dimatikan karena paling berat.

```bash
B=/org/gnome/shell/extensions/blur-my-shell
dconf write $B/sigma 25
dconf write $B/panel/blur true;        dconf write $B/panel/static-blur true
dconf write $B/dash-to-dock/blur true; dconf write $B/dash-to-dock/static-blur true
dconf write $B/overview/blur true
dconf write $B/appfolder/blur true
dconf write $B/applications/blur false
dconf write $B/screenshot/blur false
dconf write $B/window-list/blur false
```

### Magic Lamp

Path schema ekstensi ini memang diawali `ncom` (bukan salah ketik).

```bash
M=/org/gnome/shell/extensions/ncom/github/hermes83/compiz-alike-magic-lamp-effect
dconf write $M/duration 300.0   # milidetik; bawaan 400
dconf write $M/x-tiles 8.0      # makin kecil makin ringan; bawaan 10
dconf write $M/y-tiles 8.0
```

Pilihan `effect`: `"default"` (genie) atau `"sine"` (gelombang).

### Logo Menu (logo Apple)

Logo Menu tidak menyertakan logo Apple (merek dagang), jadi logo diambil dari aset tema WhiteSur:

```bash
mkdir -p ~/.local/share/icons/linux2macos
cp ~/linux2macos-src/WhiteSur-gtk-theme/src/assets/gnome-shell/activities/activities-apple.svg \
   ~/.local/share/icons/linux2macos/apple-logo.svg

L=/org/gnome/shell/extensions/Logo-menu
dconf write $L/use-custom-icon true
dconf write $L/custom-icon-path "'$HOME/.local/share/icons/linux2macos/apple-logo.svg'"
dconf write $L/menu-button-icon-size 20
dconf write $L/show-activities-button false
dconf write $L/show-power-options true
dconf write $L/show-lockscreen true
dconf write $L/menu-button-terminal "'gnome-terminal'"
```

Isi menu: About My System, System Settings, App Grid, Activities, Software Center, System Monitor, Terminal, Extensions, Force Quit App, Sleep, Lock Screen, Log Out, Restart, Shut Down.

### Just Perfection

```bash
J=/org/gnome/shell/extensions/just-perfection
dconf write $J/activities-button false        # sembunyikan titik workspace
dconf write $J/clock-menu-position 1          # 0 tengah, 1 kanan, 2 kiri
dconf write $J/clock-menu-position-offset 20  # paling kanan
dconf write $J/startup-status 0               # setelah login langsung ke desktop
dconf write $J/workspace-popup false          # tanpa popup saat ganti workspace
gsettings set org.gnome.desktop.interface clock-show-weekday true
```

Just Perfection punya puluhan opsi lain (sembunyikan search, ukuran panel, kecepatan animasi). Buka pengaturannya di aplikasi Extensions.

---

## Menonaktifkan satu ekstensi

```bash
gnome-extensions disable blur-my-shell@aunetx
```

## Alternatif yang sengaja **tidak** dipakai

| Ekstensi | Alasan |
|---|---|
| Dash to Dock (versi terpisah) | Ubuntu Dock sudah turunan Dash to Dock; memasang keduanya bentrok |
| Dock magnification (zoom ikon saat disorot) | Tidak ada yang stabil di GNOME 46, berat |
| Global menu / Fildem | Tidak dirawat, tidak mendukung GNOME 46 |
| Burn My Windows | Bagus, tapi animasinya tidak mirip macOS dan lebih berat |

# 7. Login, Boot, Flatpak & Quick Look (opsional, butuh `sudo`)

Bagian ini **tidak** dikerjakan `install.sh` karena memasang paket atau mengubah file sistem di luar folder home. Kerjakan hanya jika kamu paham risikonya. Kesalahan pada layar login bisa membuat kamu tidak bisa login lewat GUI. Sebelum mulai, pastikan kamu tahu cara masuk ke TTY (<kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>F3</kbd>) untuk memperbaikinya.

---

## Layar login (GDM) bergaya WhiteSur

Memakai `tweaks.sh` resmi dari WhiteSur-gtk-theme. Script ini mengganti file tema GNOME Shell sistem yang dipakai GDM dan otomatis membuat backup.

```bash
sudo apt install -y sassc libglib2.0-dev-bin
cd ~/.cache/linux2macos/src/WhiteSur-gtk-theme   # sudah di-clone oleh install.sh
sudo ./tweaks.sh -g
```

Opsi:

| Opsi | Fungsi |
|---|---|
| `-b /path/gambar.jpg` | Pakai wallpaper sendiri sebagai latar login |
| `-b blank` | Latar polos |
| `-nb` | Tanpa blur |
| `-nd` | Tanpa digelapkan |

Contoh dengan wallpaper WhiteSur yang sudah terpasang:

```bash
sudo ./tweaks.sh -g -b ~/.local/share/backgrounds/WhiteSur-dark.jpg
```

Log out untuk melihat hasilnya.

### Mengembalikan layar login

```bash
cd ~/.cache/linux2macos/src/WhiteSur-gtk-theme
sudo ./tweaks.sh -g -r
```

> Setelah `sudo apt upgrade` yang memperbarui `gnome-shell` / `yaru-theme-gnome-shell`, tema login bisa kembali ke bawaan. Jalankan `sudo ./tweaks.sh -g` lagi.

---

## Aplikasi Flatpak

Aplikasi Flatpak berjalan di sandbox dan tidak bisa membaca `~/.themes`. Beri izin baca ke folder tema untuk semua aplikasi Flatpak milik user (tanpa sudo):

```bash
flatpak override --user \
  --filesystem=xdg-config/gtk-3.0:ro --filesystem=xdg-config/gtk-4.0:ro \
  --filesystem=~/.themes:ro --filesystem=~/.local/share/icons:ro \
  --env=GTK_THEME=WhiteSur-Dark --env=ICON_THEME=WhiteSur-dark
```

Buka ulang aplikasinya. Untuk mengembalikan: `flatpak override --user --reset`.

Alternatif dari WhiteSur sendiri (menyalin tema ke folder sistem, butuh sudo):

```bash
cd ~/.cache/linux2macos/src/WhiteSur-gtk-theme
./tweaks.sh -F -c Dark
```

---

## Quick Look (pratinjau dengan Spasi)

Di macOS, menekan <kbd>Spasi</kbd> pada file di Finder menampilkan pratinjau. Di Files, fitur yang sama disediakan **GNOME Sushi**:

```bash
sudo apt update && sudo apt install -y gnome-sushi
nautilus -q
```

Pilih file di Files lalu tekan <kbd>Spasi</kbd>. Bisa untuk gambar, PDF, video, audio, teks, dan kode. Tekan <kbd>Spasi</kbd> lagi atau <kbd>Esc</kbd> untuk menutup.

---

## Animasi boot (Plymouth)

Ubuntu memakai Plymouth untuk animasi saat booting. Tema bergaya macOS (logo + progress bar) banyak tersedia di GitHub. Cari *"macOS plymouth theme"* dan **baca isi repo sebelum memasang**, karena tema dipasang sebagai root.

Langkah umum setelah tema diunduh ke folder `NAMA_TEMA` yang berisi `NAMA_TEMA.plymouth`:

```bash
sudo cp -r NAMA_TEMA /usr/share/plymouth/themes/
sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth \
     /usr/share/plymouth/themes/NAMA_TEMA/NAMA_TEMA.plymouth 100
sudo update-alternatives --config default.plymouth   # pilih NAMA_TEMA
sudo update-initramfs -u
```

Uji tanpa reboot:

```bash
sudo apt install -y plymouth-x11
sudo plymouthd; sudo plymouth --show-splash; sleep 5; sudo plymouth quit
```

### Mengembalikan animasi boot Ubuntu

```bash
sudo update-alternatives --config default.plymouth   # pilih bgrt (bawaan Ubuntu)
sudo update-initramfs -u
```

> Pada beberapa laptop dengan NVIDIA, splash Plymouth tidak muncul sama sekali karena driver dimuat terlambat. Itu bukan kerusakan; boot tetap normal.

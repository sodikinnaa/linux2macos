# 2. Instalasi (dengan script)

## Langkah 1: unduh repo

```bash
git clone https://github.com/sodikinnaa/linux2macos.git
cd linux2macos
```

## Langkah 2: jalankan installer

```bash
./scripts/install.sh
```

Jangan pakai `sudo`. Script menolak jalan sebagai root karena semua file dipasang di folder home kamu.

Urutan yang dikerjakan:

1. **backup**: `dconf dump /`, `~/.bashrc`, dan `~/.config/gtk-4.0` disimpan ke `~/.config/linux2macos/backup/<tanggal>/`
2. **theme**: rilis WhiteSur Dark/Light diekstrak ke `~/.themes`, GTK4 di‑link
3. **icons**: ikon WhiteSur dirakit (tanpa menjalankan installer upstream)
4. **cursors**: kursor WhiteSur
5. **wallpaper**: resolusi dipilih otomatis (1080p / 2k / 4k)
6. **fonts**: Inter + JetBrainsMono Nerd Font
7. **dock**: posisi, transparansi, auto‑hide, titik indikator
8. **extensions**: 5 ekstensi dari extensions.gnome.org sesuai versi GNOME kamu, lalu diatur
9. **window**: tombol kiri, jendela baru di tengah
10. **app-icons**: launcher snap/AppImage diarahkan ke ikon WhiteSur
11. **terminal**: palet warna, font, Starship, fastfetch
12. **browser**: Chrome/Brave ke tema GTK, **hanya jika browser sedang tertutup**

Lama proses ±2–5 menit tergantung koneksi.

## Langkah 3: muat ulang GNOME Shell

Ekstensi baru terbaca setelah GNOME Shell dimuat ulang.

| Sesi | Cara |
|---|---|
| X11 | <kbd>Alt</kbd>+<kbd>F2</kbd> → ketik `r` → <kbd>Enter</kbd>. Aplikasi tetap terbuka |
| Wayland | Log out lalu login lagi |

Cek apakah ekstensi aktif:

```bash
gnome-extensions list --enabled
```

Harus ada `user-theme@…`, `blur-my-shell@aunetx`, `compiz-alike-magic-lamp-effect@…`, `logomenu@aryan_k`, `just-perfection-desktop@just-perfection`.

## Langkah 4: browser

Chrome/Brave menimpa pengaturannya sendiri saat ditutup, jadi browser harus **tertutup penuh** ketika diubah.

```bash
./scripts/browser-gtk.sh          # untuk browser yang sudah tertutup
./scripts/browser-gtk.sh --wait   # tunggu sampai browser ditutup, lalu terapkan
```

Brave sering tetap jalan di latar belakang setelah jendelanya ditutup. Keluar penuh dengan <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Q</kbd> atau lewat ikon di tray.

## Langkah 5: periksa hasilnya

- [ ] Logo Apple di pojok kiri atas; diklik muncul menu (About, Settings, Lock, Restart, Shut Down)
- [ ] Jam di kanan atas dengan nama hari
- [ ] Top bar dan dock transparan + blur
- [ ] Dock di bawah tengah, muncul saat mouse ke bawah; titik di bawah aplikasi yang terbuka
- [ ] Minimize jendela memakai efek *Magic Lamp*
- [ ] Tombol jendela ● ● ● di kiri, termasuk di Chrome/Brave
- [ ] Buka terminal baru: muncul fastfetch dan prompt Starship berwarna

Ada yang belum sesuai? Lihat [Troubleshooting](09-troubleshooting.md).

## Menjalankan ulang / memperbarui

Script aman dijalankan berkali‑kali. Untuk memperbarui tema ke versi terbaru WhiteSur:

```bash
git pull
./scripts/install.sh theme icons cursors
```

Setiap kali dijalankan, backup baru dibuat dan `backup/latest` menunjuk ke backup terakhir. `backup/original` tetap berisi kondisi sebelum instalasi pertama.

## Variasi

| Ingin | Perintah / ubah |
|---|---|
| Mode terang | `gsettings set org.gnome.desktop.interface gtk-theme WhiteSur-Light; gsettings set org.gnome.desktop.interface color-scheme default; gsettings set org.gnome.desktop.interface icon-theme WhiteSur; dconf write /org/gnome/shell/extensions/user-theme/name "'WhiteSur-Light'"` |
| Dock selalu tampil | `gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true` |
| Ikon dock lebih besar | `gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 56` |
| Tanpa efek Magic Lamp | `gnome-extensions disable compiz-alike-magic-lamp-effect@hermes83.github.com` |
| Jam format 12 jam | `gsettings set org.gnome.desktop.interface clock-format 12h` |

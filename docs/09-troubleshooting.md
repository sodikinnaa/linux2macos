# 9. Troubleshooting & FAQ

## Troubleshooting

### Top bar, blur, logo Apple, atau Magic Lamp tidak muncul

GNOME Shell belum dimuat ulang. Ekstensi baru hanya terbaca setelah itu.

- X11: <kbd>Alt</kbd>+<kbd>F2</kbd> → `r` → <kbd>Enter</kbd>
- Wayland: log out lalu login

Cek status:

```bash
gnome-extensions list --enabled
gnome-extensions info blur-my-shell@aunetx | grep State
```

| State | Arti |
|---|---|
| `ACTIVE` | Berjalan normal |
| `INACTIVE` | Terpasang tapi tidak diaktifkan → `gnome-extensions enable <uuid>` |
| `ERROR` | Error saat dimuat → lihat log di bawah |
| `OUT OF DATE` | Tidak mendukung versi GNOME ini |
| *does not exist* | Belum dimuat ulang, atau gagal terpasang |

Log error ekstensi:

```bash
journalctl --user -b -g 'gnome-shell' | tail -50
```

Pastikan ekstensi pengguna tidak dimatikan global:

```bash
gsettings set org.gnome.shell disable-user-extensions false
```

### `gnome-extensions enable` menjawab *"Extension … does not exist"*

Normal sebelum GNOME Shell dimuat ulang. Muat ulang dulu, lalu aktifkan.

### Top bar masih tema Yaru

User Themes belum aktif, atau nama tema belum diset:

```bash
dconf read /org/gnome/shell/extensions/user-theme/name   # harus 'WhiteSur-Dark'
```

### Aplikasi GNOME (Files, Settings) masih tema lama

Itu aplikasi GTK4/libadwaita. Cek symlink:

```bash
ls -l ~/.config/gtk-4.0/
```

Harus ada `gtk.css`, `gtk-dark.css`, `assets` yang menunjuk ke `~/.themes/WhiteSur-Dark/gtk-4.0/`. Tutup & buka ulang aplikasinya.

### Aplikasi Flatpak tidak ikut tema

Lihat [Login & Boot → Aplikasi Flatpak](07-login-boot.md#aplikasi-flatpak).

### Tombol Chrome/Brave masih bawaan

Lihat [Browser & Terminal](05-browser-terminal.md#tombol-masih-kotakbawaan). Paling sering: browser masih jalan di latar belakang, jadi keluar dengan <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Q</kbd>.

### Beberapa ikon aplikasi masih beda

```bash
./scripts/install.sh app-icons
```

Aplikasi yang tetap beda berarti WhiteSur tidak punya ikonnya. Pilih ikon lain secara manual (lihat [Panduan Manual §9](03-panduan-manual.md#9-ikon-aplikasi-yang-belum-seragam)). Aplikasi web Chrome/Brave sengaja dibiarkan.

Kalau ikon kembali seperti semula setelah aplikasi di‑update (misalnya launcher di `~/.local/share/applications` ditulis ulang oleh aplikasinya), jalankan `app-icons` lagi.

### Huruf di terminal renggang (`r o o t @ …`)

Pakai varian **Mono**:

```bash
P=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$P/" font 'JetBrainsMono Nerd Font Mono 12'
```

### Prompt Starship menampilkan kotak/tanda tanya

Font terminal bukan Nerd Font. Ikuti langkah di atas.

### `starship: command not found`

`~/.local/bin` belum di `PATH`. Tambahkan ke `~/.bashrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Dock hilang / tidak muncul

Dock auto‑hide: arahkan mouse ke tepi bawah layar. Agar selalu tampil:

```bash
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true
```

### Layar berkedip/hitam setelah Alt+F2 → r

Tunggu 2–3 detik. Kalau GNOME Shell crash berulang, masuk TTY (<kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>F3</kbd>), login, lalu:

```bash
gsettings set org.gnome.shell disable-user-extensions true
sudo systemctl restart gdm3     # akan log out semua sesi
```

Setelah masuk lagi, aktifkan ekstensi satu per satu untuk mencari penyebabnya.

### Script gagal mengunduh

- Cek koneksi ke `github.com`, `api.github.com`, `extensions.gnome.org`.
- GitHub API punya batas 60 request/jam tanpa login. Tunggu sebentar lalu jalankan modul yang gagal saja, mis. `./scripts/install.sh fonts`.

### Setelah upgrade Ubuntu tampilan berantakan

Ekstensi mungkin belum mendukung GNOME versi baru. Jalankan ulang:

```bash
./scripts/install.sh extensions
```

Script mengambil versi ekstensi yang cocok dengan GNOME terbaru. Ekstensi yang belum mendukung akan dilewati dengan peringatan.

---

## FAQ

**Apakah aman? Apakah butuh sudo?**
`install.sh` tidak memakai sudo dan hanya menulis ke folder home. Semua bisa dikembalikan dengan `restore.sh`. Hanya bagian opsional [Login & Boot](07-login-boot.md) yang butuh sudo.

**Apakah bisa menjalankan aplikasi macOS?**
Tidak. Ini hanya tampilan; sistem tetap Ubuntu.

**Kenapa font Inter, bukan SF Pro?**
Lisensi SF Pro hanya untuk perangkat Apple dan tidak boleh didistribusikan ulang. Inter sangat mirip dan berlisensi bebas (OFL).

**Bisakah menu File/Edit aplikasi pindah ke top bar (global menu)?**
Tidak secara stabil. GNOME tidak mendukung global menu, dan ekstensi yang ada (Fildem dll.) tidak dirawat untuk GNOME 46.

**Bisakah ikon dock membesar saat disorot (magnification)?**
Belum ada ekstensi yang stabil untuk GNOME 46. Ini juga cukup berat.

**Apakah memperlambat PC?**
Pengaruhnya kecil dengan pengaturan bawaan (blur statis, tanpa blur aplikasi). Lihat [Performa](06-performa.md).

**Mode terang?**
Lihat tabel *Variasi* di [Instalasi](02-instalasi.md#variasi).

**Wayland atau X11?**
Keduanya bisa. Di X11 GNOME Shell bisa dimuat ulang tanpa log out (<kbd>Alt</kbd>+<kbd>F2</kbd> → `r`).

**Bisa di KDE Plasma / XFCE?**
Script ini khusus GNOME. WhiteSur juga punya versi KDE: [WhiteSur-kde](https://github.com/vinceliuice/WhiteSur-kde).

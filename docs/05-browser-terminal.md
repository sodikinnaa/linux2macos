# 5. Browser & Terminal

## Chrome, Brave, Chromium, Edge

Browser berbasis Chromium menggambar tombol jendelanya sendiri. Supaya tombolnya ikut WhiteSur (● ● ● di kiri), browser harus memakai **tema GTK**.

### Cara cepat (script)

```bash
./scripts/browser-gtk.sh          # terapkan ke browser yang sedang tertutup
./scripts/browser-gtk.sh --wait   # tunggu browser ditutup, lalu terapkan
./scripts/browser-gtk.sh --undo   # kembalikan Preferences asli
```

Script mengubah **semua profil** (`Default`, `Profile 1`, `Profile 2`, …) di:

| Browser | Folder |
|---|---|
| Google Chrome | `~/.config/google-chrome` |
| Chromium (deb / snap) | `~/.config/chromium`, `~/snap/chromium/common/chromium` |
| Brave | `~/.config/BraveSoftware/Brave-Browser` |
| Microsoft Edge | `~/.config/microsoft-edge` |

Yang diubah di file `Preferences` tiap profil:

| Kunci | Nilai | Arti |
|---|---|---|
| `extensions.theme.system_theme` | `1` | 0 = Classic, **1 = GTK**, 2 = QT |
| `browser.custom_chrome_frame` | `true` | Tab tetap di baris judul (ringkas, seperti Safari) |

Salinan asli disimpan di `~/.config/linux2macos/backup/browser-prefs/`.

> **Penting:** browser menulis ulang `Preferences` saat ditutup. Kalau diubah ketika browser masih jalan, perubahan akan hilang. Brave/Chrome bisa tetap berjalan di latar belakang setelah jendelanya ditutup. Keluar penuh dengan <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Q</kbd>, lalu cek dengan `pgrep -a brave` / `pgrep -a chrome`.

### Cara manual

1. Buka `chrome://settings/appearance` (Brave: `brave://settings/appearance`)
2. **Theme** → **GTK**
3. **Mode** → **Dark**
4. **Use system title bar and borders** → **Off**

Profil yang dibuat **setelah** script dijalankan perlu diatur sekali dengan cara manual ini. Chromium tidak punya pengaturan default global untuk tema.

### Tombol masih kotak/bawaan?

- Browser dibuka sebelum tema WhiteSur dipasang → tutup penuh lalu buka lagi.
- Profil yang dipakai belum diubah → jalankan `./scripts/browser-gtk.sh` lagi saat browser tertutup.
- Pastikan `gtk-theme` = `WhiteSur-Dark`: `gsettings get org.gnome.desktop.interface gtk-theme`.

### Firefox

Firefox memakai tema sistem secara otomatis (Settings → General → Website appearance / Themes → **System theme — auto**). Untuk tampilan mirip Safari, lihat [WhiteSur Firefox theme](https://github.com/vinceliuice/WhiteSur-gtk-theme#firefox-theme) (`./tweaks.sh -f` di repo WhiteSur-gtk-theme).

---

## Terminal

### Yang dipasang

| Komponen | Keterangan |
|---|---|
| **JetBrainsMono Nerd Font Mono** | Font monospace dengan ikon (wajib untuk prompt Starship) |
| Palet warna | Pastel gelap (latar `#1e1e2e`, teks `#cdd6f4`) |
| [**Starship**](https://starship.rs) | Prompt berwarna: folder, branch git, versi bahasa, durasi perintah |
| [**fastfetch**](https://github.com/fastfetch-cli/fastfetch) | Info sistem + logo saat terminal dibuka |

Biner Starship & fastfetch dipasang di `~/.local/bin`. Preset Starship: `pastel-powerline` (`~/.config/starship.toml`).

Script menambahkan blok ini ke `~/.bashrc`:

```bash
# >>> linux2macos terminal >>>
if [[ $- == *i* ]]; then
  command -v fastfetch >/dev/null && fastfetch
  command -v starship >/dev/null && eval "$(starship init bash)"
fi
# <<< linux2macos terminal <<<
```

`restore.sh` hanya menghapus blok di antara dua penanda tersebut; isi `.bashrc` lainnya tidak disentuh.

### Pengaturan profil GNOME Terminal

```bash
P=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
K="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$P/"
gsettings set "$K" use-system-font false
gsettings set "$K" font 'JetBrainsMono Nerd Font Mono 12'
gsettings set "$K" use-theme-colors false
gsettings set "$K" background-color '#1e1e2e'
gsettings set "$K" foreground-color '#cdd6f4'
gsettings set "$K" palette "['#45475a','#f38ba8','#a6e3a1','#f9e2af','#89b4fa','#f5c2e7','#94e2d5','#bac2de','#585b70','#f38ba8','#a6e3a1','#f9e2af','#89b4fa','#f5c2e7','#94e2d5','#a6adc8']"
gsettings set "$K" scrollbar-policy 'never'
gsettings set "$K" default-size-columns 110
gsettings set "$K" default-size-rows 30
```

> Pakai **`JetBrainsMono Nerd Font Mono`**, bukan `JetBrainsMono Nerd Font`. Varian non‑Mono bisa membuat jarak antarhuruf renggang di GNOME Terminal (`r o o t @ …`).

### Preset Starship lain

```bash
starship preset --list
starship preset tokyo-night -o ~/.config/starship.toml
```

### Zsh

Kalau kamu memakai zsh, tambahkan ke `~/.zshrc`:

```bash
fastfetch
eval "$(starship init zsh)"
```

### Mematikan fastfetch saja

Hapus baris `command -v fastfetch …` di blok `.bashrc`.

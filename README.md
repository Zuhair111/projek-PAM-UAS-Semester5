# Family Tracking App
**Projek PAM - UAS Semester 5**

Aplikasi tracking keluarga dengan integrasi smartwatch yang memungkinkan orang tua untuk memantau lokasi anak-anak mereka secara real-time.

---

## 📋 Fitur Utama

- 📍 **Tracking Lokasi Real-time** - Pantau lokasi anggota keluarga di peta
- ⌚ **Integrasi Smartwatch** - Dukungan untuk smartwatch Android
- 📱 **Pairing QR Code** - Mudah menghubungkan smartwatch dengan aplikasi utama
- 👨‍👩‍👧‍👦 **Manajemen Keluarga** - Tambah/kelola anggota keluarga
- 🔔 **Notifikasi** - Notifikasi lokasi dan aktivitas
- 🌐 **Integrasi IoT** - Koneksi dengan perangkat IoT eksternal

---

## 📁 Struktur Proyek

```
Projek_PAM/
├── aplikasi2/          # Aplikasi utama (smartphone)
└── aplikasi2_watch/    # Aplikasi smartwatch
```

---

## 💡 Informasi Penting

> **✅ Aplikasi ini sudah dikonfigurasi lengkap!**
> 
> Firebase dan Google Maps API sudah disetup. Anda **TIDAK** perlu:
> - ❌ Membuat akun Firebase baru
> - ❌ Setup Google Maps API Key baru
> - ❌ Konfigurasi database dan authentication
> 
> Yang perlu Anda lakukan:
> - ✅ Install Flutter SDK dan Android Studio
> - ✅ Install dependencies (`flutter pub get`)
> - ✅ Jalankan aplikasi (`flutter run`)

---

# 🚀 Panduan Instalasi

## Langkah 1: Persiapan Tools

### 1.1 Install Flutter SDK

1. Download Flutter dari [Flutter Official Website](https://docs.flutter.dev/get-started/install/windows)
2. Extract file zip ke folder `C:\src\flutter`
3. Tambahkan Flutter ke PATH:
   - Buka "Edit System Environment Variables"
   - Klik "Environment Variables"
   - Edit "Path" → Tambahkan `C:\src\flutter\bin`
4. Verifikasi instalasi:
   ```bash
   flutter --version
   ```

### 1.2 Install Android Studio

1. Download [Android Studio](https://developer.android.com/studio)
2. Install Android SDK melalui SDK Manager:
   - Android SDK Platform (API Level 33 atau lebih tinggi)
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
3. Buat Emulator Android:
   - "More Actions" → "Virtual Device Manager"
   - "Create Device" → Pilih Pixel 5
   - Download system image (Android 13.0)
   - Finish

### 1.3 Install VS Code (Opsional)

1. Download [VS Code](https://code.visualstudio.com/)
2. Install extension "Flutter" (by Dart Code)

### 1.4 Verifikasi Setup

Jalankan perintah berikut untuk mengecek instalasi:

```bash
flutter doctor
```

Pastikan tidak ada error penting (tanda ✓).

---

## Langkah 2: Persiapan File Aplikasi

### 2.1 Ekstrak Folder

1. Copy folder `Projek_PAM` yang Anda terima
2. Letakkan di lokasi yang mudah diakses, contoh:
   ```
   C:\Users\YourName\Projects\Projek_PAM
   ```

### 2.2 Verifikasi File Konfigurasi

**PENTING!** Pastikan file-file berikut ada:

✅ `aplikasi2\android\app\google-services.json`
✅ `aplikasi2_watch\android\app\google-services.json`
✅ `aplikasi2\android\app\src\main\AndroidManifest.xml`

**Jika file tidak ada**, hubungi pemberi aplikasi untuk mendapatkan file konfigurasi Firebase.

### 2.3 Buka Folder di Terminal

```bash
cd C:\Users\YourName\Projects\Projek_PAM
```

---

## Langkah 3: Install Dependencies

### 3.1 Aplikasi Utama

```bash
cd aplikasi2
flutter pub get
```

Tunggu hingga selesai (1-3 menit).

### 3.2 Aplikasi Watch

```bash
cd ..\aplikasi2_watch
flutter pub get
```

---

## Langkah 4: Jalankan Aplikasi

### 4.1 Start Emulator

**Via Android Studio:**
1. Buka Android Studio
2. "More Actions" → "Virtual Device Manager"
3. Klik ▶️ pada emulator yang sudah dibuat

**Via Command Line:**
```bash
flutter emulators
flutter emulators --launch <nama_emulator>
```

### 4.2 Cek Device

Pastikan emulator terdeteksi:

```bash
flutter devices
```

### 4.3 Run Aplikasi Utama

```bash
cd aplikasi2
flutter run
```

⏱️ **Build pertama kali memakan waktu 5-15 menit**. Harap sabar!

### 4.4 Run Aplikasi Watch (Opsional)

Untuk menjalankan aplikasi watch, Anda memerlukan emulator Wear OS:

1. Buat Virtual Device Wear OS di Android Studio
2. Pilih "Wear OS Small Round"
3. Jalankan emulator Wear OS
4. Run aplikasi:
   ```bash
   cd aplikasi2_watch
   flutter run
   ```

---

## Langkah 5: Testing Aplikasi

### 5.1 Registrasi Akun

1. Klik "Daftar" atau "Register"
2. Email: `test@example.com`
3. Password: `test123456`
4. Klik "Register"

### 5.2 Setup Profil

1. Pilih role: **Parent** (Orang Tua) atau **Child** (Anak)
2. Masukkan nama
3. Lengkapi profil

### 5.3 Coba Fitur

- 📍 **Lokasi**: Izinkan akses lokasi → Lihat peta
- 👨‍👩‍👧‍👦 **Family**: Tambah anggota keluarga
- 👤 **Profile**: Edit profil

---

# 🔧 Troubleshooting

## Problem 1: "flutter command not found"

**Penyebab:** Flutter belum masuk PATH

**Solusi:**
1. Tambahkan Flutter ke PATH (ulangi Langkah 1.1)
2. Restart terminal
3. Test: `flutter --version`

## Problem 2: Build error "Gradle sync failed"

**Solusi:**
```bash
cd aplikasi2
flutter clean
flutter pub get
flutter run
```

## Problem 3: "google-services.json not found"

**Penyebab:** File konfigurasi Firebase tidak ada

**Solusi:**
- Hubungi pemberi aplikasi untuk mendapatkan file:
  - `aplikasi2\android\app\google-services.json`
  - `aplikasi2_watch\android\app\google-services.json`

## Problem 4: Google Maps tidak muncul (peta kosong)

**Solusi:**
```bash
flutter clean
flutter run
```
- Pastikan emulator/device terkoneksi internet
- Tunggu beberapa saat, maps akan load

## Problem 5: Lokasi tidak bisa diakses

**Solusi:**
- Di emulator: Settings → Location → Enable
- Set lokasi manual: Menu "..." → Location
- Izinkan permission saat diminta aplikasi

## Problem 6: Firebase Authentication error

**Solusi:**
- Pastikan `google-services.json` ada di lokasi yang benar
- Pastikan device terkoneksi internet
- Coba rebuild:
  ```bash
  flutter clean
  flutter run
  ```

## Problem 7: Build sangat lama (>20 menit)

**Solusi:**
- Build pertama memang lama (5-15 menit adalah normal)
- Jika stuck, tekan Ctrl+C lalu coba lagi:
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```

---

# ✅ Checklist Setup

Gunakan checklist ini untuk memastikan semua sudah benar:

- [ ] Flutter SDK terinstall (`flutter --version` berjalan)
- [ ] Android Studio terinstall
- [ ] Android SDK terinstall
- [ ] Emulator Android sudah dibuat
- [ ] Folder aplikasi sudah diekstrak
- [ ] File `google-services.json` ada di `aplikasi2\android\app\`
- [ ] File `google-services.json` ada di `aplikasi2_watch\android\app\`
- [ ] `flutter pub get` berhasil untuk aplikasi2
- [ ] `flutter pub get` berhasil untuk aplikasi2_watch
- [ ] Emulator sudah running
- [ ] `flutter devices` menampilkan device
- [ ] Aplikasi berhasil di-build dan berjalan

---

# 📦 Build APK (Opsional)

Untuk membuat file APK yang bisa diinstall di device lain:

### Debug APK
```bash
cd aplikasi2
flutter build apk --debug
```

### Release APK
```bash
cd aplikasi2
flutter build apk --release
```

File APK tersimpan di: `aplikasi2\build\app\outputs\flutter-apk\`

---

# 📚 Informasi Tambahan

## Link Repository
🔗 https://github.com/Zuhair111/projek-PAM-UAS-Semester5

## Catatan Keamanan

⚠️ **File yang Dibutuhkan:**
- `google-services.json` (2 file untuk aplikasi2 dan aplikasi2_watch)
- Jika tidak ada, hubungi pemberi aplikasi

✅ **Sudah Dikonfigurasi:**
- Firebase Authentication & Database
- Google Maps API Key
- Semua dependencies

🎯 **Yang Perlu Dilakukan:**
- Install Flutter SDK dan Android Studio
- Install dependencies dengan `flutter pub get`
- Jalankan dengan `flutter run`

---

# 👥 Tim Pengembang

Projek PAM - UAS Semester 5

---

# 📄 Lisensi

Educational Project - Untuk keperluan akademik

---

**💻 Selamat mencoba! Jika ada masalah, cek bagian Troubleshooting terlebih dahulu.**

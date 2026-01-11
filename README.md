# Family Tracking App - Projek PAM UAS Semester 5

Aplikasi tracking keluarga dengan integrasi smartwatch yang memungkinkan orang tua untuk memantau lokasi anak-anak mereka secara real-time.

## 📋 Fitur Utama

- **Tracking Lokasi Real-time**: Pantau lokasi anggota keluarga di peta
- **Integrasi Smartwatch**: Dukungan untuk smartwatch Android
- **Pairing QR Code**: Mudah menghubungkan smartwatch dengan aplikasi utama
- **Manajemen Keluarga**: Tambah/kelola anggota keluarga
- **Notifikasi**: Notifikasi lokasi dan aktivitas
- **Integrasi IoT**: Koneksi dengan perangkat IoT eksternal

## � Struktur Proyek

```
Projek_PAM/
├── aplikasi2/          # Aplikasi utama (smartphone)
└── aplikasi2_watch/    # Aplikasi smartwatch
```

---

# 🚀 PANDUAN LENGKAP MENJALANKAN APLIKASI

Ikuti langkah-langkah berikut secara berurutan untuk menjalankan aplikasi ini di laptop Anda.

> **CATATAN PENTING**: Aplikasi ini sudah dikonfigurasi lengkap dengan Firebase dan Google Maps API. 
> Anda TIDAK perlu membuat akun Firebase atau API Key baru. 
> Cukup install tools yang diperlukan dan jalankan aplikasi!

## LANGKAH 1: Persiapan Tools (Install Sekali Saja)

### 1.1 Install Flutter SDK

1. **Download Flutter:**
   - Buka https://docs.flutter.dev/get-started/install/windows
   - Download Flutter SDK untuk Windows (file .zip)
   - Extract file zip ke folder `C:\src\flutter` (atau lokasi pilihan Anda)

2. **Tambahkan Flutter ke PATH:**
   - Buka "Edit System Environment Variables" di Windows
   - Klik "Environment Variables"
   - Di bagian "User variables", edit variable "Path"
   - Tambahkan path: `C:\src\flutter\bin` (sesuaikan dengan lokasi Flutter Anda)
   - Klik OK

3. **Verifikasi Instalasi:**
   - Buka Command Prompt atau PowerShell
   - Ketik: `flutter --version`
   - Jika berhasil, akan muncul versi Flutter

### 1.2 Install Android Studio

1. **Download Android Studio:**
   - Buka https://developer.android.com/studio
   - Download dan install Android Studio

2. **Install Android SDK:**
   - Buka Android Studio
   - Pilih "More Actions" → "SDK Manager"
   - Pastikan terinstall:
     - Android SDK Platform (Android 13.0 atau lebih tinggi)
     - Android SDK Build-Tools
     - Android SDK Command-line Tools

3. **Buat Emulator (Virtual Device):**
   - Di Android Studio, pilih "More Actions" → "Virtual Device Manager"
   - Klik "Create Device"
   - Pilih device (contoh: Pixel 5)
   - Pilih system image (contoh: Android 13.0 - API Level 33)
   - Klik "Finish"

### 1.3 Install VS Code (Opsional, tapi Direkomendasikan)

1. Download dan install VS Code dari https://code.visualstudio.com/
2. Install Extension Flutter di VS Code:
   - Buka VS Code
   - Klik icon Extensions (Ctrl+Shift+X)
   - Cari "Flutter"
   - Install extension "Flutter" (by Dart Code)

### 1.4 Setup Flutter

Jalankan perintah berikut di Command Prompt/PowerShell:

```bash
flutter doctor
```

Perintah ini akan mengecek semua yang dibutuhkan. Ikuti instruksi untuk memperbaiki masalah yang muncul (jika ada).

---

## LANGKAH 2: Persiapan File Aplikasi

### 2.1 Ekstrak Folder

1. Salin folder `Projek_PAM` yang Anda terima
2. Letakkan di lokasi yang mudah diakses, contoh: `C:\Users\YourName\Projects\Projek_PAM`
3. Pastikan struktur folder seperti ini:
   ```
   Projek_PAM/
   ├── aplikasi2/
   │   ├── android/
   │   │   └── app/
   │   │       └── google-services.json  ← File ini HARUS ADA
   │   ├── lib/
   │   └── pubspec.yaml
   └── aplikasi2_watch/
       ├── android/
       │   └── app/
       │       └── google-services.json  ← File ini HARUS ADA
       ├── lib/
       └── pubspec.yaml
   ```

### 2.2 Verifikasi File Konfigurasi

**PENTING:** Pastikan file-file berikut sudah ada di folder:

✅ `aplikasi2\android\app\google-services.json` - Konfigurasi Firebase untuk aplikasi utama
✅ `aplikasi2_watch\android\app\google-services.json` - Konfigurasi Firebase untuk aplikasi watch
✅ `aplikasi2\android\app\src\main\AndroidManifest.xml` - Sudah berisi Google Maps API Key

**Jika file-file ini TIDAK ADA**, hubungi pemberi aplikasi untuk mendapatkan file tersebut.

### 2.3 Buka Folder di VS Code atau Terminal

**Jika menggunakan VS Code:**
- Buka VS Code
- File → Open Folder
- Pilih folder `Projek_PAM`

**Jika menggunakan Terminal/PowerShell:**
```bash
cd C:\Users\YourName\Projects\Projek_PAM
```

---

## LANGKAH 3: Install Dependencies

Sekarang kita install semua package yang dibutuhkan aplikasi.

### 3.1 Install Dependencies Aplikasi Utama

Buka Terminal/PowerShell di folder aplikasi utama:

```bash
cd aplikasi2
flutter pub get
```

Tunggu hingga proses selesai (biasanya 1-3 menit tergantung koneksi internet).

### 3.2 Install Dependencies Aplikasi Watch

Buka Terminal/PowerShell di folder aplikasi watch:

```bash
cd ..\aplikasi2_watch
flutter pub get
```

Tunggu hingga selesai.

---

## LANGKAH 4: Jalankan Aplikasi

### 4.1 Jalankan Emulator Android

**Cara 1: Via Android Studio**
1. Buka Android Studio
2. Klik "More Actions" → "Virtual Device Manager"
3. Klik tombol ▶️ (Play) pada device yang sudah dibuat
4. Tunggu emulator menyala (biasanya 1-2 menit)

**Cara 2: Via Command Line**
```bash
flutter emulators
flutter emulators --launch <nama_emulator>
```

### 4.2 Cek Koneksi Device

Pastikan emulator terdeteksi:

```bash
flutter devices
```

Seharusnya muncul device Android dalam list.

### 4.3 Jalankan Aplikasi Utama

Pastikan Anda di folder `aplikasi2`:

```bash
cd aplikasi2
flutter run
```

**Proses build pertama kali akan lama (5-15 menit).** Harap bersabar!

Setelah berhasil, aplikasi akan otomatis terbuka di emulator.

### 4.4 Jalankan Aplikasi Watch (Opsional)

Jika ingin test aplikasi watch, Anda perlu emulator Wear OS atau smartwatch fisik.

**Untuk emulator Wear OS:**
1. Di Android Studio, buat Virtual Device baru
2. Pilih kategori "Wear OS" 
3. Pilih device seperti "Wear OS Small Round"
4. Jalankan emulator

**Jalankan aplikasi:**
```bash
cd aplikasi2_watch
flutter run
```

Pilih device Wear OS saat diminta.

---

## LANGKAH 5: Testing Aplikasi

### 5.1 Registrasi Akun Pertama

1. Di aplikasi, klik "Daftar" atau "Register"
2. Masukkan email: `test@example.com`
3. Masukkan password: `test123456`
4. Klik "Register"

### 5.2 Setup Profil

1. Pilih role: **Parent** (Orang Tua)
2. Masukkan nama: `Test Parent`
3. Lengkapi profil

### 5.3 Test Fitur

- **Lokasi**: Izinkan akses lokasi → Lihat peta
- **Family**: Coba tambah anggota keluarga
- **Profile**: Edit profil Anda

---

## ❗ Troubleshooting - Masalah yang Sering Terjadi

### Problem 1: "flutter command not found"

**Solusi:**
- Flutter belum masuk PATH
- Ulangi Langkah 1.1 untuk menambahkan Flutter ke PATH
- Restart terminal/PowerShell
- Test lagi: `flutter --version`

### Problem 2: Build error "Gradle sync failed"

**Solusi:**
```bash
cd aplikasi2
flutter clean
flutter pub get
flutter run
```

### Problem 3: "google-services.json not found"

**Solusi:**
- File `google-services.json` mungkin tidak tersedia di folder yang Anda terima
- Hubungi pemberi aplikasi untuk mendapatkan file:
  - `aplikasi2\android\app\google-services.json`
  - `aplikasi2_watch\android\app\google-services.json`
- Pastikan file berada di lokasi yang tepat

### Problem 4: Google Maps tidak muncul (peta kosong)

**Solusi:**
- Google Maps API sudah dikonfigurasi di aplikasi
- Jika tetap tidak muncul, coba:
  ```bash
  flutter clean
  flutter run
  ```
- Pastikan emulator/device sudah terhubung internet

### Problem 5: Lokasi tidak bisa diakses

**Solusi:**
- Di emulator, buka Settings → Location → Enable
- Set lokasi manual di emulator (menu "..." → Location)
- Izinkan permission lokasi saat diminta aplikasi

### Problem 6: Firebase Authentication error

**Solusi:**
- Firebase sudah dikonfigurasi, seharusnya tidak ada masalah
- Jika ada error, pastikan:
  - File `google-services.json` ada di lokasi yang benar
  - Device/emulator terkoneksi internet
  - Coba rebuild: `flutter clean` lalu `flutter run`

### Problem 7: Build sangat lama (lebih dari 20 menit)

**Solusi:**
- Build pertama memang lama, ini normal
- Jika stuck, tekan Ctrl+C lalu coba lagi:
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```

---

## 📋 Checklist Setup

Gunakan checklist ini untuk memastikan semua sudah benar:

- [ ] Flutter SDK terinstall dan `flutter --version` berjalan
- [ ] Android Studio terinstall
- [ ] Android SDK terinstall
- [ ] Emulator Android sudah dibuat
- [ ] Folder aplikasi sudah diekstrak
- [ ] File `google-services.json` ada di `aplikasi2\android\app\`
- [ ] File `google-services.json` ada di `aplikasi2_watch\android\app\`
- [ ] `flutter pub get` berhasil di folder aplikasi2
- [ ] `flutter pub get` berhasil di folder aplikasi2_watch
- [ ] Emulator sudah running
- [ ] `flutter devices` menampilkan device
- [ ] Aplikasi berhasil di-build dan running

---

## 🏗️ Build APK (Opsional)

Jika ingin membuat file APK untuk diinstall di device lain:

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

APK akan tersimpan di: `aplikasi2\build\app\outputs\flutter-apk\`

---

## 📞 Informasi Tambahan

### Link Repository
https://github.com/Zuhair111/projek-PAM-UAS-Semester5

### Catatan Penting

⚠️ **FILE YANG DIBUTUHKAN:**
- File `google-services.json` (2 file untuk aplikasi2 dan aplikasi2_watch)
- Jika file ini tidak ada di folder yang Anda terima, **hubungi pemberi aplikasi**

✅ **SUDAH DIKONFIGURASI:**
- Firebase Authentication & Database
- Google Maps API Key
- Semua dependencies di pubspec.yaml

🎯 **YANG PERLU ANDA LAKUKAN:**
- Install Flutter SDK dan Android Studio
- Install dependencies dengan `flutter pub get`
- Jalankan aplikasi dengan `flutter run`

---

## 👥 Kontributor

Projek PAM - UAS Semester 5

## 📄 Lisensi

Educational Project - Untuk keperluan akademik

---

**Selamat mencoba! Jika ada pertanyaan atau masalah, periksa bagian Troubleshooting terlebih dahulu.**

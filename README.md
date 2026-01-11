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
   └── aplikasi2_watch/
   ```

### 2.2 Buka Folder di VS Code atau Terminal

**Jika menggunakan VS Code:**
- Buka VS Code
- File → Open Folder
- Pilih folder `Projek_PAM`

**Jika menggunakan Terminal/PowerShell:**
```bash
cd C:\Users\YourName\Projects\Projek_PAM
```

---

## LANGKAH 3: Setup Firebase (WAJIB)

Aplikasi ini menggunakan Firebase sebagai backend. Anda HARUS setup Firebase terlebih dahulu.

### 3.1 Buat Akun Firebase

1. Buka https://console.firebase.google.com/
2. Login dengan akun Google Anda
3. Klik "Add project" atau "Tambah proyek"
4. Nama proyek: `family-tracking-app` (atau terserah Anda)
5. Ikuti wizard hingga selesai

### 3.2 Enable Authentication

1. Di Firebase Console, pilih proyek Anda
2. Klik "Authentication" di menu kiri
3. Klik tab "Sign-in method"
4. Enable "Email/Password"
5. Klik "Save"

### 3.3 Enable Firestore Database

1. Di Firebase Console, klik "Firestore Database"
2. Klik "Create database"
3. Pilih mode: **"Start in production mode"**
4. Pilih lokasi: **asia-southeast2 (Jakarta)** atau yang terdekat
5. Klik "Enable"

6. **Setup Firestore Rules:**
   - Klik tab "Rules"
   - Ganti semua isi dengan kode berikut:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null;
       }
       match /families/{familyId} {
         allow read, write: if request.auth != null;
       }
       match /locations/{locationId} {
         allow read, write: if request.auth != null;
       }
       match /smartwatches/{watchId} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```
   - Klik "Publish"

### 3.4 Enable Realtime Database

1. Di Firebase Console, klik "Realtime Database"
2. Klik "Create Database"
3. Pilih lokasi yang sama dengan Firestore
4. Pilih mode: **"Start in locked mode"**
5. Klik "Enable"

6. **Setup Realtime Database Rules:**
   - Klik tab "Rules"
   - Ganti dengan:
   ```json
   {
     "rules": {
       ".read": "auth != null",
       ".write": "auth != null"
     }
   }
   ```
   - Klik "Publish"

### 3.5 Download File Konfigurasi Firebase

#### Untuk Aplikasi Utama (aplikasi2):

1. Di Firebase Console, klik icon gear (⚙️) → "Project settings"
2. Scroll ke bawah ke bagian "Your apps"
3. Klik icon Android (robot hijau)
4. **Register app:**
   - Android package name: `com.example.aplikasi2`
   - App nickname: `Aplikasi2` (opsional)
   - Klik "Register app"
5. **Download google-services.json:**
   - Klik tombol "Download google-services.json"
   - Simpan file ini
6. **Letakkan file di lokasi yang benar:**
   - Copy file `google-services.json`
   - Paste ke folder: `Projek_PAM\aplikasi2\android\app\`
   - Path lengkap: `C:\Users\YourName\Projects\Projek_PAM\aplikasi2\android\app\google-services.json`

#### Untuk Aplikasi Watch (aplikasi2_watch):

1. Masih di halaman "Project settings" → "Your apps"
2. Klik "Add app" → Pilih icon Android lagi
3. **Register app:**
   - Android package name: `com.example.aplikasi2_watch`
   - App nickname: `Aplikasi2 Watch` (opsional)
   - Klik "Register app"
4. **Download google-services.json:**
   - Download file yang kedua ini
5. **Letakkan file di lokasi yang benar:**
   - Copy file `google-services.json`
   - Paste ke folder: `Projek_PAM\aplikasi2_watch\android\app\`
   - Path lengkap: `C:\Users\YourName\Projects\Projek_PAM\aplikasi2_watch\android\app\google-services.json`

**PENTING:** Pastikan kedua file `google-services.json` sudah berada di lokasi yang benar!

---

## LANGKAH 4: Setup Google Maps API (WAJIB)

### 4.1 Buat API Key

1. Buka https://console.cloud.google.com/
2. Pilih project yang sama dengan Firebase (atau akan otomatis dipilih)
3. Klik menu ☰ → "APIs & Services" → "Library"
4. Cari "Maps SDK for Android"
5. Klik "Maps SDK for Android" → Klik "Enable"
6. Klik menu ☰ → "APIs & Services" → "Credentials"
7. Klik "Create Credentials" → "API Key"
8. Copy API Key yang muncul (contoh: `AIzaSyAaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQ`)

### 4.2 Masukkan API Key ke Aplikasi

1. Buka file: `Projek_PAM\aplikasi2\android\app\src\main\AndroidManifest.xml`
2. Cari baris yang berisi `com.google.android.geo.API_KEY`
3. Ganti `YOUR_API_KEY_HERE` dengan API Key Anda:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="AIzaSyAaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQ"/>
   ```
4. Simpan file (Ctrl+S)

---

## LANGKAH 5: Install Dependencies

Sekarang kita install semua package yang dibutuhkan aplikasi.

### 5.1 Install Dependencies Aplikasi Utama

Buka Terminal/PowerShell di folder aplikasi utama:

```bash
cd aplikasi2
flutter pub get
```

Tunggu hingga proses selesai (biasanya 1-3 menit tergantung koneksi internet).

### 5.2 Install Dependencies Aplikasi Watch

Buka Terminal/PowerShell di folder aplikasi watch:

```bash
cd ..\aplikasi2_watch
flutter pub get
```

Tunggu hingga selesai.

---

## LANGKAH 6: Jalankan Aplikasi

### 6.1 Jalankan Emulator Android

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

### 6.2 Cek Koneksi Device

Pastikan emulator terdeteksi:

```bash
flutter devices
```

Seharusnya muncul device Android dalam list.

### 6.3 Jalankan Aplikasi Utama

Pastikan Anda di folder `aplikasi2`:

```bash
cd aplikasi2
flutter run
```

**Proses build pertama kali akan lama (5-15 menit).** Harap bersabar!

Setelah berhasil, aplikasi akan otomatis terbuka di emulator.

### 6.4 Jalankan Aplikasi Watch (Opsional)

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

## LANGKAH 7: Testing Aplikasi

### 7.1 Registrasi Akun Pertama

1. Di aplikasi, klik "Daftar" atau "Register"
2. Masukkan email: `test@example.com`
3. Masukkan password: `test123456`
4. Klik "Register"

### 7.2 Setup Profil

1. Pilih role: **Parent** (Orang Tua)
2. Masukkan nama: `Test Parent`
3. Lengkapi profil

### 7.3 Test Fitur

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
- File `google-services.json` belum diletakkan dengan benar
- Pastikan file ada di:
  - `aplikasi2\android\app\google-services.json`
  - `aplikasi2_watch\android\app\google-services.json`

### Problem 4: Google Maps tidak muncul (peta kosong)

**Solusi:**
- API Key belum dimasukkan atau salah
- Cek file `AndroidManifest.xml`
- Pastikan "Maps SDK for Android" sudah di-enable di Google Cloud Console
- Rebuild aplikasi:
  ```bash
  flutter clean
  flutter run
  ```

### Problem 5: Lokasi tidak bisa diakses

**Solusi:**
- Di emulator, buka Settings → Location → Enable
- Set lokasi manual di emulator (menu "..." → Location)
- Izinkan permission lokasi saat diminta aplikasi

### Problem 6: Firebase Authentication error

**Solusi:**
- Pastikan Email/Password sudah di-enable di Firebase Console
- Cek file `google-services.json` sudah benar
- Pastikan package name sama persis: `com.example.aplikasi2`

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
- [ ] Akun Firebase sudah dibuat
- [ ] Authentication di-enable di Firebase
- [ ] Firestore Database dibuat dan rules sudah di-update
- [ ] Realtime Database dibuat dan rules sudah di-update
- [ ] File `google-services.json` untuk aplikasi2 sudah ada di `aplikasi2\android\app\`
- [ ] File `google-services.json` untuk watch sudah ada di `aplikasi2_watch\android\app\`
- [ ] Google Maps API Key sudah dibuat
- [ ] Maps SDK for Android sudah di-enable
- [ ] API Key sudah dimasukkan ke `AndroidManifest.xml`
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

⚠️ **JANGAN BAGIKAN:**
- File `google-services.json` (sudah ada di .gitignore)
- Google Maps API Key ke publik
- Credentials Firebase

✅ **AMAN DIBAGIKAN:**
- Semua source code (.dart files)
- Assets (images, icons)
- File konfigurasi (pubspec.yaml, AndroidManifest.xml dengan placeholder API key)

---

## 👥 Kontributor

Projek PAM - UAS Semester 5

## 📄 Lisensi

Educational Project - Untuk keperluan akademik

---

**Selamat mencoba! Jika ada pertanyaan atau masalah, periksa bagian Troubleshooting terlebih dahulu.**

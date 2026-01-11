# Family Tracking App - Projek PAM UAS Semester 5

Aplikasi tracking keluarga dengan integrasi smartwatch yang memungkinkan orang tua untuk memantau lokasi anak-anak mereka secara real-time.

## 📋 Fitur Utama

- **Tracking Lokasi Real-time**: Pantau lokasi anggota keluarga di peta
- **Integrasi Smartwatch**: Dukungan untuk smartwatch Android
- **Pairing QR Code**: Mudah menghubungkan smartwatch dengan aplikasi utama
- **Manajemen Keluarga**: Tambah/kelola anggota keluarga
- **Notifikasi**: Notifikasi lokasi dan aktivitas
- **Integrasi IoT**: Koneksi dengan perangkat IoT eksternal

## 🛠️ Prerequisites

Sebelum memulai, pastikan Anda sudah menginstal:

- **Flutter SDK** (3.0 atau lebih tinggi)
  ```bash
  flutter --version
  ```
- **Android Studio** atau **VS Code** dengan Flutter extension
- **Java JDK** (untuk build Android)
- **Git**
- **Akun Firebase** (untuk backend)

## 📱 Struktur Proyek

```
Projek_PAM/
├── aplikasi2/          # Aplikasi utama (smartphone)
└── aplikasi2_watch/    # Aplikasi smartwatch
```

## 🚀 Cara Setup dan Menjalankan

### 1. Clone Repository

```bash
git clone https://github.com/Zuhair111/projek-PAM-UAS-Semester5.git
cd projek-PAM-UAS-Semester5
```

### 2. Setup Firebase

#### a. Buat Proyek Firebase
1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik "Add project" atau "Tambah proyek"
3. Ikuti wizard setup proyek

#### b. Enable Services Firebase
Di Firebase Console, aktifkan:
- **Authentication** → Email/Password
- **Firestore Database** → Mode Production
- **Realtime Database**

#### c. Download Configuration Files

**Untuk Android:**
1. Tambahkan aplikasi Android di Firebase Console
2. Package name: `com.example.aplikasi2` (untuk aplikasi utama)
3. Download `google-services.json`
4. Letakkan di `aplikasi2/android/app/google-services.json`

**Untuk Watch:**
1. Tambahkan aplikasi Android lagi
2. Package name: `com.example.aplikasi2_watch`
3. Download `google-services.json`
4. Letakkan di `aplikasi2_watch/android/app/google-services.json`

#### d. Setup Firestore Rules
Di Firebase Console → Firestore Database → Rules, paste rules berikut:

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
  }
}
```

### 3. Setup Google Maps API

1. Buka [Google Cloud Console](https://console.cloud.google.com/)
2. Buat atau pilih project yang sama dengan Firebase
3. Enable **Maps SDK for Android**
4. Buat API Key di Credentials
5. Edit file `aplikasi2/android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

### 4. Install Dependencies

#### Untuk Aplikasi Utama:
```bash
cd aplikasi2
flutter pub get
```

#### Untuk Aplikasi Watch:
```bash
cd aplikasi2_watch
flutter pub get
```

### 5. Jalankan Aplikasi

#### Aplikasi Utama (Smartphone):

1. Hubungkan smartphone Android atau jalankan emulator
2. Pastikan device terdeteksi:
   ```bash
   flutter devices
   ```
3. Jalankan aplikasi:
   ```bash
   cd aplikasi2
   flutter run
   ```

#### Aplikasi Watch (Smartwatch):

1. Hubungkan smartwatch Android atau gunakan emulator Wear OS
2. Jalankan aplikasi:
   ```bash
   cd aplikasi2_watch
   flutter run
   ```

## 📖 Cara Menggunakan Aplikasi

### Pertama Kali Menggunakan

1. **Registrasi Akun**
   - Buka aplikasi → Klik "Daftar"
   - Isi email dan password
   - Verifikasi email jika diperlukan

2. **Pilih Role**
   - **Parent**: Untuk orang tua yang ingin memantau
   - **Child**: Untuk anak yang akan dipantau

3. **Setup Profil**
   - Masukkan nama depan
   - Lengkapi informasi profil

### Untuk Orang Tua (Parent)

1. **Tambah Anggota Keluarga**
   - Buka menu "Family"
   - Klik tombol "+" atau "Tambah Anggota"
   - Pilih metode:
     - Undang via kode
     - Scan QR code anak

2. **Pantau Lokasi**
   - Buka halaman "Location" atau "Map"
   - Lihat lokasi real-time semua anggota keluarga di peta
   - Klik marker untuk detail

3. **Pairing Smartwatch**
   - Buka menu "Smartwatch" atau "Jam Tangan"
   - Klik "Pair New Device"
   - Scan QR code dari smartwatch anak

### Untuk Anak (Child)

1. **Terima Undangan**
   - Masukkan kode undangan dari orang tua
   - Atau tunjukkan QR code untuk di-scan

2. **Berikan Izin Lokasi**
   - Aplikasi akan meminta izin lokasi
   - Izinkan "Always" atau "Selalu" untuk tracking real-time

3. **Setup Smartwatch (Opsional)**
   - Install aplikasi watch di smartwatch
   - Login dengan akun yang sama
   - Buka halaman QR Pairing
   - Tunjukkan QR code ke orang tua untuk di-scan

## ⚙️ Konfigurasi IoT (Opsional)

Jika ingin mengintegrasikan dengan perangkat IoT:

1. Edit `aplikasi2/lib/utils/iot_config.dart`
2. Sesuaikan IP dan port perangkat IoT Anda
3. Buka halaman "IoT Device" di aplikasi
4. Koneksi ke perangkat

## 🔧 Troubleshooting

### Build Error

```bash
cd aplikasi2
flutter clean
flutter pub get
flutter run
```

### Google Maps Tidak Muncul
- Pastikan API key sudah benar
- Pastikan Maps SDK for Android sudah enabled
- Pastikan API key tidak ada pembatasan yang memblokir aplikasi

### Firebase Connection Error
- Cek `google-services.json` sudah di lokasi yang benar
- Pastikan package name sama dengan di Firebase Console
- Rebuild aplikasi setelah menambahkan config

### Lokasi Tidak Update
- Pastikan izin lokasi sudah diberikan
- Cek GPS device sudah aktif
- Pastikan ada koneksi internet

### Smartwatch Tidak Bisa Pairing
- Pastikan kedua device (phone & watch) terkoneksi internet
- Pastikan sudah login dengan akun yang benar
- Coba generate QR code baru

## 📞 Testing

### Test di Emulator

```bash
# Jalankan emulator
flutter emulators --launch <emulator_id>

# Run app
flutter run
```

### Test dengan Device Fisik

1. Enable USB Debugging di Android device
2. Hubungkan via USB
3. `flutter devices` untuk cek koneksi
4. `flutter run` untuk install dan jalankan

## 🏗️ Build APK

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

APK akan tersimpan di: `aplikasi2/build/app/outputs/flutter-apk/`

## 👥 Kontributor

Projek PAM - UAS Semester 5

## 📄 Lisensi

Educational Project - Untuk keperluan akademik

---

**Note**: Pastikan untuk tidak men-commit file `google-services.json` ke repository publik karena berisi sensitive information. File tersebut sudah masuk dalam `.gitignore`.

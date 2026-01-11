# Setup Firebase untuk Aplikasi

## 🔥 Langkah-langkah Setup Firebase

### 1. Install Dependencies
Jalankan perintah berikut untuk menginstall dependencies:
```bash
flutter pub get
```

### 2. Setup Firebase Project

#### a. Buat Project Firebase
1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik "Add project" atau "Buat project"
3. Beri nama project (misal: "aplikasi2" atau "kiddo-app")
4. Ikuti wizard setup hingga selesai

#### b. Install Firebase CLI
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login ke Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

#### c. Konfigurasi Firebase untuk Flutter
Jalankan perintah ini di root project:
```bash
flutterfire configure
```

Perintah ini akan:
- Menampilkan list project Firebase
- Pilih project yang sudah dibuat
- Pilih platform yang akan digunakan (Android, iOS, Web)
- Otomatis membuat file `firebase_options.dart`

### 3. Enable Firebase Authentication

1. Buka Firebase Console
2. Pilih project Anda
3. Di menu sebelah kiri, klik "**Build**" → "**Authentication**"
4. Klik "**Get started**"
5. Tab "**Sign-in method**"
6. Enable "**Email/Password**"
   - Klik pada "Email/Password"
   - Toggle "Enable" → ON
   - Klik "Save"

### 4. Enable Cloud Firestore (Optional tapi Direkomendasikan)

1. Di Firebase Console, klik "**Build**" → "**Firestore Database**"
2. Klik "**Create database**"
3. Pilih mode:
   - **Production mode**: Untuk production (lebih aman)
   - **Test mode**: Untuk development (lebih mudah)
4. Pilih lokasi server (pilih yang terdekat, misal: asia-southeast1)
5. Klik "Enable"

### 5. Security Rules Firestore (Jika menggunakan Firestore)

Atur security rules di Firestore:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Rules untuk koleksi users
    match /users/{userId} {
      // User hanya bisa read/write data mereka sendiri
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Rules lainnya bisa ditambahkan sesuai kebutuhan
  }
}
```

### 6. Update main.dart

File `main.dart` sudah diupdate dengan Firebase initialization. Pastikan file `firebase_options.dart` sudah ter-generate setelah menjalankan `flutterfire configure`.

### 7. Jalankan Aplikasi

```bash
flutter run
```

## 📱 Platform Specific Setup

### Android

File yang perlu diperhatikan:
- `android/app/google-services.json` (otomatis dibuat oleh flutterfire)
- Pastikan minSdkVersion minimal 21 di `android/app/build.gradle.kts`

### iOS

File yang perlu diperhatikan:
- `ios/Runner/GoogleService-Info.plist` (otomatis dibuat oleh flutterfire)
- Pastikan iOS deployment target minimal 12.0

## ✨ Fitur yang Sudah Diimplementasikan

### 1. **Login Page** ([lib/pages/login_page.dart](lib/pages/login_page.dart))
- ✅ Login dengan email dan password
- ✅ Validasi input
- ✅ Loading indicator
- ✅ Error handling dengan pesan yang jelas
- ✅ Forgot password functionality
- ✅ Integrasi dengan UserRole untuk role management

### 2. **Register Page** ([lib/pages/register_page.dart](lib/pages/register_page.dart))
- ✅ Registrasi dengan email, password, dan nama
- ✅ Validasi password minimal 6 karakter
- ✅ Loading indicator
- ✅ Error handling
- ✅ Auto simpan data user ke Firestore

### 3. **Auth Service** ([lib/services/auth_service.dart](lib/services/auth_service.dart))
- ✅ Sign in with email/password
- ✅ Register with email/password
- ✅ Sign out
- ✅ Reset password
- ✅ Get user data from Firestore
- ✅ Update user data
- ✅ Auth state stream

## 🔒 Keamanan

1. **Password**: Minimal 6 karakter (bisa ditingkatkan)
2. **Email Validation**: Menggunakan Firebase email validation
3. **Firestore Rules**: User hanya bisa akses data mereka sendiri
4. **Error Handling**: Semua error Firebase ditangani dengan baik

## 📝 Cara Menggunakan

### Register User Baru
1. Buka aplikasi
2. Klik "Daftar"
3. Isi nama lengkap, email, dan password
4. Klik tombol "Daftar"
5. Jika berhasil, akan redirect ke halaman login

### Login
1. Masukkan email dan password yang sudah didaftarkan
2. Klik tombol "Masuk"
3. Jika berhasil, akan masuk ke aplikasi

### Lupa Password
1. Di halaman login, masukkan email
2. Klik "Lupa Kata Sandi?"
3. Cek email untuk link reset password

## 🚨 Troubleshooting

### Error: "MissingPluginException"
```bash
flutter clean
flutter pub get
# Untuk iOS
cd ios && pod install && cd ..
# Jalankan ulang aplikasi
```

### Error: "Firebase not configured"
Pastikan sudah menjalankan `flutterfire configure` dan file `firebase_options.dart` sudah ada.

### Error: "Default FirebaseApp not initialized"
Pastikan `Firebase.initializeApp()` dipanggil di `main()` sebelum `runApp()`.

## 📚 Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)

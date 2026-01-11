# 👨‍👩‍👧‍👦 KIDDO - Family Tracking App

Flutter application dengan Firebase Authentication untuk tracking dan monitoring keluarga.

> **🤝 Untuk Collaborator:** Baca [COLLABORATOR_SETUP.md](COLLABORATOR_SETUP.md) untuk panduan lengkap setup project ini.

## 🔥 Firebase Authentication

Aplikasi ini sudah terintegrasi dengan **Firebase Authentication** untuk login dan registrasi user.

### ✨ Fitur Authentication:
- ✅ **Login** dengan email & password
- ✅ **Register** user baru
- ✅ **Forgot Password** (reset via email)
- ✅ **Logout** dengan clear session
- ✅ **Auto save** user data ke Firestore
- ✅ **Role management** (Parent/Child)

## 🤝 Collaboration & Firebase Access

### Untuk Pemilik Project:

Jika ingin menambahkan collaborator yang bisa akses Firebase:

1. **Tambahkan di Firebase Console:**
   - Buka [Firebase Console](https://console.firebase.google.com)
   - Pilih project → Settings (⚙️) → Users and Permissions
   - Add Member → masukkan email collaborator
   - Pilih role **Editor** atau **Viewer**

2. **Repository Settings:**
   - Pastikan menggunakan **Private Repository** di GitHub
   - File Firebase config sudah ter-commit (check `.gitignore`)
   - Share repository URL ke collaborator

### Untuk Collaborator:

Baca panduan lengkap di **[COLLABORATOR_SETUP.md](COLLABORATOR_SETUP.md)**

## 🚀 Quick Start

### 1. Setup Firebase

Ikuti langkah-langkah di **[QUICK_START.md](QUICK_START.md)** untuk setup Firebase:

```bash
# Install Firebase CLI
npm install -g firebase-tools
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase untuk project ini
flutterfire configure
```

### 2. Enable Authentication di Firebase Console
1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project Anda
3. **Build** → **Authentication** → **Get started**
4. Enable **Email/Password**

### 3. Install Dependencies & Run

```bash
flutter pub get
flutter run
```

## 📁 Struktur Project

```
lib/
├── main.dart                       # App entry point dengan Firebase init
├── firebase_options.dart           # Firebase configuration (auto-generated)
├── services/
│   └── auth_service.dart          # Firebase Auth service
├── pages/
│   ├── login_page.dart            # Login dengan Firebase
│   ├── register_page.dart         # Register dengan Firebase
│   ├── profile_page.dart          # Profile dengan logout
│   └── ...                        # Pages lainnya
├── widgets/
│   ├── auth_wrapper.dart          # Auth state checker
│   └── ...                        # Widgets lainnya
└── utils/
    └── user_role.dart             # Role management
```

## 📖 Dokumentasi

- **[QUICK_START.md](QUICK_START.md)** - Panduan cepat setup Firebase
- **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** - Dokumentasi lengkap Firebase setup
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Summary implementasi
- **[GOOGLE_MAPS_SETUP.md](GOOGLE_MAPS_SETUP.md)** - Setup Google Maps (jika diperlukan)

## 🔑 Auth Service API

File: [lib/services/auth_service.dart](lib/services/auth_service.dart)

### Methods:

```dart
// Login
final result = await authService.signInWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password123',
);

// Register
final result = await authService.registerWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password123',
  name: 'Nama User',
  role: 'parent',
);

// Logout
await authService.signOut();

// Reset Password
final result = await authService.resetPassword(
  email: 'user@example.com',
);

// Get User Data
final userData = await authService.getUserData(uid);

// Update User Data
await authService.updateUserData(uid, {'name': 'New Name'});
```

## 🎯 Cara Menggunakan

### Register User Baru:
1. Buka aplikasi
2. Klik **"Daftar"** di welcome screen
3. Isi form:
   - Nama Lengkap
   - Email
   - Jenis Kelamin (optional)
   - Tanggal Lahir (optional)
   - Password (minimal 6 karakter)
4. Klik **"Daftar"**
5. Akan redirect ke login page

### Login:
1. Masukkan email dan password
2. Klik **"Masuk"**
3. Jika berhasil, masuk ke aplikasi

### Lupa Password:
1. Di login page, masukkan email Anda
2. Klik **"Lupa Kata Sandi?"**
3. Cek email untuk link reset password

### Logout:
1. Buka menu **Profile**
2. Scroll ke bawah
3. Klik **"Keluar"**
4. Confirm di dialog

## 🔐 Security

- Password minimal 6 karakter
- Email validation otomatis
- Firestore security rules (recommended untuk production)
- User hanya bisa akses data mereka sendiri

## 🛠️ Technologies

- **Flutter** ^3.9.2
- **Firebase Core** ^3.8.1
- **Firebase Auth** ^5.3.3
- **Cloud Firestore** ^5.5.2
- **Flutter Map** ^6.0.0
- **Geolocator** ^10.1.0
- **Permission Handler** ^11.0.1

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ⚠️ Web (perlu konfigurasi tambahan)

## 🐛 Troubleshooting

### Error: Firebase not initialized
**Solusi**: Jalankan `flutterfire configure`

### Error: MissingPluginException
```bash
flutter clean
flutter pub get
# Untuk iOS
cd ios && pod install && cd ..
```

### Build Error
```bash
flutter clean
flutter pub get
flutter run
```

## 📞 Support

Untuk pertanyaan atau issue, silakan buat issue di repository ini.

## 📄 License

This project is licensed under the MIT License.

---

**Happy Coding! 🚀**


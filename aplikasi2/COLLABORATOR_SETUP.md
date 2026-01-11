# Panduan Setup untuk Collaborator

Selamat datang! Panduan ini akan membantu Anda untuk setup project ini di komputer Anda.

## 📋 Prerequisites

Pastikan Anda sudah menginstall:
- **Flutter SDK** (versi terbaru)
- **Android Studio** atau **VS Code** dengan Flutter extension
- **Git**
- **Java JDK** (untuk Android development)

## 🚀 Langkah Setup

### 1. Clone Repository

```bash
git clone <URL_REPOSITORY_GITHUB>
cd aplikasi2
```

### 2. Install Dependencies

```bash
flutter pub get
cd ../aplikasi2_watch
flutter pub get
cd ../aplikasi2
```

### 3. Setup Firebase (PENTING!)

File konfigurasi Firebase sudah disertakan dalam repository ini, tetapi Anda perlu:

#### A. Minta Akses Firebase Console

Minta pemilik project untuk menambahkan email Google Anda sebagai **Editor** di:
- Buka [Firebase Console](https://console.firebase.google.com)
- Pilih project ini
- Settings (⚙️) → Users and Permissions
- Add Member → masukkan email Anda dengan role **Editor**

#### B. Verifikasi File Firebase

Pastikan file-file ini ada:
- ✅ `lib/firebase_options.dart`
- ✅ `android/app/google-services.json`
- ✅ `ios/Runner/GoogleService-Info.plist`

Jika tidak ada, jalankan:
```bash
flutterfire configure
```

### 4. Setup Android

Buat file `android/local.properties`:
```properties
sdk.dir=C:\\Users\\<YOUR_USERNAME>\\AppData\\Local\\Android\\sdk
flutter.sdk=C:\\flutter
```

Sesuaikan path dengan lokasi SDK di komputer Anda.

### 5. Setup Google Maps API Key (Optional)

Jika Anda perlu mengganti API key:

**Android** - Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

**iOS** - Edit `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

### 6. Build dan Run

#### Untuk Aplikasi Mobile (aplikasi2):
```bash
flutter run
```

#### Untuk Smartwatch (aplikasi2_watch):
```bash
cd ../aplikasi2_watch
flutter run
```

## 🔐 Keamanan Firebase

**PENTING:** File Firebase configuration sudah di-commit ke repository untuk memudahkan kolaborasi. Ini berarti:

✅ **Aman jika:**
- Firestore Security Rules sudah dikonfigurasi dengan benar
- Authentication diaktifkan
- Hanya collaborator terpercaya yang punya akses

⚠️ **Perhatian:**
- Jangan share repository ke public GitHub
- Gunakan **Private Repository**
- Jaga Firestore Rules tetap ketat

### Cek Firestore Rules

Rules ada di file `firestore.rules`. Pastikan seperti ini:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data - hanya bisa diakses oleh user yang login
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Family data - hanya anggota keluarga
    match /families/{familyId} {
      allow read, write: if request.auth != null && 
        exists(/databases/$(database)/documents/families/$(familyId)/members/$(request.auth.uid));
    }
  }
}
```

## 📱 Testing

### Test Aplikasi Mobile:
```bash
cd aplikasi2
flutter test
```

### Test Smartwatch:
```bash
cd aplikasi2_watch
flutter test
```

## 🐛 Troubleshooting

### Problem: "Firebase not initialized"
**Solusi:** 
```bash
flutterfire configure
```

### Problem: "Google Services plugin error"
**Solusi:** Pastikan `google-services.json` ada di `android/app/`

### Problem: "Module not found"
**Solusi:**
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean
cd .. && flutter run
```

### Problem: "API key invalid"
**Solusi:** Regenerate API key di Firebase Console → Project Settings → Add App

## 📚 Dokumentasi Lengkap

- [Firebase Setup](FIREBASE_SETUP.md)
- [Google Maps Setup](GOOGLE_MAPS_SETUP.md)
- [QR Pairing Guide](QR_PAIRING_GUIDE.md)
- [Testing Guide](TESTING_GUIDE.md)
- [Troubleshooting](TROUBLESHOOTING.md)

## 🤝 Contribution Guidelines

1. **Branch Strategy:**
   - `main` - production ready code
   - `develop` - development branch
   - `feature/*` - untuk fitur baru
   - `fix/*` - untuk bug fixes

2. **Commit Messages:**
   ```
   feat: menambahkan fitur X
   fix: memperbaiki bug Y
   docs: update dokumentasi Z
   style: formatting code
   refactor: refactor code tanpa mengubah behavior
   test: menambahkan atau update tests
   ```

3. **Pull Request:**
   - Buat branch baru dari `develop`
   - Test semua fitur
   - Push dan buat Pull Request ke `develop`
   - Tunggu review dari maintainer

## 💬 Kontak

Jika ada masalah atau pertanyaan, hubungi pemilik project atau buat Issue di GitHub.

---

**Selamat coding! 🚀**

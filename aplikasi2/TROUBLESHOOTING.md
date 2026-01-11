# 🔧 Troubleshooting - Firebase Authentication Issues

## Setup Issues

### ❌ Error: "DefaultFirebaseApp has not been initialized"

**Penyebab**: Firebase belum diinisialisasi atau `firebase_options.dart` tidak ada

**Solusi**:
```bash
# Step 1: Install Firebase CLI
npm install -g firebase-tools

# Step 2: Login Firebase
firebase login

# Step 3: Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Step 4: Configure Firebase
flutterfire configure

# Step 5: Restart app
flutter clean
flutter pub get
flutter run
```

---

### ❌ Error: "MissingPluginException"

**Penyebab**: Plugin belum teregister atau cache kotor

**Solusi**:
```bash
# Clean project
flutter clean

# Get dependencies
flutter pub get

# Untuk Android
flutter run

# Untuk iOS
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

---

### ❌ Error: "firebase_options.dart: No such file or directory"

**Penyebab**: File `firebase_options.dart` belum di-generate

**Solusi**:
```bash
# Generate firebase_options.dart
flutterfire configure

# Pilih project Firebase yang sudah dibuat
# Pilih platform (Android/iOS)
# File akan otomatis dibuat
```

---

### ❌ Error: "You need to enable JavaScript to run this app"

**Penyebab**: Mencoba run di web tapi belum configure untuk web

**Solusi**:
```bash
# Configure untuk web
flutterfire configure --platforms=web

# Atau run di mobile
flutter run -d android
flutter run -d ios
```

---

## Authentication Issues

### ❌ Error: "An internal error has occurred"

**Penyebab**: Firebase Auth belum enabled di console

**Solusi**:
1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project Anda
3. **Build** → **Authentication**
4. Klik **Get started**
5. Tab **Sign-in method**
6. Enable **Email/Password**
7. Klik **Save**

---

### ❌ Login/Register tidak berfungsi, tidak ada error

**Debug steps**:
```dart
// Tambahkan print di login_page.dart
print('Email: ${_emailController.text}');
print('Password: ${_passwordController.text}');

// Check hasil dari AuthService
print('Result: $result');
```

**Kemungkinan penyebab**:
1. Firebase Auth belum enabled
2. Network issue
3. firebase_options.dart salah

---

### ❌ Email reset password tidak terkirim

**Penyebab**: Email template belum dikonfigurasi

**Solusi**:
1. Firebase Console → **Authentication**
2. Tab **Templates**
3. Klik **Password reset**
4. Customize email template (optional)
5. Save

**Note**: Cek folder spam di email

---

### ❌ Error: "The email address is already in use"

**Penyebab**: Email sudah terdaftar di Firebase Auth

**Solusi**:
- Gunakan email lain untuk register
- Atau login dengan email yang sudah ada
- Atau hapus user dari Firebase Console → Authentication → Users

---

### ❌ Error: "The password is invalid"

**Penyebab**: Password salah atau user tidak ada

**Solusi**:
1. Cek password (case-sensitive)
2. Gunakan forgot password jika lupa
3. Verify user exists di Firebase Console

---

## Firestore Issues

### ❌ Error: "Cloud Firestore is not enabled"

**Penyebab**: Firestore belum dibuat

**Solusi**:
1. Firebase Console → **Firestore Database**
2. Klik **Create database**
3. Pilih **Test mode** (untuk development)
4. Pilih lokasi server terdekat
5. Klik **Enable**

---

### ❌ Data tidak tersimpan di Firestore

**Debug steps**:
```dart
// Tambahkan try-catch di auth_service.dart
try {
  await _firestore.collection('users').doc(result.user!.uid).set({...});
  print('Data saved successfully');
} catch (e) {
  print('Error saving data: $e');
}
```

**Kemungkinan penyebab**:
1. Firestore belum enabled
2. Security rules terlalu ketat
3. Network issue

---

### ❌ Error: "PERMISSION_DENIED"

**Penyebab**: Firestore security rules menolak akses

**Solusi - Test Mode** (Development):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

**Solusi - Production**:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## Build Issues

### ❌ Android Build Error: "Execution failed for ':app:processDebugGoogleServices'"

**Penyebab**: `google-services.json` tidak ada atau salah

**Solusi**:
```bash
# Re-configure Firebase
flutterfire configure

# Check file ada
ls android/app/google-services.json

# Clean dan rebuild
flutter clean
flutter pub get
flutter run
```

---

### ❌ iOS Build Error: "GoogleService-Info.plist not found"

**Penyebab**: File GoogleService-Info.plist tidak ada

**Solusi**:
```bash
# Re-configure Firebase
flutterfire configure

# Check file ada
ls ios/Runner/GoogleService-Info.plist

# Clean dan rebuild
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

---

### ❌ Error: "Minimum SDK version"

**Penyebab**: Firebase membutuhkan minimum SDK

**Solusi untuk Android** (`android/app/build.gradle.kts`):
```kotlin
defaultConfig {
    minSdk = 21  // Minimal 21 untuk Firebase
    targetSdk = 34
}
```

**Solusi untuk iOS** (`ios/Podfile`):
```ruby
platform :ios, '12.0'  # Minimal 12.0 untuk Firebase
```

---

## Runtime Issues

### ❌ App crash saat startup

**Debug steps**:
1. Check logs:
   ```bash
   flutter run --verbose
   ```

2. Verify Firebase initialization di `main.dart`:
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
     runApp(const MyApp());
   }
   ```

---

### ❌ Loading terus menerus

**Kemungkinan penyebab**:
1. API call stuck
2. Network timeout
3. Firebase not responding

**Debug**:
```dart
// Tambahkan timeout
try {
  final result = await authService
      .signInWithEmailAndPassword(...)
      .timeout(Duration(seconds: 30));
} on TimeoutException {
  print('Request timeout');
}
```

---

### ❌ State tidak update setelah login

**Penyebab**: setState tidak dipanggil atau context hilang

**Solusi**:
```dart
if (!mounted) return;  // Check mounted sebelum setState

setState(() {
  _isLoading = false;
});
```

---

## Network Issues

### ❌ Error: "A network error has occurred"

**Penyebab**: Tidak ada koneksi internet atau Firebase unreachable

**Solusi**:
1. Check koneksi internet
2. Check Firebase Status: https://status.firebase.google.com/
3. Try again atau tambahkan retry logic

---

### ❌ Error: "Too many requests"

**Penyebab**: Terlalu banyak request dalam waktu singkat

**Solusi**:
1. Tunggu beberapa menit
2. Implementasi rate limiting
3. Check Firebase quotas

---

## Development Issues

### ❌ Hot reload tidak bekerja setelah tambah Firebase

**Solusi**:
```bash
# Full restart diperlukan setelah add Firebase
# Press 'R' (capital R) di terminal
# Atau
flutter run
```

---

### ❌ Dependency conflict

**Error message**: "version solving failed"

**Solusi**:
```bash
# Update dependencies
flutter pub upgrade

# Atau gunakan versi specific yang compatible
# Edit pubspec.yaml:
firebase_core: ^3.8.1
firebase_auth: ^5.3.3
cloud_firestore: ^5.5.2
```

---

## Testing Issues

### ❌ Unit test error setelah add Firebase

**Solusi**: Mock Firebase di test

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

void main() {
  setupFirebaseMocks();
  
  setUpAll(() async {
    await Firebase.initializeApp();
  });
  
  // Your tests here
}

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Setup mock
}
```

---

## Production Issues

### ⚠️ Security Rules terlalu terbuka

**Problem**: Rules test mode di production

**Solusi**: Update Firestore rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

### ⚠️ API Keys exposed

**Problem**: firebase_options.dart di git public

**Solusi**:
1. Add ke `.gitignore`:
   ```
   firebase_options.dart
   google-services.json
   GoogleService-Info.plist
   ```

2. Setup restrictions di Firebase Console:
   - Project Settings → API Keys
   - Add application restrictions
   - Add API restrictions

---

## Quick Debug Commands

```bash
# Check Flutter doctor
flutter doctor -v

# Check dependencies
flutter pub deps

# Clean everything
flutter clean
rm -rf ios/Pods
rm ios/Podfile.lock
flutter pub get
cd ios && pod install && cd ..

# Run with logs
flutter run --verbose

# Check Firebase project
firebase projects:list
```

---

## Getting Help

### Still have issues?

1. **Check logs**: `flutter run --verbose`
2. **Firebase Status**: https://status.firebase.google.com/
3. **Stack Overflow**: Tag `flutter`, `firebase`, `dart`
4. **GitHub Issues**: 
   - FlutterFire: https://github.com/firebase/flutterfire/issues
   - Flutter: https://github.com/flutter/flutter/issues

### Useful Resources:
- **FlutterFire Docs**: https://firebase.flutter.dev/
- **Firebase Docs**: https://firebase.google.com/docs
- **Flutter Docs**: https://flutter.dev/docs

---

**Semoga membantu! 🚀**

# ✅ LANGKAH TERAKHIR - Enable Firebase Authentication

## 🎯 Setup Sudah Selesai!

File konfigurasi Firebase sudah disetup dengan benar:
- ✅ `google-services.json` → `android/app/google-services.json`
- ✅ `firebase_options.dart` → konfigurasi lengkap
- ✅ Android Gradle files → sudah update
- ✅ Dependencies → sudah terinstall

## 🔥 Yang Perlu Anda Lakukan Sekarang:

### 1. Enable Email/Password Authentication

1. **Buka Firebase Console**:
   - Link: https://console.firebase.google.com/
   - Atau klik: https://console.firebase.google.com/project/aplikasi2-9ab49/overview

2. **Pilih Project Anda**: `aplikasi2-9ab49`

3. **Navigate ke Authentication**:
   - Di sidebar kiri, klik **"Build"**
   - Klik **"Authentication"**
   - Klik tombol **"Get started"** (jika belum pernah enable)

4. **Enable Email/Password**:
   - Klik tab **"Sign-in method"**
   - Cari **"Email/Password"** dalam daftar providers
   - Klik pada **"Email/Password"**
   - Toggle switch **"Enable"** → ON
   - Klik **"Save"**

   ✅ **DONE!** Email/Password authentication sekarang aktif!

### 6️⃣ Jalankan Aplikasi

```bash
flutter pub get
flutter run
```

## ✅ Yang Sudah Diimplementasikan

### Login Page
- ✅ Login dengan Firebase Authentication
- ✅ Validasi email & password
- ✅ Loading state
- ✅ Error handling
- ✅ Forgot password (kirim email reset)

### 2. (Optional tapi Recommended) Enable Cloud Firestore

Firestore digunakan untuk menyimpan data user (nama, role, dll).

1. Di sidebar Firebase Console, klik **"Build"** → **"Firestore Database"**
2. Klik tombol **"Create database"**
3. **Select mode**:
   - Untuk development/testing: Pilih **"Start in test mode"**
   - Untuk production: Pilih **"Start in production mode"**
4. **Select location**: Pilih `asia-southeast1 (Singapore)` atau terdekat
5. Klik **"Enable"**

#### Set Security Rules (Setelah enable Firestore):
Di tab **"Rules"**, update dengan:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Rules untuk collection users
    match /users/{userId} {
      // User hanya bisa read/write data mereka sendiri
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Klik **"Publish"**.

## 🚀 Test Aplikasi

```bash
# Clean dan rebuild
flutter clean
flutter pub get

# Run aplikasi
flutter run
```

## 📋 Testing Checklist:

### Test Register:
1. Buka aplikasi
2. Klik "Daftar"
3. Isi form:
   ```
   Nama: Test User
   Email: test@example.com
   Password: test123
   ```
4. Klik "Daftar"
5. ✅ Harus muncul: "Registrasi berhasil! Silakan login"
6. ✅ Redirect ke Login Page

### Verify di Firebase Console:
1. **Authentication** → **Users**
   - ✅ User baru harus muncul dengan email `test@example.com`

2. **Firestore Database** → **users collection** (jika Firestore enabled)
   - ✅ Document dengan uid user harus ada
   - ✅ Isi: `{uid, email, name, role, createdAt}`

### Test Login:
1. Di Login Page, masukkan:
   ```
   Email: test@example.com
   Password: test123
   ```
2. Klik "Masuk"
3. ✅ Harus berhasil login
4. ✅ Masuk ke MainNavigationPage

### Test Forgot Password:
1. Di Login Page, masukkan email yang terdaftar
2. Klik "Lupa Kata Sandi?"
3. ✅ Muncul konfirmasi email terkirim
4. ✅ Cek inbox email (cek folder spam juga)
5. ✅ Email dari Firebase harus ada dengan link reset password

### Test Logout:
1. Buka Profile Page
2. Scroll ke bawah
3. Klik "Keluar"
4. Confirm di dialog
5. ✅ Kembali ke Login Page

## 🎉 Selesai!

Jika semua test di atas berhasil, Firebase Authentication sudah berfungsi dengan sempurna!

## 📚 Resources:

- **Firebase Console**: https://console.firebase.google.com/project/aplikasi2-9ab49
- **Authentication**: https://console.firebase.google.com/project/aplikasi2-9ab49/authentication
- **Firestore**: https://console.firebase.google.com/project/aplikasi2-9ab49/firestore

## 🆘 Ada Masalah?

Lihat dokumentasi:
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Solusi error umum
- [TESTING_GUIDE.md](TESTING_GUIDE.md) - Panduan testing lengkap
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Setup detail

---

**Happy Coding! 🚀**

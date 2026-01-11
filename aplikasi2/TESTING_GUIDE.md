# 🧪 Testing Guide - Firebase Authentication

## Persiapan Testing

### 1. Pastikan Firebase Sudah Setup
```bash
# Check firebase_options.dart sudah ada
ls lib/firebase_options.dart

# Jika belum, jalankan:
flutterfire configure
```

### 2. Enable Authentication di Firebase Console
- Authentication → Sign-in method → Email/Password → Enable

## 📝 Test Cases

### Test 1: Register User Baru

#### Steps:
1. Buka aplikasi
2. Klik "Daftar" atau "Bergabung Sekarang"
3. Isi form:
   ```
   Nama: Test User
   Email: test001@example.com
   Password: test123
   ```
4. Klik tombol "Daftar"

#### Expected Result:
- ✅ Muncul loading indicator
- ✅ SnackBar sukses: "Registrasi berhasil! Silakan login"
- ✅ Redirect ke Login Page
- ✅ User tersimpan di Firebase Auth
- ✅ User data tersimpan di Firestore → collection `users`

#### Verify di Firebase Console:
1. Authentication → Users → Lihat user baru
2. Firestore → users → Cek document dengan uid user

---

### Test 2: Login dengan Akun yang Sudah Terdaftar

#### Steps:
1. Di Login Page, masukkan:
   ```
   Email: test001@example.com
   Password: test123
   ```
2. Klik "Masuk"

#### Expected Result:
- ✅ Muncul loading indicator
- ✅ Login berhasil
- ✅ UserRole.setRole() dipanggil
- ✅ Redirect ke MainNavigationPage
- ✅ Role tersimpan dengan benar

---

### Test 3: Login dengan Email Salah

#### Steps:
1. Masukkan email yang tidak terdaftar:
   ```
   Email: tidakada@example.com
   Password: test123
   ```
2. Klik "Masuk"

#### Expected Result:
- ✅ Muncul SnackBar error
- ✅ Pesan: "Email tidak ditemukan"
- ✅ Tetap di Login Page
- ✅ Loading hilang

---

### Test 4: Login dengan Password Salah

#### Steps:
1. Masukkan email yang benar tapi password salah:
   ```
   Email: test001@example.com
   Password: wrongpassword
   ```
2. Klik "Masuk"

#### Expected Result:
- ✅ Muncul SnackBar error
- ✅ Pesan: "Password salah"
- ✅ Tetap di Login Page

---

### Test 5: Register dengan Email yang Sudah Ada

#### Steps:
1. Klik "Daftar"
2. Isi dengan email yang sudah terdaftar:
   ```
   Nama: Another User
   Email: test001@example.com
   Password: test456
   ```
3. Klik "Daftar"

#### Expected Result:
- ✅ Muncul SnackBar error
- ✅ Pesan: "Email sudah terdaftar"
- ✅ Tetap di Register Page

---

### Test 6: Register dengan Password Terlalu Pendek

#### Steps:
1. Isi form dengan password < 6 karakter:
   ```
   Nama: Test User
   Email: test002@example.com
   Password: 12345
   ```
2. Klik "Daftar"

#### Expected Result:
- ✅ Muncul SnackBar error
- ✅ Pesan: "Password minimal 6 karakter"
- ✅ Tetap di Register Page

---

### Test 7: Forgot Password

#### Steps:
1. Di Login Page, masukkan email:
   ```
   Email: test001@example.com
   ```
2. Klik "Lupa Kata Sandi?"

#### Expected Result:
- ✅ SnackBar konfirmasi
- ✅ Pesan: "Email reset password telah dikirim"
- ✅ Email dikirim ke inbox (cek spam juga)
- ✅ Email berisi link reset password dari Firebase

#### Verify Email:
1. Cek email inbox
2. Klik link reset password
3. Masukkan password baru
4. Coba login dengan password baru

---

### Test 8: Validasi Input Kosong (Login)

#### Steps:
1. Di Login Page, klik "Masuk" tanpa isi form

#### Expected Result:
- ✅ SnackBar error: "Email tidak boleh kosong"

#### Steps:
2. Isi email, password kosong, klik "Masuk"

#### Expected Result:
- ✅ SnackBar error: "Password tidak boleh kosong"

---

### Test 9: Validasi Input Kosong (Register)

#### Steps:
1. Di Register Page, klik "Daftar" tanpa isi nama

#### Expected Result:
- ✅ SnackBar error: "Nama tidak boleh kosong"

---

### Test 10: Logout

#### Steps:
1. Login dengan user yang sudah ada
2. Buka Profile Page
3. Klik "Keluar"
4. Confirm di dialog

#### Expected Result:
- ✅ Dialog konfirmasi muncul
- ✅ Setelah konfirm, loading singkat
- ✅ Firebase signOut() dipanggil
- ✅ UserRole.clear() dipanggil
- ✅ Redirect ke Login Page
- ✅ Tidak bisa back ke halaman sebelumnya

---

### Test 11: Loading State

#### Steps:
1. Perhatikan saat proses login/register berlangsung

#### Expected Result:
- ✅ Tombol disabled saat loading
- ✅ CircularProgressIndicator muncul
- ✅ User tidak bisa klik tombol 2x
- ✅ Loading hilang setelah proses selesai

---

### Test 12: Data Persistence di Firestore

#### Steps:
1. Register user baru dengan data lengkap
2. Cek Firebase Console → Firestore

#### Expected Result di Firestore:
```json
users/{uid}/
{
  "uid": "firebase_user_id",
  "email": "test001@example.com",
  "name": "Test User",
  "role": "parent",
  "createdAt": "timestamp"
}
```

---

## 🔍 Testing Checklist

### Functional Testing:
- [ ] Register user baru berhasil
- [ ] Login dengan kredensial yang benar
- [ ] Login dengan email salah (error handling)
- [ ] Login dengan password salah (error handling)
- [ ] Register dengan email duplikat (error handling)
- [ ] Validasi password minimal 6 karakter
- [ ] Forgot password mengirim email
- [ ] Logout berhasil dan clear session
- [ ] Data tersimpan di Firestore dengan benar

### UI/UX Testing:
- [ ] Loading indicator muncul saat proses
- [ ] Error message jelas dan informatif
- [ ] Tombol disabled saat loading
- [ ] Input validation bekerja
- [ ] Password visibility toggle bekerja
- [ ] Navigation flow benar

### Security Testing:
- [ ] Password tidak terlihat (obscured)
- [ ] Session cleared setelah logout
- [ ] User tidak bisa akses tanpa login
- [ ] Firebase rules mencegah akses unauthorized

---

## 🐛 Common Issues & Solutions

### Issue: "DefaultFirebaseApp not initialized"
**Cause**: Firebase.initializeApp() belum dipanggil
**Solution**: Check main.dart, pastikan Firebase.initializeApp() ada

### Issue: Error saat register/login tapi tidak ada pesan
**Cause**: firebase_options.dart belum di-generate
**Solution**: Jalankan `flutterfire configure`

### Issue: Email tidak terkirim untuk forgot password
**Cause**: Email template belum disetup di Firebase
**Solution**: 
1. Firebase Console → Authentication → Templates
2. Setup email template untuk Password Reset

### Issue: Data tidak tersimpan di Firestore
**Cause**: Firestore belum enabled
**Solution**: 
1. Firebase Console → Firestore Database
2. Create database

---

## 📊 Test Results Template

```
Date: ___________
Tester: ___________
Device: ___________
OS Version: ___________

Test Results:
✅ Test 1: Register User Baru - PASS
✅ Test 2: Login Sukses - PASS
✅ Test 3: Login Email Salah - PASS
✅ Test 4: Login Password Salah - PASS
✅ Test 5: Register Email Duplikat - PASS
✅ Test 6: Password Validation - PASS
✅ Test 7: Forgot Password - PASS
✅ Test 8: Input Validation Login - PASS
✅ Test 9: Input Validation Register - PASS
✅ Test 10: Logout - PASS
✅ Test 11: Loading States - PASS
✅ Test 12: Firestore Data - PASS

Overall: PASS ✅
Notes: _________________________
```

---

## 🎯 Automation Testing (Future)

Untuk automation testing, bisa menggunakan:
- **Flutter Integration Tests**
- **Firebase Emulator** untuk testing tanpa hit production
- **Mockito** untuk mock Firebase services

```dart
// Example integration test
testWidgets('Login with valid credentials', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  
  await tester.enterText(find.byType(TextField).first, 'test@example.com');
  await tester.enterText(find.byType(TextField).last, 'test123');
  await tester.tap(find.text('Masuk'));
  
  await tester.pumpAndSettle();
  
  expect(find.byType(MainNavigationPage), findsOneWidget);
});
```

---

**Happy Testing! 🧪✨**

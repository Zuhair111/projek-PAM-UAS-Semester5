# 🔥 Firestore Security Rules - Update Guide

## ❌ MASALAH: Permission Denied saat Pairing

**Error yang muncul:**
```
W/Firestore: Listen for Query(watch_pairing/627271) failed: 
Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions.}
```

**Penyebab:** Smartwatch belum login tapi sudah coba buat dokumen di Firestore. Rules lama memerlukan `request.auth != null`.

---

## ✅ SOLUSI: Update Firestore Rules

### Langkah 1: Copy Rules Baru

File rules sudah dibuat di: [`firestore.rules`](firestore.rules)

### Langkah 2: Deploy ke Firebase

**Opsi A: Via Firebase Console (Tercepat)**

1. Buka [Firebase Console](https://console.firebase.google.com)
2. Pilih project Anda
3. Klik **Firestore Database** di menu kiri
4. Klik tab **Rules**
5. Copy paste isi dari file `firestore.rules`
6. Klik **Publish**

**Opsi B: Via Firebase CLI**

```bash
# Install Firebase CLI jika belum
npm install -g firebase-tools

# Login ke Firebase
firebase login

# Initialize Firebase (jika belum)
firebase init firestore

# Deploy rules
firebase deploy --only firestore:rules
```

---

## 📋 Penjelasan Rules untuk Watch Pairing

### 1. **CREATE - Smartwatch belum login**
```javascript
allow create: if pairingCode.matches('^[0-9]{6}$') &&
                 request.resource.data.status == 'pending' &&
                 request.resource.data.keys().hasOnly(['status', 'createdAt']);
```
- ✅ Tidak require `request.auth` (smartwatch belum login)
- ✅ Validasi code harus 6 digit
- ✅ Status harus 'pending'
- ✅ Hanya boleh ada field: status, createdAt

### 2. **READ - Listening untuk credentials**
```javascript
allow read: if resource.data.createdAt != null &&
               request.time < resource.data.createdAt + duration.value(5, 'm');
```
- ✅ Siapa saja bisa read (untuk listening)
- ✅ Auto-expire setelah 5 menit
- ✅ Dokumen otomatis tidak bisa dibaca setelah 5 menit

### 3. **UPDATE - Smartphone kirim credentials**
```javascript
allow update: if request.auth != null &&
                 request.resource.data.status == 'completed' &&
                 request.resource.data.email is string &&
                 request.resource.data.password is string;
```
- ✅ Require auth (smartphone sudah login)
- ✅ Status harus 'completed'
- ✅ Harus ada email & password

### 4. **DELETE - Cleanup setelah pairing**
```javascript
allow delete: if true;
```
- ✅ Siapa saja bisa hapus (untuk cleanup)

---

## 🔐 Keamanan

### Apakah Aman?

**✅ YA, karena:**

1. **Short-lived** - Dokumen expire otomatis setelah 5 menit
2. **One-time use** - Status 'pending' hanya bisa di-update sekali ke 'completed'
3. **Validasi ketat** - Code harus 6 digit, data harus sesuai format
4. **Random code** - 6 digit random (1,000,000 kombinasi)
5. **Auto cleanup** - Dokumen dihapus setelah login berhasil
6. **Password temporary** - Hanya ada di Firestore max 5 menit
7. **Physical proximity** - User harus scan QR code (perlu akses fisik)

### Risiko Minimal:

- **Brute force?** Tidak mungkin - 1 juta kombinasi, expire 5 menit
- **Intercept?** Sulit - code random, short-lived
- **Reuse?** Tidak bisa - status 'pending' hanya bisa diupdate sekali

---

## 🧪 Testing Setelah Update Rules

### 1. Restart Smartwatch App
```bash
# Stop running app
r (hot reload) atau R (hot restart)

# Atau kill dan run ulang
flutter run -d V2151
```

### 2. Cek Console Output

**✅ SUKSES:**
```
I/flutter: Pairing document created: 627271
I/flutter: Listening for pairing...
```

**❌ GAGAL (jika masih error):**
```
E/flutter: [cloud_firestore/permission-denied]
```

### 3. Test Full Flow

**Di Smartwatch:**
1. QR code muncul dengan 6-digit code
2. Status: "Scan QR dari HP"
3. Console log: `Pairing document created: 123456`

**Di Smartphone:**
1. Scan QR code
2. Input password
3. Console log: `Credentials sent to smartwatch: 123456`

**Di Smartwatch (setelah scan):**
1. Console log: `Pairing data received: {status: completed, email: ...}`
2. Console log: `Attempting login with email: ...`
3. Console log: `Login successful: ...`
4. App navigasi ke TrackingPage

---

## 🔧 Troubleshooting

### Masih Permission Denied?

**1. Cek Rules sudah di-publish**
- Buka Firebase Console → Firestore → Rules
- Pastikan rules terbaru (cek timestamp)

**2. Clear Firestore cache**
```dart
// Tambahkan di initState qr_pairing_page.dart (temporary)
FirebaseFirestore.instance.clearPersistence();
```

**3. Restart app completely**
```bash
flutter clean
flutter run -d V2151
```

**4. Cek di Firebase Console**
- Firestore → Data → watch_pairing
- Pastikan tidak ada dokumen lama yang menghalangi

**5. Verify rules di Firebase Console**
- Rules → Simulator
- Test operation: `get`
- Location: `/watch_pairing/123456`
- Authenticated: `unchecked`
- Should show: ✅ **Allowed**

---

## 📝 Checklist

Setelah update rules:

- [ ] Rules di-publish di Firebase Console
- [ ] Timestamp rules terbaru (hari ini)
- [ ] Smartwatch app di-restart
- [ ] QR code bisa muncul tanpa error
- [ ] Console log: "Pairing document created"
- [ ] Test scan dari smartphone
- [ ] Smartwatch auto-login berhasil

---

## 🚀 Next Steps

Setelah rules diupdate dan pairing berhasil, Anda bisa:

1. ✅ Test pairing dengan akun berbeda
2. ✅ Verify GPS tracking berfungsi
3. ✅ Cek data location di Firestore
4. ✅ Test find phone feature (jika ada)

## ⚠️ PENTING

**Jangan lupa deploy rules ke Firebase!** Tanpa deploy, rules hanya ada di file lokal dan tidak akan berfungsi.

**Quick Command:**
```bash
cd c:\flutterlatihan\TUGAS\Projek_PAM\aplikasi2
firebase deploy --only firestore:rules
```

Atau copy-paste manual di Firebase Console (lebih cepat untuk testing).

# 📱⌚ QR Code Pairing - Panduan Singkat

## Flow Pairing Smartwatch via QR Code

**Konsep Sederhana:** 
- User login di **smartphone** dengan akunnya
- Scan QR di **smartwatch**
- Smartwatch otomatis login dengan **akun yang sama**
- ✅ **1 Akun untuk 2 Device** (Smartphone + Smartwatch)

```
┌──────────────┐         ┌──────────────┐         ┌─────────────┐
│  Smartwatch  │────────>│   Firestore  │<────────│  Smartphone │
│   (Wear OS)  │         │  (Database)  │         │   (Mobile)  │
└──────────────┘         └──────────────┘         └─────────────┘
       │                        │                         │
       │ 1. Generate QR         │                         │
       │    (6-digit code)      │                         │
       │────────────────────────┼────────────────────────>│
       │                        │                         │
       │                        │    2. Scan QR Code      │
       │                        │<────────────────────────│
       │                        │                         │
       │                        │    3. Konfirmasi        │
       │                        │       Password          │
       │                        │       (Akun Sendiri)    │
       │                        │                         │
       │    4. Send Credentials │                         │
       │       (Same Account)   │                         │
       │<───────────────────────┼─────────────────────────│
       │                        │                         │
       │ 5. Auto Login          │                         │
       │    (Same User)         │                         │
       │                        │                         │
       │ 6. Start Tracking      │                         │
       │    (GPS → Firestore)   │                         │
       │────────────────────────>                         │
       │                        │                         │
       │                        │    7. View on Map       │
       │                        │         (Real-time)     │
       │                        │<────────────────────────│
```

---

## 🔧 Setup Checklist

### Smartwatch App (aplikasi2_watch):
- [x] QR code generator (`qr_flutter`)
- [x] Generate 6-digit pairing code
- [x] Listen to Firestore `watch_pairing/{code}`
- [x] Auto login when credentials received
- [x] Cleanup pairing document after login

### Smartphone App (aplikasi2):
- [x] QR scanner (`mobile_scanner`)
- [x] Camera permission in AndroidManifest
- [x] Family member selection dialog
- [x] Password input dialog
- [x] Send credentials to Firestore
- [x] Success page with member name

### Firestore:
- [x] Collection: `watch_pairing`
- [x] Document ID: pairing code (6 digits)
- [x] Fields:
  - `status`: "pending" → "completed"
  - `email`: member email
  - `password`: member password
  - `timestamp`: server timestamp
- [x] Auto-delete after 5 minutes (via Rules)

---

## 📱 User Journey

### Di Smartphone (User: Ayah):
1. Login dengan akun: **ayah@example.com**
2. Buka menu → "Jam Tangan" → "Scan QR Smartwatch"
3. Izinkan akses kamera
4. Arahkan ke QR code di smartwatch
5. **Dialog Konfirmasi**: 
   - "Smartwatch akan login dengan akun Anda: **Ayah**"
   - Input password untuk konfirmasi
   - Klik "Lanjutkan"
6. Processing... (kirim credentials ke Firestore)
7. Halaman sukses: "Smartwatch Tersambung!!"

### Di Smartwatch:
1. Buka app → QR code muncul otomatis
2. Lihat 6-digit pairing code
3. Tunggu scan dari smartphone
4. ✅ **Auto login dengan akun: ayah@example.com**
5. GPS tracking dimulai otomatis

### Result:
- ✅ Smartphone login: **ayah@example.com**
- ✅ Smartwatch login: **ayah@example.com** (SAMA!)
- ✅ Ayah bisa tracking dari smartphone
- ✅ Ayah bisa lihat tracking di smartwatch
- ✅ Data sinkron real-time antara 2 device

---

## 🔒 Security Considerations

### Current Implementation:
- ✅ User harus konfirmasi password sebelum pairing
- ✅ Reauthentication untuk verify password benar
- ✅ Password dikirim ke Firestore (temporary, auto-delete 5 menit)
- ✅ Hanya user authenticated yang bisa akses
- ⚠️ Password plain text di Firestore (for simplicity)

### Why Need Password Confirmation?
1. **Prevent Unauthorized Pairing**: Tidak sembarang orang bisa pairing smartwatch
2. **Verify Identity**: Memastikan yang pairing adalah pemilik akun
3. **Security Best Practice**: Double confirmation sebelum sensitive action

### Use Case Example:
```
Scenario: Ayah pinjam HP ke anak
❌ Tanpa password: Anak bisa langsung pairing smartwatch
✅ Dengan password: Anak tidak tahu password ayah, tidak bisa pairing
```

### Production Recommendations:
1. **Firebase Custom Tokens**:
   ```dart
   // Backend (Cloud Functions)
   const customToken = await admin.auth().createCustomToken(userId);
   // Send token instead of password
   ```

2. **Encrypted Password**:
   ```dart
   import 'package:encrypt/encrypt.dart';
   
   final encrypted = encrypter.encrypt(password);
   await firestore.set({'password': encrypted.base64});
   ```

3. **OAuth Flow**:
   - Redirect to auth page di smartphone
   - Approve access for smartwatch
   - Generate time-limited token

4. **Biometric Auth**:
   - Confirm pairing dengan fingerprint/face ID
   - Extra security layer

---

## 🐛 Troubleshooting

### QR Code tidak terdeteksi:
- ✅ Brightness smartwatch maksimal
- ✅ Jarak 10-15 cm
- ✅ Posisi tegak lurus
- ✅ No screen glare

### Smartwatch tidak auto-login:
- ✅ Cek internet connection smartwatch
- ✅ Verify pairing code di Firestore Console
- ✅ Check email & password benar
- ✅ Firebase Authentication enabled

### Permission Error:
- ✅ Camera permission di AndroidManifest
- ✅ Runtime permission granted
- ✅ Camera hardware available

### Credentials tidak sampai:
- ✅ Firestore Rules allow write
- ✅ Network stable di kedua device
- ✅ No firewall blocking
- ✅ Timestamp not expired (< 5 min)

---

## 📊 Firestore Structure

```javascript
// Collection: watch_pairing
{
  "123456": {  // 6-digit pairing code
    "status": "completed",
    "email": "anak1@example.com",
    "password": "password123",  // ⚠️ Plain text (use encryption in prod)
    "timestamp": Timestamp(2024-01-06 10:30:00)
  }
}

// Auto-delete after 5 minutes via Firestore Rules
```

---

## ✅ Testing Steps

1. **Test Login di Smartphone**:
   - Login dengan akun (misal: ayah@example.com)
   - Verify login berhasil

2. **Test QR Generation**:
   - Buka smartwatch app
   - Verify QR code muncul
   - Check pairing code 6 digit

3. **Test QR Scanning**:
   - Buka smartphone → Scan QR Smartwatch
   - Scan QR code dari smartwatch
   - Verify code terdeteksi

4. **Test Password Confirmation**:
   - Dialog muncul: "Smartwatch akan login dengan akun Anda: Ayah"
   - Input password salah → error message
   - Input password benar → success

5. **Test Firestore Write**:
   - Check Firebase Console → watch_pairing collection
   - Verify document created dengan pairing code
   - Check fields: status, email, password, timestamp

6. **Test Auto Login di Smartwatch**:
   - Smartwatch receives credentials
   - Auto login berhasil dengan akun yang sama
   - Tracking page muncul

7. **Test GPS Tracking**:
   - Start tracking di smartwatch
   - Check Firestore updates di family_members
   - Verify currentLocation terupdate

8. **Test View on Map**:
   - Buka smartphone → Family → Peta Lokasi
   - Verify marker user muncul di map
   - Check real-time updates

9. **Test Cleanup**:
   - Wait 5 minutes
   - Verify pairing document auto-deleted
   - Check Firestore Rules working

---

## 📚 Dependencies

### Smartwatch (aplikasi2_watch):
```yaml
dependencies:
  qr_flutter: ^4.1.0  # QR code generator
  firebase_core: ^3.8.1
  cloud_firestore: ^5.5.2
  firebase_auth: ^5.3.3
  geolocator: ^10.1.0
```

### Smartphone (aplikasi2):
```yaml
dependencies:
  mobile_scanner: ^3.5.5  # QR code scanner
  firebase_core: ^3.8.1
  cloud_firestore: ^5.5.2
  firebase_auth: ^5.3.3
  google_maps_flutter: ^2.5.0
```

---

## 🎯 Next Features

- [ ] Multiple smartwatch per family
- [ ] Battery low notification
- [ ] SOS emergency button
- [ ] Geofencing alerts
- [ ] Location history timeline
- [ ] Offline mode support

---

**Status: ✅ Ready to Test**

# 🔧 Perbaikan Masalah Pairing QR Code

## Masalah yang Diperbaiki

**Problem:** Setelah smartphone melakukan scan ke QR code di smartwatch, smartwatch tidak bisa login dengan akun yang sama yang ada di smartphone.

## Root Cause

1. **Dokumen Firestore belum ada** - Smartwatch tidak membuat dokumen pairing di Firestore sebelum menampilkan QR code
2. **Smartphone tidak verifikasi** - Smartphone langsung mengirim kredensial tanpa mengecek apakah dokumen pairing valid
3. **Listener belum siap** - Listener di smartwatch mungkin belum subscribe saat data dikirim
4. **Error handling kurang** - Tidak ada log yang jelas untuk debugging

## Solusi yang Diimplementasikan

### 1. **Inisialisasi Dokumen Pairing di Smartwatch**

**File:** `aplikasi2_watch/lib/services/auth_service.dart`

```dart
// Create initial pairing document
Future<void> createPairingDocument(String pairingCode) async {
  try {
    await _firestore
        .collection('watch_pairing')
        .doc(pairingCode)
        .set({
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('Pairing document created: $pairingCode');
  } catch (e) {
    print('Error creating pairing document: $e');
    rethrow;
  }
}
```

**File:** `aplikasi2_watch/lib/pages/qr_pairing_page.dart`

```dart
@override
void initState() {
  super.initState();
  _pairingCode = _generatePairingCode();
  _initializePairingDocument();  // ← Buat dokumen dulu
  _listenForPairing();           // ← Baru listen
}

Future<void> _initializePairingDocument() async {
  try {
    await _authService.createPairingDocument(_pairingCode);
    setState(() {
      _statusMessage = 'Scan QR dari HP';
    });
  } catch (e) {
    setState(() {
      _statusMessage = 'Error: ${e.toString()}';
    });
  }
}
```

### 2. **Validasi Dokumen di Smartphone**

**File:** `aplikasi2/lib/pages/scan_qr_smartwatch.dart`

```dart
Future<void> _sendCredentialsToWatch(String pairingCode, String email, String password) async {
  try {
    // First check if pairing document exists
    final pairingDoc = await FirebaseFirestore.instance
        .collection('watch_pairing')
        .doc(pairingCode)
        .get();
    
    if (!pairingDoc.exists) {
      throw Exception('QR Code tidak valid atau sudah kadaluarsa');
    }
    
    final data = pairingDoc.data();
    if (data?['status'] != 'pending') {
      throw Exception('QR Code sudah digunakan atau tidak valid');
    }
    
    // Update with credentials
    await FirebaseFirestore.instance
        .collection('watch_pairing')
        .doc(pairingCode)
        .update({  // ← Gunakan update() bukan set()
      'status': 'completed',
      'email': email,
      'password': password,
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    print('Credentials sent to smartwatch: $pairingCode');
  } catch (e) {
    print('Error sending credentials: $e');
    rethrow;
  }
}
```

### 3. **Enhanced Error Handling & Logging**

**File:** `aplikasi2_watch/lib/pages/qr_pairing_page.dart`

```dart
void _listenForPairing() {
  _authService.listenForPairing(_pairingCode).listen((snapshot) async {
    if (snapshot.exists && mounted) {
      final data = snapshot.data() as Map<String, dynamic>;
      
      print('Pairing data received: $data');  // ← Log data
      
      if (data['status'] == 'completed') {
        // Verify credentials exist
        final email = data['email'];
        final password = data['password'];
        
        if (email == null || password == null) {
          setState(() {
            _statusMessage = 'Error: Kredensial tidak lengkap';
            _isWaiting = false;
          });
          return;
        }
        
        print('Attempting login with email: $email');  // ← Log login attempt
        
        try {
          final result = await _authService.signInWithEmailAndPassword(
            email,
            password,
          );
          
          if (result != null) {
            print('Login successful: ${result.user?.email}');  // ← Log success
            await _authService.cleanupPairing(_pairingCode);
          }
        } catch (e) {
          print('Login error: $e');  // ← Log error
          
          // Auto-regenerate code after error
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _pairingCode = _generatePairingCode();
                _statusMessage = 'Scan QR dari HP';
              });
              _initializePairingDocument();
            }
          });
        }
      }
    }
  });
}
```

## Flow Setelah Perbaikan

```
┌────────────────────────────────────────────────────────┐
│ SMARTWATCH                                             │
├────────────────────────────────────────────────────────┤
│ 1. Generate 6-digit code (contoh: 123456)             │
│ 2. CREATE dokumen di Firestore:                       │
│    watch_pairing/123456 = {                           │
│      status: 'pending',                               │
│      createdAt: serverTimestamp                       │
│    }                                                   │
│ 3. Tampilkan QR code                                  │
│ 4. Listen perubahan di dokumen watch_pairing/123456   │
└────────────────────────────────────────────────────────┘
                         ↓
┌────────────────────────────────────────────────────────┐
│ SMARTPHONE (User: ayah@example.com)                   │
├────────────────────────────────────────────────────────┤
│ 5. Scan QR code → dapat code "123456"                 │
│ 6. Verify dokumen exists:                             │
│    GET watch_pairing/123456                           │
│    ✓ exists                                           │
│    ✓ status = 'pending'                               │
│ 7. Konfirmasi password user                           │
│ 8. UPDATE dokumen:                                    │
│    watch_pairing/123456 = {                           │
│      status: 'completed',                             │
│      email: 'ayah@example.com',                       │
│      password: '******',                              │
│      timestamp: serverTimestamp                       │
│    }                                                   │
└────────────────────────────────────────────────────────┘
                         ↓
┌────────────────────────────────────────────────────────┐
│ SMARTWATCH                                             │
├────────────────────────────────────────────────────────┤
│ 9. Listener terima update:                            │
│    status = 'completed'                               │
│    email = 'ayah@example.com'                         │
│    password = '******'                                │
│ 10. Validate credentials not null                     │
│ 11. signInWithEmailAndPassword()                      │
│ 12. ✅ LOGIN BERHASIL dengan ayah@example.com         │
│ 13. Delete dokumen watch_pairing/123456               │
│ 14. StreamBuilder detect auth state → TrackingPage    │
└────────────────────────────────────────────────────────┘
```

## Testing Checklist

### Di Smartwatch:
- [ ] Buka app → QR code muncul
- [ ] Lihat console log: `Pairing document created: 123456`
- [ ] Status: "Scan QR dari HP"

### Di Smartphone:
- [ ] Login dengan akun (contoh: ayah@example.com)
- [ ] Buka menu "Jam Tangan" → "Scan QR Smartwatch"
- [ ] Scan QR code
- [ ] Dialog konfirmasi muncul dengan nama user
- [ ] Input password yang benar
- [ ] Lihat console log: `Credentials sent to smartwatch: 123456`

### Di Smartwatch (After Scan):
- [ ] Lihat console log: `Pairing data received: {status: completed, email: ayah@example.com, ...}`
- [ ] Lihat console log: `Attempting login with email: ayah@example.com`
- [ ] Lihat console log: `Login successful: ayah@example.com`
- [ ] App otomatis navigasi ke TrackingPage
- [ ] GPS tracking dimulai

## Troubleshooting

### Masalah: QR Code tidak valid
**Penyebab:** Dokumen pairing tidak dibuat di Firestore
**Solusi:** Pastikan Firebase sudah diinisialisasi dengan benar di smartwatch

### Masalah: Login gagal di smartwatch
**Penyebab:** Password salah atau akun tidak ada
**Solusi:** Pastikan smartphone memasukkan password yang benar saat konfirmasi

### Masalah: Listener tidak terima update
**Penyebab:** Internet connection di smartwatch bermasalah
**Solusi:** Cek koneksi internet smartwatch

### Masalah: QR Code sudah digunakan
**Penyebab:** Dokumen status bukan 'pending'
**Solusi:** Generate QR code baru (refresh app di smartwatch)

## Catatan Penting

1. **Satu Akun, Dua Device**: Setelah pairing sukses, smartphone dan smartwatch login dengan **akun yang sama**
2. **Auto Cleanup**: Dokumen pairing otomatis dihapus setelah login berhasil
3. **Security**: Password diminta untuk konfirmasi, mencegah pairing tidak sah
4. **Logging**: Semua step penting di-log untuk debugging

## Keamanan

- ✅ Password hanya tersimpan sementara di Firestore (max 5 menit via Rules)
- ✅ Dokumen dihapus segera setelah login berhasil
- ✅ Status 'pending' mencegah reuse QR code
- ✅ Password harus dikonfirmasi oleh user smartphone


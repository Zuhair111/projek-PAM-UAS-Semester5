# 🕐 Setup Smartwatch Tracking - Panduan Lengkap

## Arsitektur
```
Smartwatch (Wear OS) → GPS Location → Firestore → Mobile App → Display on Map
```

## Langkah 1: Buat Flutter Wear OS Project Baru

### 1.1 Buat Project Baru
```bash
cd c:\flutterlatihan\TUGAS
flutter create --platforms android aplikasi2_watch
cd aplikasi2_watch
```

### 1.2 Tambah Dependencies
Edit `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.8.1
  cloud_firestore: ^5.5.2
  firebase_auth: ^5.3.3
  geolocator: ^10.1.0
  permission_handler: ^11.0.1
  workmanager: ^0.5.1  # Untuk background task
  shared_preferences: ^2.2.2
  wearable: ^0.2.0  # Wear OS specific
  qr_flutter: ^4.1.0  # QR Code generator
```

### 1.3 Setup Firebase
1. Buat project Firebase baru atau gunakan yang sudah ada
2. Tambahkan Android app dengan package name: `com.example.aplikasi2_watch`
3. Download `google-services.json` ke `android/app/`
4. Edit `android/build.gradle` (project level):
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

5. Edit `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

defaultConfig {
    minSdk 23  // Wear OS minimum
    targetSdk 33
}
```

---

## Langkah 2: Implementasi Wear OS App

### 2.1 Main App - QR Code Pairing Setup
Buat `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/qr_pairing_page.dart';
import 'pages/tracking_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Tracker Watch',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFFE07B4F),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFE07B4F),
        ),
      ),
      home: StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const TrackingPage();
          }
          return const QrPairingPage();
        },
      ),
    );
  }
}
```

### 2.2 Auth Service
Buat `lib/services/auth_service.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Listen for pairing credentials from smartphone
  Stream<DocumentSnapshot> listenForPairing(String pairingCode) {
    return _firestore
        .collection('watch_pairing')
        .doc(pairingCode)
        .snapshots();
  }

  // Clean up pairing document after successful login
  Future<void> cleanupPairing(String pairingCode) async {
    try {
      await _firestore
          .collection('watch_pairing')
          .doc(pairingCode)
          .delete();
    } catch (e) {
      print('Error cleaning up pairing: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
```

### 2.3 Location Tracking Service
Buat `lib/services/location_service.dart`:

```dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<Position>? _positionStream;
  bool _isTracking = false;

  bool get isTracking => _isTracking;

  Future<bool> checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission == LocationPermission.whileInUse ||
           permission == LocationPermission.always;
  }

  Future<void> startTracking() async {
    if (_isTracking) return;
    
    final hasPermission = await checkPermissions();
    if (!hasPermission) {
      throw Exception('Location permission denied');
    }

    _isTracking = true;

    // Get initial position
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _updateLocationInFirestore(position);
    } catch (e) {
      print('Error getting initial position: $e');
    }

    // Start listening to position updates
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
        timeLimit: Duration(seconds: 30), // Or every 30 seconds
      ),
    ).listen(
      (Position position) async {
        await _updateLocationInFirestore(position);
      },
      onError: (error) {
        print('Location stream error: $error');
      },
    );
  }

  Future<void> _updateLocationInFirestore(Position position) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Get user's family_member document
      final memberQuery = await _firestore
          .collection('family_members')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (memberQuery.docs.isEmpty) {
        print('User is not a family member');
        return;
      }

      final memberDoc = memberQuery.docs.first;
      
      // Update location
      await memberDoc.reference.update({
        'currentLocation': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'lastSeen': FieldValue.serverTimestamp(),
        'isOnline': true,
        'hasSmartwatch': true,
      });

      // Add to location history
      await memberDoc.reference.collection('location_history').add({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Location updated: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  Future<void> stopTracking() async {
    if (!_isTracking) return;
    
    await _positionStream?.cancel();
    _positionStream = null;
    _isTracking = false;

    // Mark as offline
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        final memberQuery = await _firestore
            .collection('family_members')
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();

        if (memberQuery.docs.isNotEmpty) {
          await memberQuery.docs.first.reference.update({
            'isOnline': false,
            'lastSeen': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        print('Error marking offline: $e');
      }
    }
  }

  void dispose() {
    stopTracking();
  }
}
```

### 2.4 QR Pairing Page (Wear OS)
Buat `lib/pages/qr_pairing_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';
import '../services/auth_service.dart';

class QrPairingPage extends StatefulWidget {
  const QrPairingPage({Key? key}) : super(key: key);

  @override
  State<QrPairingPage> createState() => _QrPairingPageState();
}

class _QrPairingPageState extends State<QrPairingPage> {
  final _authService = AuthService();
  late String _pairingCode;
  bool _isWaiting = false;
  String _statusMessage = 'Scan QR dari HP';

  @override
  void initState() {
    super.initState();
    _pairingCode = _generatePairingCode();
    _listenForPairing();
  }

  String _generatePairingCode() {
    // Generate 6 digit random code
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  void _listenForPairing() {
    _authService.listenForPairing(_pairingCode).listen((snapshot) async {
      if (snapshot.exists && mounted) {
        final data = snapshot.data() as Map<String, dynamic>;
        
        if (data['status'] == 'pending') {
          setState(() {
            _isWaiting = true;
            _statusMessage = 'Menunggu scan...';
          });
        } else if (data['status'] == 'completed' && data['email'] != null && data['password'] != null) {
          setState(() {
            _statusMessage = 'Login...';
          });
          
          try {
            // Auto login with credentials from smartphone
            await _authService.signInWithEmailAndPassword(
              data['email'],
              data['password'],
            );
            
            // Clean up pairing document
            await _authService.cleanupPairing(_pairingCode);
            
            // Navigation handled by StreamBuilder in main.dart
          } catch (e) {
            setState(() {
              _statusMessage = 'Login gagal: ${e.toString()}';
              _isWaiting = false;
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.watch,
                size: 36,
                color: Color(0xFFE07B4F),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sambungkan Smartwatch',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // QR Code
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: _pairingCode,
                  version: QrVersions.auto,
                  size: 150,
                  backgroundColor: Colors.white,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Pairing code text
              Text(
                'Kode: $_pairingCode',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Status message
              if (_isWaiting)
                const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFE07B4F),
                  ),
                ),
              
              const SizedBox(height: 8),
              
              Text(
                _statusMessage,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                '1. Buka app di HP\n2. Login dengan akun Anda\n3. Scan QR code ini\n4. Konfirmasi password',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
```

### 2.5 Login Page Manual (Backup - Optional)
Buat `lib/pages/login_page.dart`:

```dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.watch,
                size: 48,
                color: Color(0xFFE07B4F),
              ),
              const SizedBox(height: 16),
              const Text(
                'Family Tracker',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, size: 18),
                ),
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, size: 18),
                ),
                obscureText: true,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE07B4F),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Email dan password harus diisi');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      _showError('Login gagal: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

### 2.6 Tracking Page (Wear OS)
Buat `lib/pages/tracking_page.dart`:

```dart
import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/auth_service.dart';
import 'package:geolocator/geolocator.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({Key? key}) : super(key: key);

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final _locationService = LocationService();
  final _authService = AuthService();
  Position? _lastPosition;
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  Future<void> _startTracking() async {
    try {
      await _locationService.startTracking();
      setState(() => _isTracking = true);
      
      // Listen to position updates for UI
      Geolocator.getPositionStream().listen((position) {
        setState(() => _lastPosition = position);
      });
    } catch (e) {
      _showError('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isTracking ? Icons.location_on : Icons.location_off,
                size: 48,
                color: _isTracking ? Colors.green : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                _isTracking ? 'Tracking Aktif' : 'Tracking Mati',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_lastPosition != null) ...[
                Text(
                  'Lat: ${_lastPosition!.latitude.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Lng: ${_lastPosition!.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Akurasi: ${_lastPosition!.accuracy.toStringAsFixed(1)}m',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_isTracking) {
                    await _locationService.stopTracking();
                    setState(() => _isTracking = false);
                  } else {
                    await _startTracking();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTracking ? Colors.red : Colors.green,
                ),
                child: Text(_isTracking ? 'Stop' : 'Start'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  await _locationService.stopTracking();
                  await _authService.signOut();
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }
}
```

---

## Langkah 3: Setup AndroidManifest.xml untuk Wear OS

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    
    <!-- Wear OS -->
    <uses-feature android:name="android.hardware.type.watch" />
    
    <application
        android:label="Family Tracker"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Wear OS metadata -->
        <meta-data
            android:name="com.google.android.wearable.standalone"
            android:value="true" />
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
```

---

## Langkah 4: Build & Deploy ke Smartwatch

### 4.1 Build APK
```bash
cd aplikasi2_watch
flutter build apk --release
```

### 4.2 Install ke Smartwatch via ADB
```bash
# Connect smartwatch via USB atau WiFi debugging
adb devices

# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 4.3 Atau Install via Google Play Store
1. Buat signed bundle:
```bash
flutter build appbundle --release
```

2. Upload ke Play Store Console
3. Publish ke Wear OS section

---

## Langkah 5: Testing

### 5.1 Di Smartwatch:
1. Buka aplikasi Family Tracker di smartwatch
2. QR code dan pairing code akan muncul otomatis
3. Tunggu scan dari HP

### 5.2 Di Aplikasi HP (Smartphone):
1. Login ke aplikasi smartphone dengan akun Anda (misal: ayah@example.com)
2. Navigasi ke fitur "Scan QR Smartwatch"
3. Arahkan kamera ke QR code di smartwatch
4. Konfirmasi password akun Anda
5. Smartwatch akan otomatis login dengan akun yang sama (ayah@example.com)

### 5.3 Setelah Pairing:
1. Smartwatch akan otomatis login
2. Tracking page akan muncul
3. Klik "Start Tracking" atau akan auto-start
4. Buka tab "Keluarga" → "Peta Lokasi" di HP
5. Marker anggota keluarga akan muncul di map
6. Marker update real-time setiap 30 detik

---

## Langkah 6: Integrasi dengan Aplikasi Smartphone yang Sudah Ada

### 6.1 Update AndroidManifest.xml di Smartphone:

Tambahkan permission kamera di `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Existing permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    
    <!-- Camera permission for QR scanning -->
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
    
    <application>
        <!-- ... existing config ... -->
    </application>
</manifest>
```

### 6.2 File scan_qr_smartwatch.dart (Sudah Terupdate):

File `lib/pages/scan_qr_smartwatch.dart` sekarang sudah terintegrasi penuh dengan:
- ✅ Real QR code scanner menggunakan `mobile_scanner`
- ✅ Permission handler untuk kamera
- ✅ Dialog konfirmasi password (current user only)
- ✅ Reauthentication untuk keamanan
- ✅ Kirim credentials akun saat ini ke Firestore collection `watch_pairing`
- ✅ Auto-navigation ke halaman sukses
- ✅ Simplified flow: scan → confirm password → done

### 6.3 Flow Lengkap di Smartphone:
1. User buka aplikasi → navigasi ke "Scan QR Smartwatch"
2. Izinkan akses kamera
3. Arahkan kamera ke QR code di smartwatch
4. QR code terdeteksi → parsing pairing code (6 digit)
5. Tampilkan dialog: konfirmasi password untuk akun yang sedang login
6. User masukkan password untuk verifikasi
7. System reauthenticate untuk keamanan
8. Kirim credentials akun saat ini ke Firestore:
   ```
   watch_pairing/{pairingCode}:
     - status: "completed"
     - email: "current_user@example.com" (email akun yang sedang login)
     - password: "password_yang_dikonfirmasi"
     - timestamp: server timestamp
   ```
9. Smartwatch terima data → auto login dengan akun yang sama
10. Navigate ke halaman "Smartwatch Tersambung"

**Catatan Penting:** 
- Smartwatch akan login dengan akun yang SAMA dengan smartphone
- Tidak ada pilihan anggota keluarga - pairing 1 user untuk 2 devices
- Untuk tracking anak dengan akun berbeda, gunakan fitur "Tambah Keluarga" yang sudah ada

### 6.4 Security Note:

⚠️ **Important:** Dalam implementasi ini, password dikirim plain text ke Firestore untuk kemudahan development. 

**Untuk production**, pertimbangkan opsi lebih aman:
1. **Firebase Custom Tokens**: Generate custom token di backend
2. **OAuth Flow**: Gunakan OAuth redirect flow
3. **Encrypted Storage**: Encrypt password sebelum kirim
4. **Time-Limited Tokens**: Set TTL 5 menit untuk pairing document

Contoh Firestore Rules dengan auto-delete:
```javascript
match /watch_pairing/{pairingCode} {
  allow create: if request.auth != null;
  allow read, update: if request.auth != null;
  allow delete: if request.auth != null;
  
  // Auto-delete after 5 minutes
  allow read: if request.time < resource.data.timestamp + duration.value(5, 'm');
}
```

---

## Langkah 7: Firestore Rules untuk Pairing

Tambahkan rules di Firebase Console:

```javascript
match /watch_pairing/{pairingCode} {
  // Allow create (dari smartwatch)
  allow create: if request.auth != null;
  
  // Allow read & update (dari smartphone untuk kirim credentials)
  allow read, update: if request.auth != null;
  
  // Allow delete (cleanup setelah login)
  allow delete: if request.auth != null;
  
  // Auto delete after 5 minutes
  allow read: if request.time < resource.data.timestamp + duration.value(5, 'm');
}

---

## Troubleshooting

### QR Code tidak terbaca:
- Pastikan layar smartwatch brightness maksimal
- Posisikan HP tegak lurus dengan smartwatch
- Jarak ideal: 10-15 cm
- Pastikan tidak ada pantulan cahaya di layar

### Smartwatch tidak auto-login setelah scan:
- Cek koneksi internet smartwatch
- Pastikan pairing code sama di Firestore
- Cek Firebase Console → Firestore → collection `watch_pairing`
- Credentials harus terkirim dengan benar (email, password)

### GPS tidak akurat:
- Pastikan smartwatch di luar ruangan
- Tunggu 1-2 menit untuk GPS lock
- Cek Settings → Location → Mode → High accuracy

### Data tidak muncul di app:
- Cek koneksi internet smartwatch
- Pastikan login berhasil (cek auth state)
- Cek Firestore rules di Firebase Console
- Cek battery optimization disabled untuk app

### Battery drain cepat:
- Ganti `distanceFilter` jadi 50 meter
- Ganti update interval jadi 60 detik
- Gunakan `LocationAccuracy.medium` instead of `high`

---

## Next Steps

1. ✅ Implement battery monitoring di smartwatch
2. ✅ Add notification jika tracking stop
3. ✅ Add geofencing untuk zona aman
4. ✅ Optimize battery usage dengan adaptive tracking
5. ✅ Add emergency SOS button

---

**Selamat! Smartwatch tracking sudah siap!** 🎉

# 📱⌚ Panduan: Menambahkan Fitur Melacak Smartphone dari Smartwatch

## 🎯 Overview Fitur

Fitur ini memungkinkan user menemukan smartphone mereka yang hilang dengan menggunakan smartwatch. Ketika smartwatch mengirim perintah, smartphone akan memberikan respons (bunyi alarm, getaran, atau menampilkan lokasi).

---

## 🏗️ Arsitektur Sistem

### Komponen yang Dibutuhkan:

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│ Smartwatch  │────────▶│   Firebase   │◀────────│ Smartphone  │
│   App       │  Write  │   Firestore  │  Listen │    App      │
│  (Kiddo)    │         │   Real-time  │         │  (Kiddo)    │
└─────────────┘         └──────────────┘         └─────────────┘
      │                                                   │
      └───────── BLE/WiFi (Optional) ───────────────────┘
```

### Flow:
1. User tap tombol "Cari Smartphone" di smartwatch
2. Smartwatch write ke Firestore: `findMyPhone: true`
3. Smartphone listen ke Firestore changes
4. Smartphone detect command → Play alarm/vibrate
5. User finds phone → Smartphone write: `found: true`

---

## 📋 Langkah-langkah Implementasi

### **FASE 1: Setup Backend (Firebase)**

#### 1.1 Struktur Data Firestore

Tambahkan collection `devices` dengan struktur:

```javascript
devices/{userId}/
  ├─ smartphone/
  │   ├─ deviceId: "phone_unique_id"
  │   ├─ lastSeen: Timestamp
  │   ├─ location: GeoPoint
  │   ├─ battery: 75
  │   ├─ isOnline: true
  │   └─ findMyPhone: false  // Command dari smartwatch
  │
  └─ smartwatch/
      ├─ deviceId: "watch_unique_id"
      ├─ lastSeen: Timestamp
      ├─ location: GeoPoint
      ├─ battery: 60
      └─ isOnline: true
```

#### 1.2 Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Devices collection
    match /devices/{userId}/{device=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

### **FASE 2: Update Aplikasi Smartphone (Flutter)**

#### 2.1 Tambah Dependencies

**pubspec.yaml**:
```yaml
dependencies:
  # Yang sudah ada...
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.2
  
  # Tambahan baru
  audioplayers: ^5.2.1        # Untuk play alarm sound
  vibration: ^1.8.4           # Untuk getaran
  device_info_plus: ^9.1.1    # Device ID
  flutter_local_notifications: ^16.3.0  # Notifikasi
```

#### 2.2 Buat Service untuk Device Tracking

**lib/services/device_tracking_service.dart**:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  StreamSubscription<DocumentSnapshot>? _deviceListener;

  // Initialize tracking
  Future<void> initialize() async {
    await _initNotifications();
    await _registerDevice();
    await _startListening();
  }

  // Register device di Firestore
  Future<void> _registerDevice() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final deviceId = await _getDeviceId();
    final position = await _getCurrentLocation();

    await _firestore
        .collection('devices')
        .doc(user.uid)
        .collection('smartphone')
        .doc(deviceId)
        .set({
      'deviceId': deviceId,
      'lastSeen': FieldValue.serverTimestamp(),
      'location': GeoPoint(position.latitude, position.longitude),
      'battery': await _getBatteryLevel(),
      'isOnline': true,
      'findMyPhone': false,
      'model': await _getDeviceModel(),
    }, SetOptions(merge: true));
  }

  // Listen untuk command dari smartwatch
  Future<void> _startListening() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final deviceId = await _getDeviceId();

    _deviceListener = _firestore
        .collection('devices')
        .doc(user.uid)
        .collection('smartphone')
        .doc(deviceId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data?['findMyPhone'] == true) {
          _handleFindMyPhoneCommand();
        }
      }
    });
  }

  // Handle command "Find My Phone"
  Future<void> _handleFindMyPhoneCommand() async {
    print('🔔 Find My Phone command received!');
    
    // 1. Play loud alarm
    await _playAlarm();
    
    // 2. Vibrate
    await _vibrate();
    
    // 3. Show notification
    await _showNotification();
    
    // 4. Update location
    await _updateLocation();
    
    // 5. Turn on screen (optional)
    // Note: Memerlukan plugin tambahan atau native code
  }

  // Play alarm sound
  Future<void> _playAlarm() async {
    try {
      // Gunakan asset atau URL sound
      await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
      await _audioPlayer.setVolume(1.0);
      
      // Stop setelah 30 detik
      Future.delayed(const Duration(seconds: 30), () {
        _audioPlayer.stop();
      });
    } catch (e) {
      print('Error playing alarm: $e');
    }
  }

  // Vibrate phone
  Future<void> _vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      // Vibrate pattern: [wait, vibrate, wait, vibrate, ...]
      Vibration.vibrate(
        pattern: [0, 1000, 500, 1000, 500, 1000],
        repeat: 5,
      );
    }
  }

  // Show notification
  Future<void> _showNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'find_my_phone',
      'Find My Phone',
      channelDescription: 'Notifications for finding phone',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      '📱 Smartphone Ditemukan!',
      'Smartwatch sedang mencari smartphone ini',
      details,
    );
  }

  // Update location
  Future<void> _updateLocation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final deviceId = await _getDeviceId();
    final position = await _getCurrentLocation();

    await _firestore
        .collection('devices')
        .doc(user.uid)
        .collection('smartphone')
        .doc(deviceId)
        .update({
      'location': GeoPoint(position.latitude, position.longitude),
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  // Mark as found
  Future<void> markAsFound() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final deviceId = await _getDeviceId();

    await _firestore
        .collection('devices')
        .doc(user.uid)
        .collection('smartphone')
        .doc(deviceId)
        .update({
      'findMyPhone': false,
      'found': true,
      'foundAt': FieldValue.serverTimestamp(),
    });

    // Stop alarm
    await _audioPlayer.stop();
    Vibration.cancel();
  }

  // Helper methods
  Future<void> _initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _notifications.initialize(settings);
  }

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return info.id;
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return info.identifierForVendor ?? 'unknown';
    }
    return 'unknown';
  }

  Future<String> _getDeviceModel() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return '${info.manufacturer} ${info.model}';
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return info.model;
    }
    return 'Unknown';
  }

  Future<Position> _getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<int> _getBatteryLevel() async {
    // Implement battery level detection
    // Memerlukan plugin seperti battery_plus
    return 100;
  }

  // Cleanup
  void dispose() {
    _deviceListener?.cancel();
    _audioPlayer.dispose();
  }
}
```

#### 2.3 Initialize Service di Main

**lib/main.dart**:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/splash_screen.dart';
import 'services/device_tracking_service.dart';

// Global instance
final deviceTrackingService = DeviceTrackingService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize device tracking
  await deviceTrackingService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KIDDO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFFFF8F0),
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}
```

#### 2.4 Tambah UI untuk "Ketemu" Button

Ketika alarm berbunyi, user bisa tap untuk stop:

**lib/widgets/find_my_phone_overlay.dart**:

```dart
import 'package:flutter/material.dart';
import '../services/device_tracking_service.dart';

class FindMyPhoneOverlay extends StatelessWidget {
  const FindMyPhoneOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.withOpacity(0.9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.phone_android,
              size: 120,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              '📱 Smartphone Ditemukan!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                await deviceTrackingService.markAsFound();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Saya Sudah Ketemu',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### **FASE 3: Aplikasi Smartwatch**

#### 3.1 Platform Pilihan

**Option A: Wear OS (Android)**
- Bahasa: Kotlin/Java atau Flutter (via flutter_wear_plugin)
- SDK: Wear OS SDK

**Option B: watchOS (Apple Watch)**
- Bahasa: Swift/SwiftUI
- Framework: WatchKit

**Option C: Cross-platform**
- Flutter (limited support)
- React Native (via react-native-watch-connectivity)

#### 3.2 Fitur Smartwatch App

**UI Simple**:
```
┌─────────────────┐
│   KIDDO Watch   │
├─────────────────┤
│                 │
│   📱            │
│ Cari Smartphone │
│                 │
│   [TAP]         │
│                 │
└─────────────────┘
```

**Functionality**:
1. Button "Cari Smartphone"
2. Trigger command ke Firestore
3. Tampilkan status (searching, found)
4. Optional: Show phone location on map

#### 3.3 Code Example (Conceptual)

```dart
// Smartwatch App - Find Phone Button
class FindPhoneButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Trigger command
          await FirebaseFirestore.instance
              .collection('devices')
              .doc(user.uid)
              .collection('smartphone')
              .doc('phone_id')  // Get actual device ID
              .update({
            'findMyPhone': true,
            'triggeredAt': FieldValue.serverTimestamp(),
            'triggeredBy': 'smartwatch',
          });
          
          // Show feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mencari smartphone...')),
          );
        }
      },
      child: Column(
        children: [
          Icon(Icons.phone_android, size: 48),
          SizedBox(height: 8),
          Text('Cari Smartphone'),
        ],
      ),
    );
  }
}
```

---

### **FASE 4: Integration dengan Aplikasi Existing**

#### 4.1 Tambah Menu di Jam Tangan Page

**lib/pages/jam_tangan_page.dart**:

```dart
// Tambahkan button "Cari Smartphone"
Card(
  child: ListTile(
    leading: Icon(Icons.phone_android, color: Color(0xFFE07B4F)),
    title: Text('Cari Smartphone Saya'),
    subtitle: Text('Temukan smartphone dengan smartwatch'),
    trailing: Icon(Icons.arrow_forward_ios),
    onTap: () {
      // Trigger find my phone dari smartphone
      // (untuk testing, nanti actual trigger dari smartwatch)
      _triggerFindMyPhone();
    },
  ),
)
```

#### 4.2 Testing Mode

```dart
Future<void> _triggerFindMyPhone() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final deviceId = await DeviceInfoPlugin().androidInfo
        .then((info) => info.id);
    
    await FirebaseFirestore.instance
        .collection('devices')
        .doc(user.uid)
        .collection('smartphone')
        .doc(deviceId)
        .update({
      'findMyPhone': true,
      'triggeredAt': FieldValue.serverTimestamp(),
    });
  }
}
```

---

### **FASE 5: Permissions & Setup**

#### 5.1 Android Permissions

**android/app/src/main/AndroidManifest.xml**:

```xml
<manifest>
  <uses-permission android:name="android.permission.VIBRATE" />
  <uses-permission android:name="android.permission.WAKE_LOCK" />
  <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
</manifest>
```

#### 5.2 iOS Permissions

**ios/Runner/Info.plist**:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Aplikasi memerlukan akses lokasi untuk fitur Find My Phone</string>
<key>UIBackgroundModes</key>
<array>
  <string>location</string>
  <string>remote-notification</string>
</array>
```

#### 5.3 Add Alarm Sound Asset

**assets/sounds/alarm.mp3** - Download alarm sound

**pubspec.yaml**:
```yaml
flutter:
  assets:
    - assets/
    - assets/sounds/
```

---

## 🧪 Testing Flow

### Test 1: Simulasi dari Smartphone

1. Login ke aplikasi
2. Buka Jam Tangan Page
3. Tap "Cari Smartphone Saya"
4. ✅ Verify: Alarm berbunyi
5. ✅ Verify: Phone bergetar
6. ✅ Verify: Notifikasi muncul
7. Tap "Saya Sudah Ketemu"
8. ✅ Verify: Alarm stop

### Test 2: Dari Firestore Console

1. Buka Firestore Console
2. Navigate: `devices/{userId}/smartphone/{deviceId}`
3. Edit field `findMyPhone: true`
4. ✅ Verify: Smartphone respond dengan alarm

### Test 3: End-to-end (dengan smartwatch)

1. Pairing smartwatch dengan smartphone
2. Login dengan akun yang sama
3. Di smartwatch: Tap "Cari Smartphone"
4. ✅ Verify: Command dikirim ke Firestore
5. ✅ Verify: Smartphone menerima dan respond
6. ✅ Verify: Smartwatch tampil status "Found"

---

## 📊 Monitoring & Analytics

### Dashboard di Firebase Console

Monitor activity:
```javascript
// devices/{userId}/smartphone/activity_log
{
  timestamp: "2026-01-06T10:30:00",
  action: "find_my_phone_triggered",
  triggeredBy: "smartwatch",
  result: "found",
  duration: 45  // seconds to find
}
```

### Analytics Events

```dart
// Track usage
FirebaseAnalytics.instance.logEvent(
  name: 'find_my_phone',
  parameters: {
    'triggered_by': 'smartwatch',
    'found': true,
    'duration': 45,
  },
);
```

---

## 🔒 Security Considerations

### 1. **Authentication**
- ✅ Hanya device user sendiri yang bisa trigger
- ✅ Require login di smartwatch dan smartphone
- ✅ Token expiration

### 2. **Rate Limiting**
```dart
// Prevent spam
if (lastTriggered != null && 
    DateTime.now().difference(lastTriggered) < Duration(minutes: 1)) {
  throw Exception('Please wait before triggering again');
}
```

### 3. **Privacy**
- ✅ Lokasi hanya visible untuk user sendiri
- ✅ Data encrypted in transit (Firebase default)
- ✅ No third-party access

---

## 🚀 Future Enhancements

### Phase 2 Features:

1. **Remote Camera Activation**
   - Ambil foto dari kamera smartphone
   - Upload ke Firebase Storage
   - Tampilkan di smartwatch

2. **Remote Lock**
   - Lock smartphone dari smartwatch
   - Require PIN untuk unlock

3. **Location History**
   - Track pergerakan smartphone
   - Show trail di map

4. **Battery Alert**
   - Notifikasi jika battery low
   - Auto save location before shutdown

5. **Offline Mode**
   - Simpan last known location
   - Show di smartwatch meskipun phone offline

---

## 📋 Checklist Implementation

### Smartphone App:
- [ ] Install dependencies (audioplayers, vibration, dll)
- [ ] Buat DeviceTrackingService
- [ ] Initialize service di main.dart
- [ ] Setup permissions (Android & iOS)
- [ ] Add alarm sound asset
- [ ] Test listening dari Firestore
- [ ] Implement alarm/vibration
- [ ] Create "Found" overlay UI

### Smartwatch App:
- [ ] Setup project (Wear OS / watchOS)
- [ ] Implement Firebase connection
- [ ] Create "Find Phone" button
- [ ] Send command ke Firestore
- [ ] Show status feedback
- [ ] Handle success/error

### Backend:
- [ ] Setup Firestore structure
- [ ] Configure security rules
- [ ] Setup Cloud Functions (optional)
- [ ] Enable Firebase Analytics

### Testing:
- [ ] Test dari Firestore Console
- [ ] Test alarm & vibration
- [ ] Test notification
- [ ] Test end-to-end dengan smartwatch
- [ ] Test permission handling

---

## 💡 Tips

1. **Start Simple**: Test dulu dengan trigger manual dari smartphone
2. **Use Emulator**: Test smartwatch app di emulator dulu
3. **Mock Data**: Gunakan mock data untuk development
4. **Logging**: Tambah extensive logging untuk debugging
5. **User Feedback**: Show clear status di UI

---

## 📚 Resources

- **Firebase Docs**: https://firebase.google.com/docs/firestore
- **Wear OS**: https://developer.android.com/training/wearables
- **watchOS**: https://developer.apple.com/watchos/
- **Flutter Packages**: https://pub.dev

---

**Dengan panduan ini, Anda bisa mengimplementasikan fitur Find My Phone dari smartwatch! 🎉**

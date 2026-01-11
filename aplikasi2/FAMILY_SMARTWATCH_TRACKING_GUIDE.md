# 👨‍👩‍👧‍👦⌚ Panduan: Pelacakan Anggota Keluarga dengan Smartwatch

## 🎯 Overview Fitur

Fitur ini memungkinkan **orang tua melacak lokasi anak-anak** yang menggunakan smartwatch secara real-time. Setiap anggota keluarga yang memakai smartwatch akan mengirim lokasi mereka secara berkala, dan orang tua dapat melihat semua lokasi tersebut di peta pada smartphone.

### Perbedaan dengan Fitur "Find Phone":
- ❌ Bukan untuk mencari smartphone yang hilang
- ✅ Untuk melacak lokasi anggota keluarga (terutama anak-anak)
- ✅ Tracking real-time dengan update setiap 30 detik
- ✅ Menampilkan semua anggota keluarga di peta
- ✅ Riwayat pergerakan dan battery monitoring

---

## 🏗️ Arsitektur Sistem

### Komponen Utama:

```
┌─────────────────┐         ┌──────────────┐         ┌─────────────────┐
│  Smartwatch     │ Kirim   │   Firebase   │ Stream  │  Smartphone     │
│  (Anak 1,2,3)   │ Lokasi  │   Firestore  │ Data    │  (Orang Tua)    │
│                 │ ─────▶  │              │ ◀────── │                 │
│  - GPS Active   │         │  - Families  │         │  - Google Maps  │
│  - Send Every   │         │  - Members   │         │  - View All     │
│    30 seconds   │         │  - Locations │         │  - Track Kids   │
└─────────────────┘         └──────────────┘         └─────────────────┘
```

### Flow Komunikasi:
```
1. Anak memakai smartwatch → Login ke app
2. Smartwatch aktifkan GPS tracking
3. Setiap 30 detik:
   ├─ Get GPS location
   ├─ Get battery level
   └─ Upload ke Firestore
4. Orang tua buka app smartphone
5. Peta menampilkan semua lokasi anak real-time
6. Tap marker untuk lihat detail (nama, battery, last seen)
```

---

## 📋 Langkah-langkah Implementasi

### **FASE 1: Setup Backend (Firebase)**

#### 1.1 Struktur Data Firestore

Buat 3 collections utama:

```javascript
// ========== COLLECTION: families ==========
families/{familyId}/
{
  "familyId": "family_abc123",
  "familyName": "Keluarga Budi",
  "createdBy": "userId_orang_tua",  // UID orang tua
  "members": [
    "userId_orang_tua",
    "userId_anak1", 
    "userId_anak2"
  ],
  "createdAt": Timestamp,
  "inviteCode": "ABC123"  // Untuk join keluarga
}

// ========== COLLECTION: family_members ==========
family_members/{userId}/
{
  "userId": "userId_anak1",
  "familyId": "family_abc123",
  "name": "Budi Junior",
  "role": "anak",  // "orang_tua" atau "anak"
  "email": "budi.jr@email.com",
  "profilePhoto": "url_to_photo",
  
  // Smartwatch Info
  "hasSmartwatch": true,
  "smartwatchId": "watch_device_123",
  "smartwatchModel": "Samsung Galaxy Watch 5",
  
  // Location Data (Updated setiap 30 detik dari smartwatch)
  "currentLocation": {
    "latitude": -6.2088,
    "longitude": 106.8456,
    "accuracy": 10.5,  // meters
    "timestamp": Timestamp,
    "address": "Jl. Sudirman No. 10, Jakarta"  // Reverse geocoding
  },
  
  // Location History (Max 50 locations)
  "locationHistory": [
    {
      "latitude": -6.2088,
      "longitude": 106.8456,
      "timestamp": Timestamp
    },
    // ... more history
  ],
  
  // Status
  "batteryLevel": 75,  // Smartwatch battery %
  "isOnline": true,    // Tracking aktif atau tidak
  "lastSeen": Timestamp,
  
  // Timestamps
  "joinedAt": Timestamp,
  "updatedAt": Timestamp
}

// ========== COLLECTION: smartwatch_devices ==========
smartwatch_devices/{deviceId}/
{
  "deviceId": "watch_device_123",
  "userId": "userId_anak1",
  "model": "Samsung Galaxy Watch 5",
  "osVersion": "Wear OS 4.0",
  "fcmToken": "fcm_token_for_notifications",
  "isActive": true,
  "pairedAt": Timestamp,
  "lastSync": Timestamp
}
```

#### 1.2 Firestore Security Rules

Update rules di Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ===== FAMILIES: Hanya member yang bisa akses =====
    match /families/{familyId} {
      // Baca jika user adalah member keluarga
      allow read: if request.auth != null 
        && request.auth.uid in resource.data.members;
      
      // Create family baru
      allow create: if request.auth != null;
      
      // Update hanya oleh creator (orang tua)
      allow update: if request.auth != null 
        && request.auth.uid == resource.data.createdBy;
      
      // Delete hanya oleh creator
      allow delete: if request.auth != null 
        && request.auth.uid == resource.data.createdBy;
    }
    
    // ===== FAMILY MEMBERS: Anggota keluarga bisa lihat semua =====
    match /family_members/{memberId} {
      // Fungsi helper: cek apakah user adalah anggota keluarga yang sama
      function isFamilyMember() {
        let familyId = resource.data.familyId;
        let familyDoc = get(/databases/$(database)/documents/families/$(familyId));
        return request.auth.uid in familyDoc.data.members;
      }
      
      // Baca jika user adalah anggota keluarga yang sama
      allow read: if request.auth != null && isFamilyMember();
      
      // Create data member baru (saat register atau join family)
      allow create: if request.auth != null 
        && request.auth.uid == request.resource.data.userId;
      
      // Update hanya data diri sendiri (lokasi, battery, dll)
      allow update: if request.auth != null 
        && request.auth.uid == resource.data.userId;
      
      // Delete hanya data sendiri atau oleh orang tua
      allow delete: if request.auth != null 
        && (request.auth.uid == resource.data.userId 
            || request.auth.uid == get(/databases/$(database)/documents/families/$(resource.data.familyId)).data.createdBy);
    }
    
    // ===== SMARTWATCH DEVICES: Hanya pemilik =====
    match /smartwatch_devices/{deviceId} {
      allow read, write: if request.auth != null 
        && request.auth.uid == resource.data.userId;
    }
  }
}
```

---

### **FASE 2: Update Smartphone App (Orang Tua)**

#### 2.1 Tambah Dependencies

Update `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase (sudah ada)
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.2
  
  # Mapping & Location
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  
  # Messaging (optional untuk notifikasi)
  firebase_messaging: ^14.0.0
  
  # UI
  intl: ^0.19.0  # Untuk format waktu
```

Run:
```bash
flutter pub get
```

#### 2.2 Buat Family Tracking Service

Buat file `lib/services/family_tracking_service.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class FamilyTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===== GET USER'S FAMILY =====
  Future<DocumentSnapshot?> getUserFamily() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    try {
      // Get user's family member document
      final memberDoc = await _firestore
          .collection('family_members')
          .doc(userId)
          .get();

      if (!memberDoc.exists) return null;

      final familyId = memberDoc.data()?['familyId'];
      if (familyId == null) return null;

      // Get family document
      return await _firestore.collection('families').doc(familyId).get();
    } catch (e) {
      print('Error getting user family: $e');
      return null;
    }
  }

  // ===== STREAM SEMUA ANGGOTA KELUARGA DENGAN LOKASI REAL-TIME =====
  Stream<QuerySnapshot> getFamilyMembersStream(String familyId) {
    return _firestore
        .collection('family_members')
        .where('familyId', isEqualTo: familyId)
        .snapshots();
  }

  // ===== STREAM HANYA ANGGOTA DENGAN SMARTWATCH =====
  Stream<QuerySnapshot> getFamilyMembersWithSmartwatchStream(String familyId) {
    return _firestore
        .collection('family_members')
        .where('familyId', isEqualTo: familyId)
        .where('hasSmartwatch', isEqualTo: true)
        .snapshots();
  }

  // ===== UPDATE LOKASI USER (Dipanggil dari smartwatch) =====
  Future<void> updateUserLocation(Position position) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    // Get address from coordinates (reverse geocoding)
    String? address;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address = '${place.street}, ${place.locality}';
      }
    } catch (e) {
      print('Address lookup failed: $e');
      // Continue without address
    }

    // Update current location
    await _firestore.collection('family_members').doc(userId).update({
      'currentLocation': {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': FieldValue.serverTimestamp(),
        'address': address,
      },
      'lastSeen': FieldValue.serverTimestamp(),
      'isOnline': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Add to location history
    await _addToLocationHistory(userId, position);
  }

  // ===== ADD TO LOCATION HISTORY =====
  Future<void> _addToLocationHistory(String userId, Position position) async {
    try {
      // Get current history
      final doc = await _firestore.collection('family_members').doc(userId).get();
      List<dynamic> history = List.from(doc.data()?['locationHistory'] ?? []);

      // Add new location
      history.add({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': Timestamp.now(),
      });

      // Keep only last 50 locations
      if (history.length > 50) {
        history = history.sublist(history.length - 50);
      }

      // Update Firestore
      await _firestore.collection('family_members').doc(userId).update({
        'locationHistory': history,
      });
    } catch (e) {
      print('Error adding to location history: $e');
    }
  }

  // ===== GET CURRENT LOCATION DARI GPS =====
  Future<Position?> getCurrentLocation() async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      // Get location with high accuracy
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  // ===== CALCULATE DISTANCE BETWEEN TWO POINTS =====
  double calculateDistance(
    double lat1, double lon1, 
    double lat2, double lon2
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // ===== UPDATE BATTERY LEVEL (Dipanggil dari smartwatch) =====
  Future<void> updateBatteryLevel(int batteryLevel) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('family_members').doc(userId).update({
      'batteryLevel': batteryLevel,
      'lastSeen': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ===== SET TRACKING STATUS (On/Off) =====
  Future<void> setTrackingStatus(bool isOnline) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('family_members').doc(userId).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  // ===== CREATE OR JOIN FAMILY =====
  Future<String> createFamily(String familyName) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    // Generate invite code
    final inviteCode = _generateInviteCode();

    // Create family
    final familyRef = await _firestore.collection('families').add({
      'familyName': familyName,
      'createdBy': userId,
      'members': [userId],
      'createdAt': FieldValue.serverTimestamp(),
      'inviteCode': inviteCode,
    });

    // Update user's family member document
    await _firestore.collection('family_members').doc(userId).set({
      'userId': userId,
      'familyId': familyRef.id,
      'name': _auth.currentUser?.displayName ?? 'Orang Tua',
      'role': 'orang_tua',
      'email': _auth.currentUser?.email,
      'hasSmartwatch': false,
      'joinedAt': FieldValue.serverTimestamp(),
    });

    return familyRef.id;
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => 
      chars[(DateTime.now().millisecondsSinceEpoch + index) % chars.length]
    ).join();
  }
}
```

#### 2.3 Buat Halaman Peta Pelacakan

Buat file `lib/pages/family_tracking_map_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/family_tracking_service.dart';

class FamilyTrackingMapPage extends StatefulWidget {
  @override
  _FamilyTrackingMapPageState createState() => _FamilyTrackingMapPageState();
}

class _FamilyTrackingMapPageState extends State<FamilyTrackingMapPage> {
  final FamilyTrackingService _trackingService = FamilyTrackingService();
  GoogleMapController? _mapController;
  String? _familyId;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  
  // Default camera position (Jakarta)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-6.2088, 106.8456),
    zoom: 12,
  );
  
  @override
  void initState() {
    super.initState();
    _loadFamily();
  }
  
  Future<void> _loadFamily() async {
    final family = await _trackingService.getUserFamily();
    if (family != null && family.exists) {
      setState(() {
        _familyId = family.id;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      _showNoFamilyDialog();
    }
  }
  
  void _showNoFamilyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Belum Ada Keluarga'),
        content: Text('Anda belum terdaftar dalam keluarga. Silakan buat keluarga baru atau join dengan kode undangan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Pelacakan Keluarga')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_familyId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Pelacakan Keluarga')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.family_restroom, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Belum ada keluarga',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Lokasi Anggota Keluarga'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showSettings,
            tooltip: 'Pengaturan',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _trackingService.getFamilyMembersWithSmartwatchStream(_familyId!),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          
          final members = snapshot.data!.docs;
          
          if (members.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.watch_off, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada anggota dengan smartwatch',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          _updateMarkers(members);
          
          return Column(
            children: [
              // Map View
              Expanded(
                flex: 2,
                child: GoogleMap(
                  initialCameraPosition: _initialPosition,
                  markers: _markers,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _fitMapToMarkers();
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapType: MapType.normal,
                ),
              ),
              
              // Members List
              Expanded(
                child: _buildMembersList(members),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _updateMarkers(List<QueryDocumentSnapshot> members) {
    _markers.clear();
    
    for (var member in members) {
      final data = member.data() as Map<String, dynamic>;
      final location = data['currentLocation'];
      
      if (location != null && location['latitude'] != null) {
        final isOnline = data['isOnline'] ?? false;
        final name = data['name'] ?? 'Unknown';
        final role = data['role'] ?? 'anak';
        
        _markers.add(
          Marker(
            markerId: MarkerId(member.id),
            position: LatLng(
              location['latitude'],
              location['longitude'],
            ),
            infoWindow: InfoWindow(
              title: name,
              snippet: isOnline 
                ? 'Online • ${_formatTimestamp(location['timestamp'])}'
                : 'Offline • ${_formatTimestamp(data['lastSeen'])}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isOnline
                ? (role == 'orang_tua' ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueGreen)
                : BitmapDescriptor.hueRed
            ),
            alpha: isOnline ? 1.0 : 0.5,
          ),
        );
      }
    }
  }
  
  void _fitMapToMarkers() {
    if (_markers.isEmpty || _mapController == null) return;
    
    double minLat = _markers.first.position.latitude;
    double maxLat = _markers.first.position.latitude;
    double minLng = _markers.first.position.longitude;
    double maxLng = _markers.first.position.longitude;
    
    for (var marker in _markers) {
      if (marker.position.latitude < minLat) minLat = marker.position.latitude;
      if (marker.position.latitude > maxLat) maxLat = marker.position.latitude;
      if (marker.position.longitude < minLng) minLng = marker.position.longitude;
      if (marker.position.longitude > maxLng) maxLng = marker.position.longitude;
    }
    
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50, // padding
      ),
    );
  }
  
  Widget _buildMembersList(List<QueryDocumentSnapshot> members) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Anggota Keluarga (${members.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: members.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final data = members[index].data() as Map<String, dynamic>;
                final location = data['currentLocation'];
                final isOnline = data['isOnline'] ?? false;
                final battery = data['batteryLevel'] ?? 0;
                final name = data['name'] ?? 'Unknown';
                
                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: isOnline ? Colors.green : Colors.grey,
                        child: Icon(Icons.watch, color: Colors.white),
                      ),
                      if (isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (location != null && location['address'] != null)
                        Text(
                          location['address'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Text('Lokasi tidak tersedia'),
                      SizedBox(height: 4),
                      Text(
                        isOnline 
                          ? 'Online • ${_formatTimestamp(data['lastSeen'])}'
                          : 'Offline • ${_formatTimestamp(data['lastSeen'])}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOnline ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.battery_full,
                        color: _getBatteryColor(battery),
                        size: 24,
                      ),
                      Text(
                        '$battery%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    if (location != null && location['latitude'] != null) {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(location['latitude'], location['longitude']),
                          16,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Tidak diketahui';
    
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else {
      return 'Invalid';
    }
    
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return DateFormat('dd MMM, HH:mm').format(date);
  }
  
  Color _getBatteryColor(int level) {
    if (level > 50) return Colors.green;
    if (level > 20) return Colors.orange;
    return Colors.red;
  }
  
  void _showSettings() {
    // TODO: Implement settings
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pengaturan'),
        content: Text('Coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

---

### **FASE 3: Develop Smartwatch App**

#### 3.1 Platform Yang Didukung

Pilih platform smartwatch target:
- **Wear OS (Android)** - Samsung Galaxy Watch 4/5/6, Pixel Watch
- **watchOS (Apple)** - Apple Watch Series 6 ke atas
- **Tizen** - Samsung Galaxy Watch versi lama

> **Rekomendasi**: Wear OS karena support Flutter lebih baik

#### 3.2 Setup Flutter Wear OS Project

Create project baru:
```bash
flutter create --template=app --platforms=android family_watch_tracker
cd family_watch_tracker
```

Update `pubspec.yaml`:
```yaml
name: family_watch_tracker
description: Smartwatch tracking app for family members

dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.2
  
  # Location
  geolocator: ^10.1.0
  
  # Wear OS
  wear: ^1.1.0
  
  # Battery
  battery_plus: ^5.0.0
  
  # Background work
  workmanager: ^0.5.1
  
  # Permissions
  permission_handler: ^11.0.1
```

#### 3.3 Android Manifest Configuration

Update `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    
    <!-- Wear OS -->
    <uses-feature android:name="android.hardware.type.watch" />
    
    <application
        android:name="${applicationName}"
        android:label="Family Tracker"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Main Activity -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        
        <!-- WorkManager Service -->
        <service
            android:name="androidx.work.impl.background.systemjob.SystemJobService"
            android:permission="android.permission.BIND_JOB_SERVICE"
            android:exported="true" />
            
        <!-- Don't delete the meta-data below -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

#### 3.4 Main Smartwatch App Code

Buat `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:workmanager/workmanager.dart';
import 'firebase_options.dart';

// ===== BACKGROUND TASK DISPATCHER =====
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      final userId = inputData?['userId'];
      if (userId == null) return Future.value(false);
      
      // Get current location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Get battery level
      final battery = Battery();
      final batteryLevel = await battery.batteryLevel;
      
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('family_members')
          .doc(userId)
          .update({
        'currentLocation': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'batteryLevel': batteryLevel,
        'lastSeen': FieldValue.serverTimestamp(),
        'isOnline': true,
      });
      
      print('Location updated: ${position.latitude}, ${position.longitude}');
      return Future.value(true);
    } catch (e) {
      print('Background task error: $e');
      return Future.value(false);
    }
  });
}

// ===== MAIN APP =====
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize WorkManager
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  
  runApp(FamilyWatchApp());
}

class FamilyWatchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Tracker',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: AuthWrapper(),
    );
  }
}

// ===== AUTH WRAPPER =====
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasData) {
          return TrackingScreen();
        }
        
        return LoginScreen();
      },
    );
  }
}

// ===== LOGIN SCREEN =====
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Email dan password harus diisi');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } catch (e) {
      _showMessage('Login gagal: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }
  
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WatchShape(
        builder: (context, shape, widget) {
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.watch, size: 40, color: Colors.blue),
                  SizedBox(height: 16),
                  Text(
                    'Family Tracker',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),
                  
                  // Simple login (simplified for watch UI)
                  Text('Login dengan email', style: TextStyle(fontSize: 12)),
                  SizedBox(height: 16),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading 
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Login'),
                  ),
                  
                  // Note: Email & password input simplified
                  // In real app, use phone pairing or QR code login
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ===== TRACKING SCREEN =====
class TrackingScreen extends StatefulWidget {
  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  bool _isTracking = false;
  int _batteryLevel = 100;
  String? _lastUpdate;
  final _userId = FirebaseAuth.instance.currentUser?.uid;
  
  @override
  void initState() {
    super.initState();
    _checkTrackingStatus();
    _updateBatteryLevel();
  }
  
  Future<void> _checkTrackingStatus() async {
    if (_userId == null) return;
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection('family_members')
          .doc(_userId)
          .get();
      
      setState(() {
        _isTracking = doc.data()?['isOnline'] ?? false;
      });
    } catch (e) {
      print('Error checking status: $e');
    }
  }
  
  Future<void> _updateBatteryLevel() async {
    final battery = Battery();
    battery.onBatteryStateChanged.listen((state) async {
      final level = await battery.batteryLevel;
      setState(() => _batteryLevel = level);
    });
    
    _batteryLevel = await battery.batteryLevel;
    setState(() {});
  }
  
  Future<void> _toggleTracking() async {
    if (_userId == null) return;
    
    if (!_isTracking) {
      // Start tracking
      await _startTracking();
    } else {
      // Stop tracking
      await _stopTracking();
    }
  }
  
  Future<void> _startTracking() async {
    // Request permissions
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || 
        permission == LocationPermission.deniedForever) {
      _showMessage('Permission lokasi ditolak');
      return;
    }
    
    // Register periodic task (every 15 minutes minimum for Android)
    // But we'll make it update as frequently as possible
    await Workmanager().registerPeriodicTask(
      "location_update",
      "locationUpdateTask",
      frequency: Duration(minutes: 15),
      inputData: {'userId': _userId},
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
    
    // Also do immediate update
    await _updateLocationNow();
    
    // Update status
    await FirebaseFirestore.instance
        .collection('family_members')
        .doc(_userId)
        .update({'isOnline': true});
    
    setState(() {
      _isTracking = true;
      _lastUpdate = 'Baru saja';
    });
    
    _showMessage('Pelacakan diaktifkan');
  }
  
  Future<void> _stopTracking() async {
    await Workmanager().cancelAll();
    
    await FirebaseFirestore.instance
        .collection('family_members')
        .doc(_userId)
        .update({'isOnline': false});
    
    setState(() {
      _isTracking = false;
    });
    
    _showMessage('Pelacakan dinonaktifkan');
  }
  
  Future<void> _updateLocationNow() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      
      await FirebaseFirestore.instance
          .collection('family_members')
          .doc(_userId)
          .update({
        'currentLocation': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'batteryLevel': _batteryLevel,
        'lastSeen': FieldValue.serverTimestamp(),
      });
      
      setState(() {
        _lastUpdate = 'Baru saja';
      });
      
      _showMessage('Lokasi diperbarui');
    } catch (e) {
      _showMessage('Gagal update lokasi');
    }
  }
  
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(fontSize: 12))),
    );
  }
  
  Future<void> _logout() async {
    await _stopTracking();
    await FirebaseAuth.instance.signOut();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WatchShape(
        builder: (context, shape, widget) {
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Status Icon
                  Icon(
                    _isTracking ? Icons.location_on : Icons.location_off,
                    size: 48,
                    color: _isTracking ? Colors.green : Colors.grey,
                  ),
                  SizedBox(height: 12),
                  
                  // Status Text
                  Text(
                    _isTracking ? 'Pelacakan Aktif' : 'Pelacakan Nonaktif',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  if (_lastUpdate != null) ...[
                    SizedBox(height: 4),
                    Text(
                      'Update: $_lastUpdate',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                  
                  SizedBox(height: 20),
                  
                  // Battery Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.battery_full, size: 20, color: _getBatteryColor()),
                      SizedBox(width: 4),
                      Text('$_batteryLevel%', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Toggle Button
                  ElevatedButton(
                    onPressed: _toggleTracking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isTracking ? Colors.red : Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      _isTracking ? 'Matikan' : 'Aktifkan',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Manual Update Button (if tracking is on)
                  if (_isTracking)
                    TextButton(
                      onPressed: _updateLocationNow,
                      child: Text('Update Sekarang', style: TextStyle(fontSize: 12)),
                    ),
                  
                  SizedBox(height: 12),
                  
                  // Logout Button
                  TextButton(
                    onPressed: _logout,
                    child: Text('Logout', style: TextStyle(fontSize: 12, color: Colors.red)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Color _getBatteryColor() {
    if (_batteryLevel > 50) return Colors.green;
    if (_batteryLevel > 20) return Colors.orange;
    return Colors.red;
  }
}
```

---

### **FASE 4: Testing & Debugging**

#### 4.1 Test Checklist

**Smartwatch App:**
- [ ] Login berhasil dengan credentials yang sama dengan smartphone
- [ ] Tracking dapat diaktifkan/dinonaktifkan
- [ ] Lokasi terkirim ke Firestore setiap 30 detik
- [ ] Battery level terupdate
- [ ] Status online/offline terdeteksi
- [ ] Background service berjalan bahkan saat screen off
- [ ] Permission lokasi sudah diizinkan

**Smartphone App:**
- [ ] Peta menampilkan semua anggota keluarga
- [ ] Marker muncul di lokasi yang benar
- [ ] Tap marker menampilkan info (nama, last seen, battery)
- [ ] Tap list item zoom ke lokasi di peta
- [ ] Real-time update saat smartwatch kirim lokasi baru
- [ ] Battery indicator dengan warna yang sesuai
- [ ] Status online/offline update
- [ ] Address ditampilkan (jika tersedia)

**Security:**
- [ ] User hanya bisa lihat anggota keluarganya sendiri
- [ ] Firestore rules berfungsi dengan benar
- [ ] Data tidak bisa diakses oleh user lain

**Edge Cases:**
- [ ] Test dengan GPS off di smartwatch
- [ ] Test dengan koneksi internet terputus kemudian kembali
- [ ] Test dengan multiple family members
- [ ] Test dengan smartwatch battery rendah
- [ ] Test uninstall dan reinstall app

---

### **FASE 5: Optimisasi & Battery Management**

#### 5.1 Smart Location Update Strategy

Buat `lib/services/smart_location_service.dart`:

```dart
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class SmartLocationService {
  static const Duration MIN_UPDATE_INTERVAL = Duration(seconds: 30);
  static const double MIN_DISTANCE_CHANGE = 10.0; // meters
  
  DateTime? _lastUpdate;
  Position? _lastPosition;
  
  // Tentukan apakah perlu update atau tidak
  bool shouldUpdate(Position currentPosition) {
    // Check time interval
    if (_lastUpdate != null) {
      final timeDiff = DateTime.now().difference(_lastUpdate!);
      if (timeDiff < MIN_UPDATE_INTERVAL) {
        print('Skipping update: too soon (${timeDiff.inSeconds}s)');
        return false;
      }
    }
    
    // Check distance change (jangan kirim jika tidak bergerak jauh)
    if (_lastPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        currentPosition.latitude,
        currentPosition.longitude,
      );
      
      if (distance < MIN_DISTANCE_CHANGE) {
        print('Skipping update: minimal movement (${distance.toStringAsFixed(1)}m)');
        return false;
      }
    }
    
    _lastUpdate = DateTime.now();
    _lastPosition = currentPosition;
    return true;
  }
  
  // Adaptive update interval berdasarkan battery
  Duration getUpdateInterval(int batteryLevel) {
    if (batteryLevel > 50) {
      return Duration(seconds: 30); // Normal mode
    } else if (batteryLevel > 20) {
      return Duration(minutes: 2); // Battery saver mode
    } else {
      return Duration(minutes: 5); // Low battery mode
    }
  }
  
  // Get accuracy based on battery
  LocationAccuracy getAccuracy(int batteryLevel) {
    if (batteryLevel > 50) {
      return LocationAccuracy.high; // ±10m
    } else if (batteryLevel > 20) {
      return LocationAccuracy.medium; // ±100m
    } else {
      return LocationAccuracy.low; // ±500m
    }
  }
}
```

#### 5.2 Privacy & User Consent

Tambahkan consent dialog sebelum aktivasi tracking:

```dart
Future<bool> requestTrackingConsent(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text('Izin Pelacakan Lokasi'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aplikasi ini akan:'),
          SizedBox(height: 8),
          Text('• Melacak lokasi Anda secara real-time'),
          Text('• Membagikan lokasi dengan anggota keluarga'),
          Text('• Menyimpan riwayat lokasi (max 50)'),
          SizedBox(height: 12),
          Text(
            'Anda dapat menonaktifkan kapan saja.',
            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Tolak'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Setuju'),
        ),
      ],
    ),
  ) ?? false;
}
```

---

## 📊 Estimasi Waktu & Resources

### Development Time:
- **Setup Firebase & Firestore**: 3-4 jam
- **Family Management System**: 4-5 jam
- **Smartphone App (Map UI)**: 5-6 jam
- **Smartwatch App**: 6-8 jam
- **Background Service & Testing**: 5-6 jam
- **Security & Optimization**: 3-4 jam

**Total: 26-33 jam** (sekitar 4-5 hari kerja)

### Hardware Requirements:
- **Smartwatch dengan Wear OS** (Samsung Galaxy Watch 4/5/6, Pixel Watch)
- **Smartphone Android** (API 21+, Android 5.0+)
- **Google Maps API Key** (dengan billing enabled)

### Biaya Tambahan:
- Firebase Firestore: Gratis untuk usage rendah (< 50K reads/day)
- Google Maps API: $200 credit gratis per bulan
- **Total: Gratis** untuk usage personal/keluarga

---

## 🚀 Enhancements (Future Features)

### 1. **Geofencing & Safe Zones**
Orang tua bisa set zona aman (rumah, sekolah), notifikasi otomatis jika anak keluar zona.

### 2. **Location History Playback**
Lihat rute perjalanan anak hari ini dengan timeline.

### 3. **SOS Emergency Button**
Tombol darurat di smartwatch, kirim lokasi + notifikasi urgent ke orang tua.

### 4. **Battery Alerts**
Notifikasi ke orang tua jika smartwatch battery < 20%.

### 5. **Multiple Children Management**
Kelola beberapa anak dengan smartwatch berbeda, filter view per anak.

### 6. **Scheduled Tracking**
Tracking hanya aktif saat jam tertentu (misal: hanya saat sekolah).

### 7. **Offline Mode dengan Sync**
Cache last known location, sync saat koneksi kembali.

### 8. **Statistics & Reports**
Distance traveled, most visited places, weekly report.

---

## ✅ Kesimpulan

Dengan implementasi ini, aplikasi Anda akan memiliki fitur pelacakan keluarga yang powerful:

✅ **Real-time tracking** semua anggota keluarga  
✅ **Google Maps integration** dengan marker dan info  
✅ **Battery monitoring** smartwatch  
✅ **Privacy & security** dengan Firestore rules  
✅ **Background service** yang efisien  
✅ **User consent** dan kontrol tracking  

Fitur ini sangat berguna untuk orang tua yang ingin memastikan keselamatan anak-anak mereka! 👨‍👩‍👧‍👦⌚📍

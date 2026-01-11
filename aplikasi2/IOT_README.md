# 🎯 IoT Device Integration - Complete Guide

## 📌 Overview

Fitur **IoT Device Integration** memungkinkan aplikasi Flutter Anda untuk **langsung tracking lokasi perangkat IoT** (Arduino, ESP32, ESP8266) yang mengirimkan data GPS ke Firebase Realtime Database.

### ✨ Key Features:
- ✅ **Direct Connection** - Tanpa perlu scan QR code
- ✅ **Real-time Tracking** - Update otomatis setiap 5 detik
- ✅ **Live Map Visualization** - Google Maps dengan marker
- ✅ **Status Monitoring** - Online/Offline indicator
- ✅ **Speed Display** - Kecepatan dalam km/h
- ✅ **Auto Zoom** - Peta mengikuti perangkat
- ✅ **Config-based** - Mudah customize

---

## 🚀 Quick Start (3 Steps)

### 1. Setup ESP32/ESP8266
```cpp
// Upload code ini ke ESP32
#include <WiFi.h>
#include <FirebaseESP32.h>

// Config
#define WIFI_SSID "YourWiFi"
#define WIFI_PASSWORD "YourPassword"
#define FIREBASE_HOST "aplikasi2-9ab49-default-rtdb.asia-southeast1.firebasedatabase.app"

void setup() {
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Firebase.begin(FIREBASE_HOST, "your_secret");
}

void loop() {
  Firebase.setDouble(firebaseData, "/Posisi/latitude", -7.752281);
  Firebase.setDouble(firebaseData, "/Posisi/longitude", 110.356881);
  Firebase.setString(firebaseData, "/Posisi/status", "Online");
  delay(5000);
}
```

### 2. Verifikasi Firebase
Buka Firebase Console → Realtime Database → Lihat data di `/Posisi`

### 3. Pakai Aplikasi
```
1. Buka app → Login
2. Tab "Jam Tangan"
3. Klik card "Perangkat IoT"  
4. Done! 🎉
```

---

## 📁 File Structure

```
aplikasi2/
├── lib/
│   ├── pages/
│   │   ├── iot_direct_connect_page.dart  ← Halaman utama IoT
│   │   └── jam_tangan_page.dart          ← Added IoT access
│   ├── services/
│   │   └── iot_device_service.dart       ← Realtime DB service
│   └── utils/
│       └── iot_config.dart               ← Konfigurasi
│
├── IOT_DEVICE_SETUP.md                   ← Setup Arduino/ESP (LENGKAP)
├── IOT_USAGE_GUIDE.md                    ← Cara pakai aplikasi
├── IOT_QUICK_START.md                    ← Quick reference
├── IOT_IMPLEMENTATION_SUMMARY.md         ← Summary implementasi
├── IOT_VISUAL_GUIDE.md                   ← Visual mockups & flow
└── IOT_README.md                         ← File ini
```

---

## 📚 Documentation Links

| Document | Description | For Who |
|----------|-------------|---------|
| **[IOT_DEVICE_SETUP.md](IOT_DEVICE_SETUP.md)** | Setup lengkap Arduino/ESP32/ESP8266 | Developer |
| **[IOT_USAGE_GUIDE.md](IOT_USAGE_GUIDE.md)** | Panduan lengkap cara pakai app | User/Tester |
| **[IOT_QUICK_START.md](IOT_QUICK_START.md)** | Quick reference & code samples | Developer |
| **[IOT_IMPLEMENTATION_SUMMARY.md](IOT_IMPLEMENTATION_SUMMARY.md)** | Summary implementasi | Developer |
| **[IOT_VISUAL_GUIDE.md](IOT_VISUAL_GUIDE.md)** | Visual mockups & flow diagram | Everyone |

---

## ⚙️ Configuration

Edit [lib/utils/iot_config.dart](lib/utils/iot_config.dart):

```dart
// Database URL (sesuaikan dengan project Anda)
static const String databaseUrl = 
    'https://aplikasi2-9ab49-default-rtdb.asia-southeast1.firebasedatabase.app';

// Path data
static const String devicePath = 'Posisi';

// Map zoom level
static const double defaultZoomLevel = 16.0;

// Enable auto-zoom saat device bergerak
static const bool enableAutoZoom = true;
```

---

## 🔗 Data Structure

### Firebase Path:
```
/Posisi
```

### Data Format:
```json
{
  "Posisi": {
    "latitude": -7.752281333,
    "longitude": 110.356881333,
    "kecepatan": 0,
    "status": "Online"
  }
}
```

### Field Descriptions:
| Field | Type | Description |
|-------|------|-------------|
| `latitude` | double | GPS latitude coordinate |
| `longitude` | double | GPS longitude coordinate |
| `kecepatan` | double | Speed in km/h |
| `status` | string | "Online" or "Offline" |

---

## 🎨 UI Screenshots & Flow

### App Navigation:
```
Main App
  └─ Bottom Navigation
      └─ Tab "Jam Tangan"
          └─ Card "Perangkat IoT" [CLICK HERE]
              └─ IoT Device Page (with Map)
```

### Page Layout:
```
┌─────────────────────────┐
│ ← Lokasi Perangkat IoT 🔄│  ← Header + Refresh
│              🟢Terhubung │  ← Status Badge
├─────────────────────────┤
│                         │
│    🗺️ GOOGLE MAPS       │  ← Map View
│         📍             │  ← Marker
│                         │
│                         │
├─────────────────────────┤
│  ┌───────────────────┐  │
│  │ 🔧 Info Perangkat │  │  ← Info Panel
│  │ 📍 Lokasi         │  │
│  │ 🚀 Kecepatan      │  │
│  │ 🟢 Status         │  │
│  └───────────────────┘  │
└─────────────────────────┘
```

---

## 🧪 Testing Checklist

- [ ] ESP32 terhubung WiFi
- [ ] Data muncul di Firebase Console
- [ ] Aplikasi berhasil koneksi
- [ ] Map menampilkan marker di lokasi yang benar
- [ ] Info panel menampilkan data akurat
- [ ] Status badge sesuai (Hijau/Merah)
- [ ] Refresh button berfungsi
- [ ] Real-time update works (saat device bergerak)

---

## 🐛 Troubleshooting Quick Fix

| Problem | Quick Fix |
|---------|-----------|
| **"Gagal terhubung"** | Cek URL database di iot_config.dart |
| **Marker tidak muncul** | Cek data di Firebase Console |
| **Data tidak update** | Cek WiFi ESP32, lihat Serial Monitor |
| **Status offline** | ESP32 harus kirim "Online" (case-sensitive) |
| **GPS tidak akurat** | Pakai GPS outdoor, tunggu 2-3 menit untuk lock |

---

## 💡 Tips & Best Practices

### For Arduino/ESP Code:
1. **Update Interval**: 5-10 detik optimal (balance antara real-time & battery)
2. **GPS Validation**: Selalu cek `gps.location.isValid()` sebelum kirim
3. **Error Handling**: Add retry logic untuk WiFi/Firebase error
4. **Battery**: Gunakan deep sleep jika perangkat tidak bergerak

### For App Usage:
1. **Refresh Button**: Gunakan saat koneksi bermasalah
2. **Map Controls**: Pinch untuk zoom, drag untuk pan
3. **Marker Info**: Tap marker untuk detail
4. **Background**: App harus di foreground untuk real-time updates

---

## 🔐 Security Notes

### Current Setup:
```json
{
  "rules": {
    "Posisi": {
      ".read": true,
      ".write": true
    }
  }
}
```
⚠️ **This is public access** - OK for testing, NOT for production!

### Production Recommendation:
```json
{
  "rules": {
    "Posisi": {
      ".read": "auth != null",
      ".write": "auth != null",
      ".validate": "newData.hasChildren(['latitude', 'longitude', 'status'])"
    }
  }
}
```

---

## 📦 Dependencies

Already included in [pubspec.yaml](pubspec.yaml):
```yaml
dependencies:
  firebase_core: ^3.8.1          # Firebase SDK
  firebase_database: ^11.1.4      # Realtime Database
  google_maps_flutter: ^2.5.0     # Maps
```

✅ No additional packages needed!

---

## 🚀 Future Enhancements

Possible features to add:
1. **Multiple Devices** - Track beberapa device sekaligus
2. **History Tracking** - Simpan riwayat perjalanan
3. **Geofencing** - Alert saat keluar area
4. **Battery Monitor** - Display battery level device
5. **Custom Markers** - Icon berbeda per device type
6. **Offline Mode** - Cache last known location
7. **Push Notifications** - Alert real-time events
8. **Export Data** - Export GPS log to CSV/JSON

---

## 📞 Support

### For Issues:
1. Check [IOT_DEVICE_SETUP.md](IOT_DEVICE_SETUP.md#troubleshooting) for detailed troubleshooting
2. Verify data in Firebase Console
3. Check Serial Monitor on Arduino for debug logs
4. Check Flutter debug console for app logs

### For Questions:
- **Setup**: See [IOT_DEVICE_SETUP.md](IOT_DEVICE_SETUP.md)
- **Usage**: See [IOT_USAGE_GUIDE.md](IOT_USAGE_GUIDE.md)
- **Config**: See [lib/utils/iot_config.dart](lib/utils/iot_config.dart)

---

## ✅ What You Get

### Completed Features:
- ✅ Halaman IoT lengkap dengan Google Maps
- ✅ Real-time data streaming dari Firebase
- ✅ Service layer yang reusable
- ✅ Konfigurasi yang mudah diubah
- ✅ Dokumentasi lengkap
- ✅ No QR code needed - Direct connect!

### How It Works:
```
ESP32 → Firebase → Flutter App → Map Display
 (GPS)  (Realtime)   (Stream)    (Real-time)
```

---

## 🎯 Summary

### For Developers:
1. **Setup**: 10 minutes (ESP32 + Firebase)
2. **Config**: 1 file to edit ([iot_config.dart](lib/utils/iot_config.dart))
3. **Docs**: 6 comprehensive guides
4. **Ready**: No additional coding needed!

### For Users:
1. **Access**: 3 taps dari main screen
2. **View**: Real-time location on map
3. **Info**: Speed, status, coordinates
4. **Simple**: No QR scan required!

---

**🚀 Your IoT Device Integration is Ready to Use!**

Start by reading:
1. [IOT_QUICK_START.md](IOT_QUICK_START.md) - For quick implementation
2. [IOT_DEVICE_SETUP.md](IOT_DEVICE_SETUP.md) - For detailed Arduino setup
3. [IOT_USAGE_GUIDE.md](IOT_USAGE_GUIDE.md) - For app usage guide

---

**Made with ❤️ for Arduino, ESP32, and ESP8266 enthusiasts!**

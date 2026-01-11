# 🚀 Quick Start - IoT Device Integration

## Akses Fitur IoT Device

### Dari Aplikasi:
1. Buka aplikasi
2. Pilih tab **"Jam Tangan"** (bottom navigation)
3. Klik card **"Perangkat IoT"**
4. Lihat lokasi perangkat di peta

### URL Database yang Digunakan:
```
https://aplikasi2-9ab49-default-rtdb.asia-southeast1.firebasedatabase.app
```

### Path Data:
```
/Posisi
```

## Format Data di Firebase

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

## Contoh Code ESP32

```cpp
#include <WiFi.h>
#include <FirebaseESP32.h>

#define WIFI_SSID "Your_WiFi"
#define WIFI_PASSWORD "Your_Password"
#define FIREBASE_HOST "aplikasi2-9ab49-default-rtdb.asia-southeast1.firebasedatabase.app"
#define FIREBASE_AUTH "your_secret"

FirebaseData firebaseData;

void setup() {
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) delay(500);
  
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
}

void loop() {
  double lat = getGPSLatitude();  // Your GPS function
  double lng = getGPSLongitude(); // Your GPS function
  
  Firebase.setDouble(firebaseData, "/Posisi/latitude", lat);
  Firebase.setDouble(firebaseData, "/Posisi/longitude", lng);
  Firebase.setDouble(firebaseData, "/Posisi/kecepatan", 0);
  Firebase.setString(firebaseData, "/Posisi/status", "Online");
  
  delay(5000);
}
```

## File-file Penting

- **Halaman IoT**: `lib/pages/iot_direct_connect_page.dart`
- **Service**: `lib/services/iot_device_service.dart`
- **Dokumentasi Lengkap**: `IOT_DEVICE_SETUP.md`

## Fitur

✅ Real-time location tracking  
✅ Status monitoring (Online/Offline)  
✅ Speed display  
✅ Auto-update map  
✅ No QR code needed - Direct connection!  

---

📖 **Untuk dokumentasi lengkap, lihat [IOT_DEVICE_SETUP.md](IOT_DEVICE_SETUP.md)**

# 🔌 Panduan Integrasi Perangkat IoT (Arduino/ESP32/ESP8266)

## 📋 Daftar Isi
- [Tentang Fitur](#tentang-fitur)
- [Cara Kerja](#cara-kerja)
- [Setup Arduino/ESP32/ESP8266](#setup-arduinoesp32esp8266)
- [Struktur Data Realtime Database](#struktur-data-realtime-database)
- [Cara Menggunakan Aplikasi](#cara-menggunakan-aplikasi)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Tentang Fitur

Aplikasi ini dapat **langsung terhubung ke perangkat IoT** (Arduino, ESP32, ESP8266) yang mengirimkan data lokasi ke Firebase Realtime Database. Fitur ini memungkinkan Anda untuk:

- ✅ **Tracking lokasi real-time** dari perangkat IoT
- ✅ **Monitoring status** perangkat (Online/Offline)
- ✅ **Melihat kecepatan** perangkat bergerak
- ✅ **Visualisasi peta** dengan marker otomatis
- ✅ **Tidak perlu scan QR code** - langsung terhubung!

---

## ⚙️ Cara Kerja

```
Arduino/ESP32/ESP8266  →  Firebase Realtime Database  →  Aplikasi Flutter
   (Kirim GPS Data)            (Simpan di /Posisi)         (Tampilkan Map)
```

1. **Perangkat IoT** membaca data GPS dan mengirimkannya ke Firebase
2. **Firebase Realtime Database** menyimpan data di path `/Posisi`
3. **Aplikasi Flutter** mendengarkan perubahan data secara real-time
4. **Peta** otomatis update posisi marker sesuai data terbaru

---

## 🔧 Setup Arduino/ESP32/ESP8266

### 1. Install Library yang Diperlukan

**Untuk ESP32/ESP8266:**
```cpp
#include <WiFi.h>
#include <FirebaseESP32.h>  // atau FirebaseESP8266.h
#include <TinyGPS++.h>
```

### 2. Konfigurasi Firebase

```cpp
// WiFi credentials
#define WIFI_SSID "Nama_WiFi_Anda"
#define WIFI_PASSWORD "Password_WiFi"

// Firebase credentials
#define FIREBASE_HOST "aplikasi2-9ab49-default-rtdb.asia-southeast1.firebasedatabase.app"
#define FIREBASE_AUTH "your_firebase_database_secret"

// Initialize Firebase
FirebaseData firebaseData;
```

### 3. Contoh Code untuk Mengirim Data

```cpp
#include <WiFi.h>
#include <FirebaseESP32.h>
#include <TinyGPS++.h>
#include <HardwareSerial.h>

// WiFi Config
#define WIFI_SSID "Nama_WiFi"
#define WIFI_PASSWORD "Password_WiFi"

// Firebase Config
#define FIREBASE_HOST "aplikasi2-9ab49-default-rtdb.asia-southeast1.firebasedatabase.app"
#define FIREBASE_AUTH "your_database_secret"

// GPS Config
HardwareSerial GPS_Serial(1);
TinyGPSPlus gps;

FirebaseData firebaseData;

void setup() {
  Serial.begin(115200);
  GPS_Serial.begin(9600, SERIAL_8N1, 16, 17); // RX=16, TX=17
  
  // Connect to WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.println("\nWiFi Connected!");
  
  // Initialize Firebase
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);
}

void loop() {
  // Read GPS data
  while (GPS_Serial.available() > 0) {
    if (gps.encode(GPS_Serial.read())) {
      if (gps.location.isValid()) {
        double latitude = gps.location.lat();
        double longitude = gps.location.lng();
        double speed = gps.speed.kmph();
        
        // Send to Firebase
        Firebase.setDouble(firebaseData, "/Posisi/latitude", latitude);
        Firebase.setDouble(firebaseData, "/Posisi/longitude", longitude);
        Firebase.setDouble(firebaseData, "/Posisi/kecepatan", speed);
        Firebase.setString(firebaseData, "/Posisi/status", "Online");
        
        Serial.printf("Data sent - Lat: %.6f, Lng: %.6f, Speed: %.2f km/h\n", 
                      latitude, longitude, speed);
      }
    }
  }
  
  delay(5000); // Update setiap 5 detik
}
```

### 4. Koneksi Hardware GPS

**Untuk GPS Module NEO-6M:**
```
GPS Module → ESP32/ESP8266
VCC → 3.3V
GND → GND
TX → GPIO 16 (RX)
RX → GPIO 17 (TX)
```

---

## 📊 Struktur Data Realtime Database

Data harus disimpan dalam format berikut di Firebase:

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

### Field Explanation:
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `latitude` | double | Koordinat latitude GPS | -7.752281333 |
| `longitude` | double | Koordinat longitude GPS | 110.356881333 |
| `kecepatan` | double | Kecepatan dalam km/h | 45.5 |
| `status` | string | Status perangkat | "Online" / "Offline" |

---

## 📱 Cara Menggunakan Aplikasi

### Metode 1: Akses dari Tab Jam Tangan

1. **Buka aplikasi** dan login
2. **Pilih tab "Jam Tangan"** (icon jam di bottom navigation)
3. **Klik card "Perangkat IoT"** di bagian atas
4. **Tunggu koneksi** - aplikasi akan otomatis terhubung ke Realtime Database
5. **Lihat lokasi** perangkat pada peta

### Metode 2: Akses Langsung (Optional)

Anda juga bisa menambahkan akses langsung di halaman lain atau menu utama.

---

## 🎨 Fitur Halaman IoT Device

### 1. **Peta Real-time**
- Menampilkan lokasi perangkat dengan marker
- Marker hijau = Online
- Marker merah = Offline
- Auto zoom ke lokasi perangkat

### 2. **Info Panel**
Menampilkan informasi lengkap:
- 📍 Koordinat GPS (latitude, longitude)
- 🚀 Kecepatan perangkat
- 🟢 Status koneksi (Online/Offline)
- ⏰ Waktu update terakhir

### 3. **Status Indicator**
Badge di pojok kanan atas menampilkan:
- 🟢 **Terhubung** - Perangkat online
- 🔴 **Offline** - Perangkat tidak aktif

### 4. **Tombol Refresh**
- Refresh manual koneksi database
- Berguna jika koneksi terputus

---

## 🔐 Konfigurasi Firebase Rules

Pastikan Firebase Realtime Database Rules Anda mengizinkan read/write:

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

⚠️ **Catatan Keamanan:** Untuk production, gunakan rules yang lebih ketat dengan authentication.

---

## 🐛 Troubleshooting

### Problem 1: "Gagal terhubung ke database"

**Solusi:**
- Cek URL database di `iot_direct_connect_page.dart` line 29
- Pastikan URL sesuai dengan Firebase Console Anda
- Format: `https://nama-project-default-rtdb.region.firebasedatabase.app`

### Problem 2: Perangkat tidak muncul di peta

**Solusi:**
- Periksa apakah data sudah ada di Firebase Console
- Buka Firebase Console → Realtime Database → Lihat data di path `/Posisi`
- Pastikan field `latitude` dan `longitude` ada dan valid
- Cek koneksi internet perangkat IoT

### Problem 3: Data tidak update real-time

**Solusi:**
- Pastikan perangkat IoT mengirim data secara berkala
- Cek interval update di code Arduino (default 5 detik)
- Restart aplikasi Flutter
- Tekan tombol refresh di aplikasi

### Problem 4: Status selalu "Offline"

**Solusi:**
- Periksa field `status` di Firebase
- Pastikan ESP32/ESP8266 mengirim string "Online" (case-sensitive)
- Update code Arduino untuk set status dengan benar

### Problem 5: Koordinat tidak akurat

**Solusi:**
- Pastikan GPS module mendapat sinyal satelit yang cukup
- Gunakan GPS di luar ruangan (outdoor)
- Tunggu beberapa menit untuk GPS lock
- Periksa apakah `gps.location.isValid()` return true

---

## 🔄 Customisasi

### Mengubah Database URL

Edit file [iot_direct_connect_page.dart](lib/pages/iot_direct_connect_page.dart):

```dart
// Line 29-30
final String _databaseUrl = 'https://your-project-default-rtdb.region.firebasedatabase.app';
final String _devicePath = 'Posisi'; // atau path lain
```

### Mengubah Path Data

Jika Anda ingin menggunakan path berbeda (bukan `/Posisi`):

```dart
final String _devicePath = 'NamaPathAndaDisini';
```

### Mengubah Interval Update

Di code Arduino/ESP32:

```cpp
delay(5000); // Ubah nilai ini (dalam milliseconds)
// 1000 = 1 detik
// 5000 = 5 detik
// 10000 = 10 detik
```

---

## 📚 File Terkait

| File | Fungsi |
|------|--------|
| [iot_direct_connect_page.dart](lib/pages/iot_direct_connect_page.dart) | Halaman utama untuk menampilkan lokasi IoT |
| [iot_device_service.dart](lib/services/iot_device_service.dart) | Service untuk koneksi ke Realtime Database |
| [iot_device_page.dart](lib/pages/iot_device_page.dart) | Halaman IoT dengan fitur scan QR |
| [jam_tangan_page.dart](lib/pages/jam_tangan_page.dart) | Halaman navigasi dengan akses ke IoT |

---

## 💡 Tips & Best Practices

1. **Update Interval**: Gunakan interval 5-10 detik untuk balance antara real-time dan battery life
2. **GPS Accuracy**: Tunggu GPS lock sebelum mengirim data
3. **Battery Optimization**: Gunakan deep sleep mode di ESP32 saat tidak bergerak
4. **Error Handling**: Tambahkan retry logic di Arduino jika koneksi WiFi/Firebase gagal
5. **Data Validation**: Validasi data GPS sebelum dikirim (cek isValid())

---

## 🎥 Demo Flow

```
1. User membuka aplikasi
   ↓
2. Pilih tab "Jam Tangan"
   ↓
3. Klik "Perangkat IoT"
   ↓
4. Loading... (koneksi ke database)
   ↓
5. Peta muncul dengan marker perangkat
   ↓
6. Info panel menampilkan data real-time
   ↓
7. Marker auto-update saat perangkat bergerak
```

---

## 📞 Support

Jika ada masalah atau pertanyaan:
1. Periksa Firebase Console untuk melihat data
2. Cek Serial Monitor Arduino untuk debug
3. Lihat log aplikasi Flutter di Debug Console
4. Gunakan tombol Refresh di aplikasi

---

## ✅ Checklist Setup

- [ ] ESP32/ESP8266 terhubung WiFi
- [ ] GPS Module terpasang dengan benar
- [ ] Firebase project sudah dibuat
- [ ] Realtime Database sudah diaktifkan
- [ ] Database URL sudah dikonfigurasi di app
- [ ] Rules Firebase sudah diset
- [ ] Code Arduino sudah diupload
- [ ] GPS mendapat signal satelit
- [ ] Data muncul di Firebase Console
- [ ] Aplikasi berhasil menampilkan lokasi

---

**Selamat mencoba! 🚀**

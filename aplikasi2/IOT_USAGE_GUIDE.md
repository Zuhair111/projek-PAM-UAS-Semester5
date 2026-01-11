# 📱 Cara Menggunakan Fitur IoT Device - Step by Step

## Langkah 1: Persiapan Perangkat IoT

### Hardware yang Dibutuhkan:
- ✅ ESP32 atau ESP8266
- ✅ GPS Module (NEO-6M atau sejenisnya)
- ✅ Kabel jumper
- ✅ Power supply (USB atau battery)

### Koneksi Hardware:
```
GPS NEO-6M → ESP32
VCC → 3.3V
GND → GND
TX → GPIO 16 (RX pada ESP32)
RX → GPIO 17 (TX pada ESP32)
```

---

## Langkah 2: Upload Code ke ESP32

1. **Install Arduino IDE** dan library yang diperlukan:
   - WiFi.h (built-in)
   - FirebaseESP32.h
   - TinyGPS++.h

2. **Copy code** dari [IOT_DEVICE_SETUP.md](IOT_DEVICE_SETUP.md) bagian "Contoh Code"

3. **Edit WiFi credentials**:
   ```cpp
   #define WIFI_SSID "Nama_WiFi_Anda"
   #define WIFI_PASSWORD "Password_WiFi"
   ```

4. **Edit Firebase config**:
   ```cpp
   #define FIREBASE_HOST "aplikasi2-9ab49-default-rtdb.asia-southeast1.firebasedatabase.app"
   #define FIREBASE_AUTH "your_database_secret"
   ```

5. **Upload** ke ESP32

---

## Langkah 3: Verifikasi Data di Firebase

1. Buka **Firebase Console**: https://console.firebase.google.com
2. Pilih project: **aplikasi2-9ab49**
3. Klik **Realtime Database** di menu kiri
4. Anda akan melihat data seperti ini:

```
📁 aplikasi2-9ab49-default-rtdb
  └─📁 Posisi
      ├─ latitude: -7.752281333
      ├─ longitude: 110.356881333
      ├─ kecepatan: 0
      └─ status: "Online"
```

5. Data akan **update otomatis** setiap 5 detik (sesuai delay di code)

---

## Langkah 4: Menggunakan Aplikasi Flutter

### A. Buka Aplikasi

1. **Jalankan aplikasi** di smartphone Anda
2. **Login** dengan akun Anda
3. Anda akan masuk ke halaman utama

### B. Akses Halaman IoT Device

```
[Tab Lokasi] [Tab Keluarga] [Tab Jam Tangan]
                                    ↑
                              Pilih Tab Ini
```

1. **Klik tab "Jam Tangan"** di bottom navigation (icon jam)
2. Di bagian atas halaman, Anda akan melihat card **"Perangkat IoT"**
3. **Klik card tersebut**

### C. Halaman IoT Device Loading

```
┌─────────────────────────────────┐
│  ← Lokasi Perangkat IoT    🔄   │ ← Header + Refresh Button
├─────────────────────────────────┤
│                                 │
│     🔄 Loading spinner          │
│   Menghubungkan ke perangkat... │
│                                 │
└─────────────────────────────────┘
```

Aplikasi akan:
- Koneksi ke Firebase Realtime Database
- Membaca data dari path `/Posisi`
- Validasi data GPS

### D. Tampilan Peta Muncul

```
┌─────────────────────────────────┐
│  ← Lokasi Perangkat IoT    🔄   │
│                   🟢 Terhubung  │ ← Status Badge
├─────────────────────────────────┤
│                                 │
│        🗺️ GOOGLE MAPS           │
│                                 │
│          📍 Marker              │
│       (Lokasi Perangkat)        │
│                                 │
│                                 │
├─────────────────────────────────┤
│  ┌───────────────────────────┐ │
│  │ 🔧 Info Perangkat IoT     │ │ ← Info Panel
│  ├───────────────────────────┤ │
│  │ 📍 Lokasi:                │ │
│  │   -7.752281, 110.356881   │ │
│  │                           │ │
│  │ 🚀 Kecepatan: 0.0 km/h    │ │
│  │                           │ │
│  │ 🟢 Status: Online         │ │
│  │                           │ │
│  │ Update: 14:30:25          │ │
│  └───────────────────────────┘ │
└─────────────────────────────────┘
```

### E. Fitur Real-time

- **Marker akan bergerak** otomatis saat perangkat berpindah lokasi
- **Info panel update** secara real-time
- **Status badge** menampilkan koneksi (Hijau = Online, Merah = Offline)
- **Peta auto-zoom** ke lokasi terbaru

---

## Langkah 5: Monitoring Data

### Apa yang Bisa Anda Lihat:

1. **📍 Koordinat GPS**
   - Latitude & Longitude lengkap
   - Format: -7.752281, 110.356881

2. **🚀 Kecepatan**
   - Dalam km/h
   - Real-time update saat perangkat bergerak

3. **🟢 Status Koneksi**
   - Online: Perangkat aktif mengirim data
   - Offline: Perangkat tidak mengirim data

4. **⏰ Waktu Update**
   - Menampilkan kapan data terakhir diterima
   - Format: HH:MM:SS

### Marker di Peta:

- 🟢 **Marker Hijau** = Perangkat Online
- 🔴 **Marker Merah** = Perangkat Offline
- Klik marker untuk melihat info window

---

## Langkah 6: Testing Pergerakan

### Test 1: Perangkat Diam
```
Kondisi: ESP32 + GPS di posisi tetap
Expected: 
- Marker tetap di satu lokasi
- Kecepatan: 0 km/h
- Status: Online
```

### Test 2: Perangkat Bergerak
```
Kondisi: Bawa ESP32 + GPS sambil jalan/berkendara
Expected:
- Marker bergerak mengikuti lokasi real-time
- Kecepatan update sesuai pergerakan
- Peta auto-zoom mengikuti marker
```

### Test 3: Koneksi Terputus
```
Kondisi: Matikan ESP32 atau putus WiFi
Expected:
- Status berubah menjadi "Offline"
- Badge berubah merah
- Marker tetap di lokasi terakhir
```

### Test 4: Koneksi Kembali
```
Kondisi: Nyalakan kembali ESP32 + koneksi WiFi
Expected:
- Status kembali "Online"
- Badge hijau
- Marker update ke lokasi baru
```

---

## Troubleshooting Common Issues

### ❌ Problem: "Gagal terhubung ke database"

**Penyebab:**
- URL database salah
- Internet HP tidak aktif
- Firebase project tidak aktif

**Solusi:**
1. Cek koneksi internet HP
2. Verifikasi URL database di code
3. Buka Firebase Console untuk memastikan database aktif
4. Tekan tombol Refresh (🔄)

---

### ❌ Problem: Peta kosong / Marker tidak muncul

**Penyebab:**
- Data belum ada di Firebase
- GPS belum mendapat signal
- Format data salah

**Solusi:**
1. Buka Firebase Console → Realtime Database
2. Cek apakah data ada di path `/Posisi`
3. Pastikan GPS outdoor untuk mendapat signal
4. Tunggu 1-2 menit untuk GPS lock
5. Restart aplikasi

---

### ❌ Problem: Data tidak update

**Penyebab:**
- ESP32 tidak mengirim data
- Delay terlalu lama
- WiFi ESP32 terputus

**Solusi:**
1. Cek Serial Monitor Arduino
2. Pastikan WiFi connected
3. Cek apakah GPS mendapat data valid
4. Periksa Firebase rules (allow read/write)

---

## Tips Penggunaan

### 💡 Tip 1: Optimal GPS Signal
- Gunakan GPS di **luar ruangan** (outdoor)
- Hindari area dengan gedung tinggi
- Tunggu beberapa menit untuk GPS lock
- Pastikan GPS module menghadap langit

### 💡 Tip 2: Battery Optimization
- Gunakan interval update 10-30 detik untuk hemat battery
- Implementasi sleep mode saat tidak bergerak
- Gunakan power bank untuk tracking jangka panjang

### 💡 Tip 3: Accuracy Improvement
- Gunakan GPS module yang berkualitas (U-blox NEO-M8N lebih akurat)
- Tambahkan antenna eksternal jika perlu
- Filter data GPS (buang data dengan accuracy rendah)

### 💡 Tip 4: Multiple Devices
- Gunakan path berbeda untuk setiap device
  ```
  /Posisi/Device1
  /Posisi/Device2
  /Posisi/Device3
  ```
- Atau tambahkan deviceId di data
  ```json
  {
    "latitude": -7.752281333,
    "longitude": 110.356881333,
    "deviceId": "ESP32_001"
  }
  ```

---

## Flow Diagram Lengkap

```
┌─────────────────┐
│   Start App     │
└────────┬────────┘
         ↓
┌─────────────────┐
│  Login Screen   │
└────────┬────────┘
         ↓
┌─────────────────┐
│  Main Screen    │
│  (3 Tabs)       │
└────────┬────────┘
         ↓
    Pilih Tab
   "Jam Tangan"
         ↓
┌─────────────────┐
│ Jam Tangan Page │
│  ┌───────────┐  │
│  │Perangkat  │  │ ← Klik Card Ini
│  │   IoT     │  │
│  └───────────┘  │
└────────┬────────┘
         ↓
┌─────────────────┐
│   Loading...    │
│ Menghubungkan   │
└────────┬────────┘
         ↓
┌─────────────────┐
│  IoT Device     │
│     Page        │
│                 │
│  🗺️ Map View    │
│  📍 Marker      │
│  📊 Info Panel  │
└─────────────────┘
         ↑
         │
   Update Real-time
         │
         ↓
┌─────────────────┐
│   Firebase      │
│   Realtime DB   │
└────────┬────────┘
         ↑
         │
   Send Data
         │
┌─────────────────┐
│   ESP32/ESP8266 │
│   + GPS Module  │
└─────────────────┘
```

---

## Checklist Sebelum Mulai

Sebelum menggunakan fitur IoT, pastikan:

- [ ] ESP32/ESP8266 sudah diprogram
- [ ] GPS Module terpasang dengan benar
- [ ] WiFi sudah dikonfigurasi di code
- [ ] Firebase credentials sudah benar
- [ ] Perangkat sudah upload data ke Firebase
- [ ] Data terlihat di Firebase Console
- [ ] Aplikasi Flutter sudah terinstall
- [ ] Login ke aplikasi berhasil

---

## Video Tutorial (Conceptual)

### Part 1: Setup ESP32 (5 menit)
1. Pasang GPS Module
2. Upload code Arduino
3. Verifikasi di Serial Monitor

### Part 2: Verifikasi Firebase (2 menit)
1. Buka Firebase Console
2. Cek data di Realtime Database
3. Pastikan data update

### Part 3: Pakai Aplikasi (3 menit)
1. Buka aplikasi
2. Navigasi ke IoT Device page
3. Lihat lokasi di peta

---

## FAQ

**Q: Apakah harus scan QR code?**  
A: Tidak! Fitur ini langsung terhubung tanpa perlu scan QR.

**Q: Berapa lama update data?**  
A: Default 5 detik. Bisa diubah di code Arduino.

**Q: Bisa tracking berapa perangkat?**  
A: Saat ini 1 perangkat. Untuk multiple devices, perlu modifikasi.

**Q: Apakah data disimpan history?**  
A: Saat ini hanya data terbaru. Untuk history, perlu tambah fitur.

**Q: Bisa dipakai offline?**  
A: Tidak. Perlu koneksi internet untuk real-time sync.

---

**Selamat mencoba! Jika ada pertanyaan, silakan cek dokumentasi lengkap di [IOT_DEVICE_SETUP.md](IOT_DEVICE_SETUP.md)** 🚀

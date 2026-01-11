# 🎬 Demo Flow & Screenshots Guide

## 📱 User Journey

### Step 1: Launch App & Login
```
┌─────────────────────────┐
│                         │
│    🔐 Login Screen      │
│                         │
│   Email: _________      │
│   Pass:  _________      │
│                         │
│   [  LOGIN  ]           │
│                         │
└─────────────────────────┘
```

### Step 2: Main Navigation
```
┌─────────────────────────┐
│   Main Screen           │
│                         │
│   [Tab: Lokasi]         │
│   [Tab: Keluarga]       │
│  ▶[Tab: Jam Tangan]◀    │ ← PILIH INI
│                         │
└─────────────────────────┘
      [Lokasi][Keluarga][Jam]
         Bottom Navigation
```

### Step 3: Jam Tangan Page (Updated)
```
┌─────────────────────────┐
│ ← Jam Tangan            │
├─────────────────────────┤
│                         │
│  ┌───────────────────┐  │
│  │  🔧 Perangkat IoT │  │ ← KLIK INI
│  │  Lihat lokasi     │  │   (CARD BARU)
│  │  Arduino/ESP32    │  │
│  │              →    │  │
│  └───────────────────┘  │
│                         │
│  Sambungkan ke          │
│  smartwatch             │
│                         │
│      [Jam Icon]         │
│                         │
│  [Sambungkan Sekarang]  │ ← Untuk Smartwatch
│                         │
└─────────────────────────┘
```

### Step 4: Loading State
```
┌─────────────────────────┐
│ ← Lokasi Perangkat IoT🔄│
├─────────────────────────┤
│                         │
│          ⏳             │
│      Loading...         │
│                         │
│  Menghubungkan ke       │
│  perangkat...           │
│                         │
│                         │
└─────────────────────────┘
```

### Step 5: Map with Device Location
```
┌─────────────────────────┐
│ ← Lokasi Perangkat IoT🔄│
│                🟢Terhubung│
├─────────────────────────┤
│                         │
│    🗺️ GOOGLE MAPS       │
│                         │
│        📍              │ ← Marker (Hijau=Online)
│     (Device Location)   │
│                         │
│  🏠      🌳    🏢       │
│         Streets         │
│                         │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │ 🔧 Info Perangkat   │ │
│ ├─────────────────────┤ │
│ │ 📍 -7.752, 110.356  │ │
│ │ 🚀 Kecepatan: 0 km/h│ │
│ │ 🟢 Status: Online   │ │
│ │ ⏰ Update: 14:30:25 │ │
│ └─────────────────────┘ │
└─────────────────────────┘
```

---

## 🔄 Real-time Update Flow

### When Device Moves:

```
ESP32 GPS Update
       ↓
  New Location
       ↓
 Send to Firebase
       ↓
Firebase Realtime DB
   /Posisi updated
       ↓
  Stream Event
       ↓
   Flutter App
       ↓
  Update Marker
       ↓
   Auto Zoom Map
       ↓
Update Info Panel
```

---

## 🎨 UI Components Detail

### 1. Header (App Bar)
```
┌─────────────────────────┐
│ ←  Lokasi Perangkat IoT 🔄│ ← Back Button + Refresh
└─────────────────────────┘
```

### 2. Status Badge
```
┌─────────────┐
│ 🟢 Terhubung │ ← Green when Online
└─────────────┘

┌─────────────┐
│ 🔴 Offline   │ ← Red when Offline
└─────────────┘
```

### 3. Map Markers
```
Online Device:      Offline Device:
     📍                  📍
   (Green)             (Red)
```

### 4. Info Panel (Expanded)
```
┌─────────────────────────────────┐
│  🔧 Info Perangkat IoT          │
├─────────────────────────────────┤
│                                 │
│  📍 Lokasi:                     │
│     -7.752281, 110.356881       │
│                                 │
│  🚀 Kecepatan:                  │
│     45.5 km/h                   │
│                                 │
│  🟢 Status: Online              │
│                                 │
│  ⏰ Update: 14:30:25            │
└─────────────────────────────────┘
```

---

## 🔧 Backend Flow

### Arduino/ESP32 Code Flow:
```
┌─────────────────┐
│  Setup()        │
│  - Connect WiFi │
│  - Init Firebase│
│  - Init GPS     │
└────────┬────────┘
         ↓
┌─────────────────┐
│  Loop()         │
│  ┌───────────┐  │
│  │ Read GPS  │  │
│  └─────┬─────┘  │
│        ↓        │
│  ┌───────────┐  │
│  │ Validate  │  │
│  └─────┬─────┘  │
│        ↓        │
│  ┌───────────┐  │
│  │Send to FB │  │
│  └─────┬─────┘  │
│        ↓        │
│  ┌───────────┐  │
│  │ Delay 5s  │  │
│  └───────────┘  │
│        ↑        │
└────────┘        │
         Repeat ──┘
```

### Flutter App Flow:
```
┌─────────────────┐
│ Init Service    │
│ - Set DB URL    │
│ - Set Path      │
└────────┬────────┘
         ↓
┌─────────────────┐
│ Start Listening │
│ - Subscribe     │
│   to Stream     │
└────────┬────────┘
         ↓
┌─────────────────┐
│ Stream Event    │
│ - New Data?     │
└────────┬────────┘
         ↓
┌─────────────────┐
│ Update UI       │
│ - Update Marker │
│ - Move Camera   │
│ - Update Info   │
└─────────────────┘
```

---

## 📊 Data Flow Diagram

```
┌──────────────┐
│   ESP32      │ ← Read GPS coordinates
│   + GPS      │
└──────┬───────┘
       │
       │ WiFi
       ↓
┌──────────────┐
│   Firebase   │ ← Store in /Posisi
│  Realtime DB │   {lat, lng, speed, status}
└──────┬───────┘
       │
       │ Stream
       ↓
┌──────────────┐
│   Flutter    │ ← Listen to changes
│     App      │   Update UI real-time
└──────┬───────┘
       │
       ↓
┌──────────────┐
│  User sees   │ ← See on map
│  location    │
└──────────────┘
```

---

## 🧪 Test Scenarios Visual

### Scenario 1: First Load
```
User Action          App State
   │
   ├─ Open App  ──▶  [Splash Screen]
   │
   ├─ Login     ──▶  [Main Nav]
   │
   ├─ Tab "Jam" ──▶  [Jam Tangan Page]
   │
   ├─ Click IoT ──▶  [Loading...]
   │
   └─ Wait      ──▶  [Map Loaded ✓]
```

### Scenario 2: Device Moving
```
Time        Location        Map Display
───────────────────────────────────────
10:00:00    -7.752, 110.356  📍 Point A
10:00:05    -7.753, 110.357  📍 Point B (moved)
10:00:10    -7.754, 110.358  📍 Point C (moved)
10:00:15    -7.755, 110.359  📍 Point D (moved)
```

### Scenario 3: Connection Lost
```
State        Display              Action
─────────────────────────────────────────
Online  ──▶  🟢 Terhubung    ──▶ Update real-time
  │
  ├─ WiFi Off
  │
Offline ──▶  🔴 Offline      ──▶ Keep last position
  │
  ├─ WiFi On
  │
Online  ──▶  🟢 Terhubung    ──▶ Resume updates
```

---

## 💡 Visual Tips

### Marker Colors Meaning:
```
🟢 Green Marker = Device is Online & Sending Data
🔴 Red Marker   = Device Offline / Not Sending Data
```

### Info Panel Updates:
```
Static Data (Fixed):
- Device Name/Type

Dynamic Data (Updates):
- 📍 Coordinates
- 🚀 Speed
- 🟢 Status
- ⏰ Update Time
```

### Button Functions:
```
← Back Button        = Return to Jam Tangan Page
🔄 Refresh Button    = Reconnect to Database
📍 My Location (Map) = Center map to user location
```

---

## 🎯 Key Visual Elements

### Color Scheme:
```
Primary:   #E07B4F (Orange) - Brand color
Success:   #4CAF50 (Green)  - Online status
Error:     #F44336 (Red)    - Offline status
Background:#FFF8F0 (Cream)  - App background
```

### Icons Used:
```
🔧 developer_board   = IoT Device
📍 location_on       = GPS Location
🚀 speed            = Speed/Velocity
🟢 circle           = Status indicator
⏰ schedule         = Time/Update
🔄 refresh          = Reload/Reconnect
← arrow_back        = Navigation back
```

---

## 📐 Layout Structure

```
┌─────────────────────────────────┐  ← Screen (100%)
│ ┌─────────────────────────────┐ │  ← AppBar (56px)
│ │   Header with Refresh       │ │
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │  ← Status Badge (40px)
│ │  🟢 Terhubung              │ │
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │  ← Map (Flex 1)
│ │                             │ │
│ │    Google Maps View         │ │
│ │                             │ │
│ │         📍                 │ │
│ │                             │ │
│ │                             │ │
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │  ← Info Panel (180px)
│ │  Info Perangkat             │ │
│ │  - Location                 │ │
│ │  - Speed                    │ │
│ │  - Status                   │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

---

## 🔊 User Feedback

### Loading States:
```
1. Initial Load
   ⏳ "Menghubungkan ke perangkat..."

2. Refreshing
   🔄 Brief spinner

3. Error
   ❌ "Gagal terhubung ke database"
   [Coba Lagi Button]
```

### Success States:
```
✅ Map loaded with marker
✅ Info panel showing data
✅ Green status badge
```

### Error States:
```
❌ Connection error message
🔴 Red status badge (offline)
⚠️ No data available message
```

---

## 📱 Responsive Design

### Phone (Portrait):
```
┌───────────┐
│  Header   │
│  Map      │
│  (Large)  │
│           │
│  Info     │
│  (Small)  │
└───────────┘
```

### Tablet (Landscape):
```
┌─────────────────────────┐
│       Header            │
├─────────────┬───────────┤
│             │           │
│     Map     │   Info    │
│   (Wide)    │  Panel    │
│             │  (Side)   │
└─────────────┴───────────┘
```

---

## 🎓 For Presentation

### Demo Script:

1. **Intro** (30 sec)
   - "Aplikasi ini bisa tracking lokasi perangkat IoT real-time"

2. **Show Firebase** (30 sec)
   - "Data dari Arduino/ESP32 tersimpan di sini"
   - Show Realtime Database with data

3. **Open App** (1 min)
   - Login → Tab Jam Tangan → Klik Perangkat IoT

4. **Explain Features** (2 min)
   - Map dengan marker
   - Info panel real-time
   - Status indicator

5. **Show Real-time** (1 min)
   - Update data di Firebase
   - Show auto-update di app

6. **Q&A** (1 min)

---

## 📸 Screenshot Checklist

Untuk dokumentasi, ambil screenshot:
- [ ] Jam Tangan Page dengan card IoT
- [ ] Loading state
- [ ] Map dengan marker hijau (online)
- [ ] Map dengan marker merah (offline)
- [ ] Info panel detail
- [ ] Firebase Console dengan data
- [ ] Serial Monitor Arduino
- [ ] Error state
- [ ] Success notification

---

## 🎨 Mockup (ASCII Art)

### Full Page View:
```
┏━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ ← Lokasi Perangkat IoT 🔄┃
┃              🟢 Terhubung ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃         🗺️ MAP           ┃
┃    ╔═══════════════╗     ┃
┃    ║   🏙️ City    ║     ┃
┃    ║       📍      ║     ┃
┃    ║   Device      ║     ┃
┃    ║               ║     ┃
┃    ╚═══════════════╝     ┃
┃                          ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃ ╔══════════════════════╗ ┃
┃ ║ 🔧 Info Perangkat    ║ ┃
┃ ╠══════════════════════╣ ┃
┃ ║ 📍 -7.752, 110.356   ║ ┃
┃ ║ 🚀 Speed: 45.5 km/h  ║ ┃
┃ ║ 🟢 Status: Online    ║ ┃
┃ ║ ⏰ 14:30:25          ║ ┃
┃ ╚══════════════════════╝ ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

---

**Use these visuals for:**
- 📊 Presentations
- 📱 User training
- 📖 Documentation
- 🎓 Tutorials
- 🐛 Bug reports

**Visual aids make everything clearer! 🎨**

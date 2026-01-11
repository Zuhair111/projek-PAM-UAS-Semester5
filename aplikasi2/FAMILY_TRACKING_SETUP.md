# 👨‍👩‍👧‍👦 Family Tracking Setup - Panduan Lengkap

## Konsep: 2 Sistem yang Bekerja Bersama

### 1️⃣ **QR Pairing** = Menghubungkan Device untuk 1 User
```
User: Ayah
├── Device 1: Smartphone 📱 → ayah@example.com
└── Device 2: Smartwatch ⌚ → ayah@example.com (SAMA)
```
**Fungsi:** Sinkronisasi data antara smartphone & smartwatch untuk user yang sama

---

### 2️⃣ **Family System** = Menghubungkan Banyak User
```
Family: "Keluarga Budi" (familyId: family123)
├── Ayah → ayah@example.com
│   ├── Smartphone 📱
│   └── Smartwatch ⌚
│
├── Ibu → ibu@example.com
│   ├── Smartphone 📱
│   └── Smartwatch ⌚
│
└── Anak → anak@example.com
    ├── Smartphone 📱
    └── Smartwatch ⌚
```
**Fungsi:** Tracking lokasi antar anggota keluarga

---

## 🎯 Use Case: Ayah Ingin Track Anak

### Scenario:
- Ayah punya smartphone + smartwatch
- Anak punya smartphone + smartwatch sendiri
- Ayah ingin track lokasi Anak dari smartphone Ayah

---

## 📋 Step-by-Step Setup

### **Step 1: Ayah Setup Akun & Device**

#### 1A. Registrasi Ayah
```
📱 Smartphone Ayah
┌─────────────────────────┐
│  Register               │
│  ────────────────        │
│  Nama: Ayah             │
│  Email: ayah@mail.com   │
│  Password: •••••••••    │
│  Role: Orang Tua        │
│                         │
│  [  Daftar  ]           │
└─────────────────────────┘
```

#### 1B. Pairing Smartwatch Ayah
```
📱 Smartphone Ayah          ⌚ Smartwatch Ayah
┌──────────────┐           ┌──────────────┐
│ Scan QR      │ ────────> │   QR CODE    │
│              │           │   ▓▓▓▓▓▓▓    │
│ Konfirmasi   │           │   123456     │
│ Password     │           │              │
└──────────────┘           └──────────────┘
        ↓                         ↓
    ayah@mail.com  ←───────  ayah@mail.com
                    (AKUN SAMA!)
```

**Result:**
```javascript
// Firestore: family_members collection
{
  userId: "uid_ayah",
  name: "Ayah",
  email: "ayah@example.com",
  familyId: "family123",  // ← Auto-generated saat registrasi
  role: "orangtua",
  hasSmartwatch: true,
  currentLocation: { lat, lng, ... }
}
```

---

### **Step 2: Anak Setup Akun & Device**

#### 2A. Registrasi Anak
```
📱 Smartphone Anak
┌─────────────────────────┐
│  Register               │
│  ────────────────        │
│  Nama: Anak             │
│  Email: anak@mail.com   │
│  Password: •••••••••    │
│  Role: Anak             │
│                         │
│  [  Daftar  ]           │
└─────────────────────────┘
```

⚠️ **Penting:** Setelah registrasi, Anak belum ada di family Ayah!

#### 2B. Pairing Smartwatch Anak
```
📱 Smartphone Anak          ⌚ Smartwatch Anak
┌──────────────┐           ┌──────────────┐
│ Scan QR      │ ────────> │   QR CODE    │
│              │           │   ▓▓▓▓▓▓▓    │
│ Konfirmasi   │           │   456789     │
│ Password     │           │              │
└──────────────┘           └──────────────┘
        ↓                         ↓
   anak@mail.com  ←────────  anak@mail.com
                   (AKUN SAMA!)
```

**Result:**
```javascript
// Firestore: family_members collection
{
  userId: "uid_anak",
  name: "Anak",
  email: "anak@example.com",
  familyId: "family456",  // ← Family BERBEDA! (belum join)
  role: "anak",
  hasSmartwatch: true,
  currentLocation: { lat, lng, ... }
}
```

---

### **Step 3: Hubungkan Anak ke Family Ayah** ✨

#### Opsi A: Pakai Fitur "Tambah Anggota Keluarga" (Existing Feature)

##### 3.1. Ayah Kirim Undangan
```
📱 Smartphone Ayah
┌──────────────────────────────────┐
│  Family                          │
│  ────────────────────────────    │
│  👤 Ayah (Saya)                  │
│                                  │
│  [+ Tambah Anggota Keluarga]    │
└──────────────────────────────────┘
        ↓
┌──────────────────────────────────┐
│  Tambah Anggota                  │
│  ────────────────────────────    │
│  Nama: Anak                      │
│  Email: anak@mail.com            │
│  Role: Anak                      │
│  Has Smartwatch: ✅              │
│                                  │
│  [  Kirim Undangan  ]            │
└──────────────────────────────────┘
```

**Backend:**
```javascript
// Firestore: family_invitations collection
{
  invitationId: "inv123",
  fromUserId: "uid_ayah",
  fromName: "Ayah",
  toEmail: "anak@example.com",
  familyId: "family123",
  status: "pending",
  createdAt: Timestamp
}

// Kirim notifikasi/email ke anak@example.com
```

##### 3.2. Anak Terima Undangan
```
📱 Smartphone Anak
┌──────────────────────────────────┐
│  🔔 Notifikasi                   │
│  ────────────────────────────    │
│  Ayah mengundang Anda bergabung  │
│  ke Keluarga "Keluarga Budi"     │
│                                  │
│  [Tolak]      [Terima]           │
└──────────────────────────────────┘
        ↓ (Klik Terima)
```

**Backend Update:**
```javascript
// Update family_members - Anak
{
  userId: "uid_anak",
  name: "Anak",
  email: "anak@example.com",
  familyId: "family123",  // ← UPDATE! Sekarang sama dengan Ayah
  role: "anak",
  hasSmartwatch: true,
  currentLocation: { lat, lng, ... }
}

// Update invitation status
{
  invitationId: "inv123",
  status: "accepted"  // ← pending → accepted
}
```

---

#### Opsi B: Pakai Kode Undangan (Alternative)

##### 3.1. Ayah Generate Kode
```
📱 Smartphone Ayah
┌──────────────────────────────────┐
│  Family Settings                 │
│  ────────────────────────────    │
│  Family Code:                    │
│                                  │
│     ┌──────────────┐             │
│     │   ABC-123    │  📋 Copy   │
│     └──────────────┘             │
│                                  │
│  Share kode ini ke keluarga      │
└──────────────────────────────────┘
```

##### 3.2. Anak Input Kode
```
📱 Smartphone Anak
┌──────────────────────────────────┐
│  Join Family                     │
│  ────────────────────────────    │
│  Family Code:                    │
│  ┌──────────────────────┐        │
│  │  ABC-123             │        │
│  └──────────────────────┘        │
│                                  │
│  [  Join Family  ]               │
└──────────────────────────────────┘
```

---

### **Step 4: Verifikasi Setup Berhasil**

```
📱 Smartphone Ayah → Family → Peta Lokasi
┌────────────────────────────────────┐
│  🗺️ Peta Keluarga                 │
│  ──────────────────────────────    │
│                                    │
│     📍 Ayah (lat: -6.123)          │
│                                    │
│     📍 Anak (lat: -6.456)          │
│                                    │
│  ✅ Real-time tracking active     │
└────────────────────────────────────┘
```

**Firestore Query:**
```dart
// Di smartphone Ayah
final familyMembers = await FirebaseFirestore.instance
    .collection('family_members')
    .where('familyId', isEqualTo: 'family123')  // familyId Ayah
    .where('hasSmartwatch', isEqualTo: true)
    .get();

// Result:
// 1. Ayah (uid_ayah, currentLocation: {...})
// 2. Anak (uid_anak, currentLocation: {...})
```

---

## 📊 Data Structure

### Firestore Collections

#### 1. `family_members` Collection
```javascript
// Document 1: Ayah
{
  userId: "uid_ayah",
  name: "Ayah",
  email: "ayah@example.com",
  familyId: "family123",  // ← SAME
  role: "orangtua",
  hasSmartwatch: true,
  isOnline: true,
  currentLocation: {
    latitude: -6.123456,
    longitude: 107.123456,
    accuracy: 10,
    timestamp: Timestamp
  },
  lastSeen: Timestamp,
  batteryLevel: 85
}

// Document 2: Anak
{
  userId: "uid_anak",
  name: "Anak",
  email: "anak@example.com",
  familyId: "family123",  // ← SAME (setelah join)
  role: "anak",
  hasSmartwatch: true,
  isOnline: true,
  currentLocation: {
    latitude: -6.456789,
    longitude: 107.456789,
    accuracy: 15,
    timestamp: Timestamp
  },
  lastSeen: Timestamp,
  batteryLevel: 70
}
```

#### 2. `family_invitations` Collection
```javascript
{
  invitationId: "inv123",
  fromUserId: "uid_ayah",
  fromName: "Ayah",
  toEmail: "anak@example.com",
  familyId: "family123",
  status: "accepted",  // pending → accepted
  createdAt: Timestamp,
  acceptedAt: Timestamp
}
```

---

## 🔄 Complete Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│  AYAH                                                       │
├─────────────────────────────────────────────────────────────┤
│  1. Register → ayah@example.com                            │
│  2. Scan QR smartwatch → Smartwatch login: ayah@example.com│
│  3. Buat/Join Family → familyId: family123                 │
│  4. Kirim undangan ke anak@example.com                     │
└─────────────────────────────────────────────────────────────┘
                            ↓
                    [ Firestore ]
                    family_invitations
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  ANAK                                                       │
├─────────────────────────────────────────────────────────────┤
│  1. Register → anak@example.com                            │
│  2. Scan QR smartwatch → Smartwatch login: anak@example.com│
│  3. Terima undangan dari Ayah                              │
│  4. Update familyId → family123 (SAMA dengan Ayah)         │
└─────────────────────────────────────────────────────────────┘
                            ↓
                    [ Firestore ]
                    family_members
                    (familyId sama)
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  TRACKING AKTIF                                             │
├─────────────────────────────────────────────────────────────┤
│  • Smartwatch Ayah → GPS → Firestore → Map Ayah/Anak      │
│  • Smartwatch Anak → GPS → Firestore → Map Ayah/Anak      │
│  • Real-time sinkronisasi                                  │
│  • Ayah bisa track Anak ✅                                 │
│  • Anak bisa track Ayah ✅                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 💡 Key Points

### ✅ **QR Pairing**
- **Tujuan:** Connect device untuk 1 user
- **Contoh:** Ayah connect smartphone + smartwatch Ayah
- **Result:** Kedua device login dengan akun yang sama

### ✅ **Family System**
- **Tujuan:** Connect multiple users dalam 1 keluarga
- **Contoh:** Ayah, Ibu, Anak dalam 1 family
- **Result:** Bisa tracking lokasi antar anggota

### ✅ **Kombinasi Keduanya**
```
Ayah:
  1. QR Pairing: Smartphone + Smartwatch Ayah (ayah@example.com)
  2. Family: Join family123

Anak:
  1. QR Pairing: Smartphone + Smartwatch Anak (anak@example.com)
  2. Family: Join family123 (via undangan dari Ayah)

Result:
  → Ayah bisa track Anak dari smartphone Ayah
  → Data dari smartwatch Anak → Firestore → Map Ayah
```

---

## 🎯 Testing Checklist

### Phase 1: Setup Ayah
- [ ] Register ayah@example.com
- [ ] Login di smartphone Ayah
- [ ] QR pairing smartwatch Ayah
- [ ] Verify smartwatch Ayah tracking aktif
- [ ] Check Firestore: family_members document Ayah

### Phase 2: Setup Anak
- [ ] Register anak@example.com
- [ ] Login di smartphone Anak
- [ ] QR pairing smartwatch Anak
- [ ] Verify smartwatch Anak tracking aktif
- [ ] Check Firestore: family_members document Anak (familyId berbeda)

### Phase 3: Join Family
- [ ] Ayah kirim undangan ke anak@example.com
- [ ] Check Firestore: family_invitations document
- [ ] Anak buka notifikasi/undangan
- [ ] Anak terima undangan
- [ ] Check Firestore: Anak familyId updated (sama dengan Ayah)

### Phase 4: Verify Tracking
- [ ] Smartphone Ayah: Buka Family → Peta Lokasi
- [ ] Verify marker Ayah muncul
- [ ] Verify marker Anak muncul
- [ ] Test real-time update: Anak pindah lokasi
- [ ] Verify marker Anak bergerak di map Ayah

---

## 🐛 Troubleshooting

### Problem: Anak tidak muncul di map Ayah
**Possible Causes:**
1. ❌ familyId berbeda (belum join family)
2. ❌ hasSmartwatch = false
3. ❌ isOnline = false
4. ❌ currentLocation kosong

**Solutions:**
```dart
// Check Firestore
1. Verify Anak familyId == Ayah familyId
2. Verify Anak hasSmartwatch == true
3. Verify Anak isOnline == true
4. Verify Anak currentLocation exists
```

### Problem: Undangan tidak sampai ke Anak
**Solutions:**
1. Check email Anak benar
2. Check Firestore family_invitations document exists
3. Implement push notification atau in-app notification
4. Alternative: Pakai family code instead

---

## 📚 Related Features

### Existing Features (Sudah Ada):
- [x] User Registration & Login
- [x] Family Creation
- [x] Add Family Member (via invite/code)
- [x] Family Page with member list
- [x] Location Page with real-time GPS
- [x] Map View with markers

### New Feature (Just Implemented):
- [x] QR Code Pairing (Smartphone ↔ Smartwatch)
- [x] Auto-login smartwatch with same account
- [x] Real-time location sync

### Future Enhancement:
- [ ] Family admin controls
- [ ] Location history timeline
- [ ] Geofencing alerts
- [ ] SOS emergency button
- [ ] Battery low notifications

---

## 🎉 Summary

**Setup Workflow:**
1. **Ayah:** Register → QR Pairing → Buat Family
2. **Anak:** Register → QR Pairing → Join Family (via undangan)
3. **Result:** Ayah bisa track lokasi Anak real-time! ✅

**Key Concept:**
- QR Pairing = Connect devices (same user)
- Family System = Connect users (different accounts)
- Both work together for complete family tracking solution!

---

**Status: ✅ Fully Documented & Ready to Implement**

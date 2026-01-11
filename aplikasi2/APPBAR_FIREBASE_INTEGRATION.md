# 🎯 Custom AppBar - Firebase Integration

## ✨ Update Terbaru

CustomAppBar sekarang menampilkan **informasi user yang login** secara real-time dari Firebase!

---

## 🔥 Fitur Baru

### 1. **Dynamic User Name**
AppBar sekarang menampilkan nama user yang sebenarnya dari Firebase:
- ✅ Fetch data dari Firestore (`users/{uid}/name`)
- ✅ Fallback ke Firebase Auth (`displayName`)
- ✅ Fallback ke email username (`email.split('@')[0]`)
- ✅ Default 'User' jika tidak ada data

### 2. **Smart Greeting**
Salam berubah otomatis berdasarkan waktu:
- 🌅 **00:00 - 11:59**: "Selamat Pagi"
- ☀️ **12:00 - 14:59**: "Selamat Siang"
- 🌤️ **15:00 - 17:59**: "Selamat Sore"
- 🌙 **18:00 - 23:59**: "Selamat Malam"

### 3. **Loading State**
Skeleton loading saat fetch data:
- ✅ Placeholder animation
- ✅ Smooth transition ke data real
- ✅ No blank screen

---

## 📊 Sebelum vs Sekarang

### ❌ Sebelum (Hardcoded):
```dart
Text('Selamat Datang,'),  // Static
Text('Sandhika'),          // Hardcoded name
```

### ✅ Sekarang (Dynamic):
```dart
Text('$_greetingTime,'),   // Berubah sesuai waktu
Text(_displayName),         // Dari Firebase
```

---

## 🔧 Implementasi

### 1. **Import Firebase**
```dart
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
```

### 2. **State Variables**
```dart
final AuthService _authService = AuthService();
String _displayName = 'User';
String _greetingTime = 'Selamat Datang';
bool _isLoading = true;
```

### 3. **Load User Data**
```dart
Future<void> _loadUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userData = await _authService.getUserData(user.uid);
    setState(() {
      if (userData != null && userData['name'] != null) {
        _displayName = userData['name'];  // Dari Firestore
      } else {
        _displayName = user.displayName ?? 
                      user.email?.split('@')[0] ?? 
                      'User';
      }
      _isLoading = false;
    });
  }
}
```

### 4. **Update Greeting**
```dart
void _updateGreeting() {
  final hour = DateTime.now().hour;
  setState(() {
    if (hour < 12) {
      _greetingTime = 'Selamat Pagi';
    } else if (hour < 15) {
      _greetingTime = 'Selamat Siang';
    } else if (hour < 18) {
      _greetingTime = 'Selamat Sore';
    } else {
      _greetingTime = 'Selamat Malam';
    }
  });
}
```

### 5. **UI dengan Loading State**
```dart
Expanded(
  child: _isLoading
      ? _buildLoadingState()  // Skeleton
      : _buildUserInfo(),     // Real data
),
```

---

## 🎨 UI Components

### Loading State (Skeleton):
```dart
Column(
  children: [
    Container(
      height: 14,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    SizedBox(height: 4),
    Container(
      height: 16,
      width: 80,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  ],
)
```

### User Info Display:
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      '$_greetingTime,',           // "Selamat Pagi,"
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[700],
      ),
    ),
    Text(
      _displayName,                 // "Nama User"
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  ],
)
```

---

## 📱 Data Priority Flow

### 1️⃣ **Firestore (Primary)**
```
users/{uid}/name → "John Doe"
```

### 2️⃣ **Firebase Auth (Fallback)**
```
currentUser.displayName → "John"
```

### 3️⃣ **Email Username (Fallback)**
```
currentUser.email → "john@gmail.com" → "john"
```

### 4️⃣ **Default (Last Resort)**
```
"User"
```

---

## ⏰ Greeting Time Logic

| Waktu | Greeting |
|-------|----------|
| 00:00 - 11:59 | Selamat Pagi |
| 12:00 - 14:59 | Selamat Siang |
| 15:00 - 17:59 | Selamat Sore |
| 18:00 - 23:59 | Selamat Malam |

---

## 🧪 Testing

### Test 1: Login dengan User Baru
1. Register dengan nama "Test User"
2. Login
3. ✅ AppBar harus show "Test User"
4. ✅ Greeting sesuai waktu

### Test 2: Login pada Waktu Berbeda
1. Pagi (08:00): ✅ "Selamat Pagi, Test User"
2. Siang (13:00): ✅ "Selamat Siang, Test User"
3. Sore (16:00): ✅ "Selamat Sore, Test User"
4. Malam (20:00): ✅ "Selamat Malam, Test User"

### Test 3: Loading State
1. Logout
2. Login lagi
3. ✅ Muncul skeleton loading
4. ✅ Smooth transition ke nama user

### Test 4: User Tanpa Nama di Firestore
1. Login dengan user yang hanya ada di Auth
2. ✅ Fallback ke displayName atau email username
3. ✅ No blank/error

---

## 🔄 Lifecycle

```
initState()
  ├─ _loadUserData()      // Fetch dari Firebase
  │   ├─ Get currentUser
  │   ├─ Get userData from Firestore
  │   └─ setState() → Update _displayName
  └─ _updateGreeting()    // Set greeting berdasarkan waktu
      └─ setState() → Update _greetingTime

build()
  └─ Show loading OR user info
```

---

## 🎯 Benefits

### User Experience:
- ✅ **Personalized**: Nama user yang sebenarnya
- ✅ **Context-aware**: Salam berubah sesuai waktu
- ✅ **Smooth**: Loading state yang natural
- ✅ **Professional**: Design yang polished

### Developer Experience:
- ✅ **Reusable**: Pakai di semua page via main navigation
- ✅ **Maintainable**: Centralized logic
- ✅ **Error-proof**: Multiple fallbacks
- ✅ **Type-safe**: Proper null handling

---

## 📍 Where It's Used

CustomAppBar digunakan di:
- ✅ **LocationPage** (via isInMainNavigation)
- ✅ **FamilyPage** (via isInMainNavigation)
- ✅ **JamTanganPage**

Semua page yang menggunakan CustomAppBar otomatis mendapat fitur ini!

---

## 🚀 Future Enhancements

### 1. **Profile Picture dari Firebase**
```dart
// Upload & display foto profile
final photoURL = user.photoURL;
if (photoURL != null) {
  Image.network(photoURL)
} else {
  Icon(Icons.person)
}
```

### 2. **Real-time Updates**
```dart
// Stream dari Firestore
FirebaseAuth.instance.authStateChanges().listen((user) {
  if (user != null) {
    _loadUserData();
  }
});
```

### 3. **Cache User Data**
```dart
// Simpan di SharedPreferences
// Tampilkan immediately, update di background
```

### 4. **Badge Notifications**
```dart
// Hitung unread notifications
// Tampilkan badge count
```

---

## 📝 Example Displays

### User: "John Doe", Time: 09:00
```
Selamat Pagi,
John Doe
```

### User: "jane@mail.com" (no name), Time: 14:00
```
Selamat Siang,
jane
```

### User: Baru login, Loading
```
[gray box]
[gray box]
```

---

## 🔐 Error Handling

### Network Error:
```dart
try {
  final userData = await _authService.getUserData(user.uid);
} catch (e) {
  print('Error: $e');
  // Fallback to default 'User'
}
```

### User Not Logged In:
```dart
if (user == null) {
  setState(() {
    _displayName = 'User';
  });
}
```

### Firestore Data Missing:
```dart
if (userData == null || userData['name'] == null) {
  // Use Firebase Auth data
  _displayName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
}
```

---

## 📚 Related Files

- **CustomAppBar**: `lib/widgets/custom_app_bar.dart`
- **Auth Service**: `lib/services/auth_service.dart`
- **Main Navigation**: `lib/pages/main_navigation_page.dart`

---

**AppBar sekarang personal dan smart! 🎉**

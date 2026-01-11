# 🔄 Profile Page - Firebase Integration

## ✨ Fitur Baru

Profile Page sekarang **terkoneksi dengan Firebase** dan menampilkan data user yang sebenarnya!

### 🎯 Yang Berubah:

#### **Sebelum (Hardcoded)**:
```dart
const Text('Sandhika Galih')  // Data statis
const Text('@sandhika_galih')
```

#### **Sekarang (Dynamic dari Firebase)**:
```dart
Text(_displayName)        // Data dari Firebase Auth/Firestore
Text(_displayUsername)    // Generated dari email
Text(_displayRole)        // Role dari Firestore
```

---

## 📊 Data yang Ditampilkan

### 1. **Profile Header**
- **Nama**: Dari Firestore (`users/{uid}/name`) atau Firebase Auth
- **Username**: Generated dari email (contoh: `test@mail.com` → `@test`)
- **Role Badge**: "Orang Tua" atau "Anak" dari Firestore

### 2. **User Info Card** (Baru!)
Card informasi lengkap dengan:
- **Email**: Email user dari Firebase Auth
- **Role**: Role dari database
- **Tanggal Bergabung**: Timestamp dari Firestore (`createdAt`)

### 3. **Loading States**
- Loading indicator di AppBar saat fetching data
- Full screen loading untuk initial load
- Pull-to-refresh untuk refresh data

---

## 🔥 Integrasi Firebase

### Data Source:
```dart
// Firebase Auth
final user = FirebaseAuth.instance.currentUser;
user.email        // Email
user.displayName  // Nama (optional)
user.uid          // User ID

// Firestore
await _authService.getUserData(user.uid);
// Returns:
{
  'uid': 'xxx',
  'email': 'user@mail.com',
  'name': 'User Name',
  'role': 'parent',
  'createdAt': Timestamp
}
```

### Prioritas Data:
1. **Firestore** (primary) - Data lengkap dari database
2. **Firebase Auth** (fallback) - Jika Firestore tidak ada
3. **Default** (last resort) - 'User' jika tidak ada data

---

## 💡 Cara Kerja

### 1. **Initial Load** (`initState`)
```dart
@override
void initState() {
  super.initState();
  _loadUserData();  // Fetch data saat pertama kali buka
}
```

### 2. **Fetch User Data**
```dart
Future<void> _loadUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userData = await _authService.getUserData(user.uid);
    setState(() {
      _userData = userData;
      _isLoading = false;
    });
  }
}
```

### 3. **Display Data**
```dart
String get _displayName {
  if (_userData != null && _userData!['name'] != null) {
    return _userData!['name'];  // Dari Firestore
  }
  final user = FirebaseAuth.instance.currentUser;
  return user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
}
```

---

## 🎨 UI Components

### 1. **Profile Header**
```dart
_buildProfileHeader()
```
- Avatar dengan icon camera (siap untuk upload photo)
- Nama user
- Username (@email)
- Role badge dengan warna

### 2. **User Info Card**
```dart
_buildUserInfoCard()
```
- Card putih dengan shadow
- Informasi lengkap user
- Icons untuk setiap field
- Format tanggal dalam Bahasa Indonesia

### 3. **Loading States**
- **AppBar**: Mini loading indicator
- **Body**: Full screen CircularProgressIndicator
- **Pull-to-refresh**: RefreshIndicator

---

## 🔄 Pull to Refresh

User bisa refresh data dengan:
1. Swipe down dari top
2. Data akan di-fetch ulang dari Firebase
3. UI update otomatis

```dart
RefreshIndicator(
  onRefresh: _loadUserData,
  color: const Color(0xFFE07B4F),
  child: SingleChildScrollView(...)
)
```

---

## 📱 Testing

### Test dengan User yang Sudah Login:

1. **Login** dengan akun yang sudah terdaftar
2. **Buka Profile Page**
3. **Verify Data**:
   - ✅ Nama sesuai dengan data saat register
   - ✅ Email sesuai
   - ✅ Username generated dari email
   - ✅ Role sesuai (Parent/Anak)
   - ✅ Tanggal bergabung muncul (jika ada)

### Test Pull-to-Refresh:
1. Buka Profile Page
2. Swipe down dari top
3. ✅ Loading indicator muncul
4. ✅ Data ter-refresh

### Test Loading States:
1. Logout
2. Login lagi (fresh state)
3. Buka Profile Page
4. ✅ Muncul loading saat fetch data
5. ✅ Data muncul setelah loading selesai

---

## 🛠️ Error Handling

### Jika User Belum Login:
```dart
if (user == null) {
  // Show default data atau redirect ke login
}
```

### Jika Firestore Error:
```dart
try {
  final userData = await _authService.getUserData(user.uid);
} catch (e) {
  print('Error loading user data: $e');
  // Fallback ke Firebase Auth data
}
```

### Jika Data Tidak Lengkap:
```dart
// Fallback chain:
userData?['name'] ?? user.displayName ?? user.email.split('@')[0] ?? 'User'
```

---

## 📝 Code Structure

### State Management:
```dart
class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;  // Data dari Firestore
  bool _isLoading = true;           // Loading state
  
  // Getters untuk display data
  String get _displayName { ... }
  String get _displayEmail { ... }
  String get _displayUsername { ... }
  String get _displayRole { ... }
}
```

### Widget Organization:
```dart
build()
  └─ _buildProfileHeader()
  └─ _buildUserInfoCard()
  └─ _buildMenuGroup1()
  └─ _buildMenuGroup2()
  └─ _buildLogoutButton()
  
Helper Widgets:
  └─ _buildInfoRow()      // Info row di card
  └─ _buildMenuItem()     // Menu item
  └─ _formatDate()        // Format timestamp
```

---

## 🚀 Future Enhancements

Fitur yang bisa ditambahkan:

1. **Upload Photo Profile**
   ```dart
   onTap: () async {
     // Upload ke Firebase Storage
     // Update photoURL di Firestore
   }
   ```

2. **Edit Profile Inline**
   ```dart
   // Edit nama, bio, dll langsung dari profile page
   ```

3. **Real-time Updates**
   ```dart
   // Stream data dari Firestore
   // Auto update jika data berubah
   ```

4. **Cache Data**
   ```dart
   // Cache user data locally
   // Tampilkan cache saat offline
   ```

---

## 🎯 Benefits

### User Experience:
- ✅ Data personal dan akurat
- ✅ Loading feedback yang jelas
- ✅ Pull-to-refresh untuk update data
- ✅ Error handling yang baik

### Developer Experience:
- ✅ Clean code structure
- ✅ Reusable widgets
- ✅ Easy to maintain
- ✅ Type-safe dengan proper null checks

### Performance:
- ✅ Fetch data sekali di initState
- ✅ Cache data di state
- ✅ Efficient rebuild dengan setState
- ✅ Async/await untuk smooth UI

---

## 📚 Related Files

- **Profile Page**: `lib/pages/profile_page.dart`
- **Auth Service**: `lib/services/auth_service.dart`
- **User Role**: `lib/utils/user_role.dart`

---

**Profile Page sekarang fully integrated dengan Firebase! 🎉**

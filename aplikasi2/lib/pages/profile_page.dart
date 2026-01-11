import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ubah_profil_page.dart';
import 'login_page.dart';
import '../services/auth_service.dart';
import '../utils/user_role.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await _authService.getUserData(user.uid);
        if (mounted) {
          setState(() {
            _userData = userData;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String get _displayName {
    if (_userData != null && _userData!['name'] != null) {
      return _userData!['name'];
    }
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
  }

  String get _displayEmail {
    if (_userData != null && _userData!['email'] != null) {
      return _userData!['email'];
    }
    final user = FirebaseAuth.instance.currentUser;
    return user?.email ?? 'user@example.com';
  }

  String get _displayUsername {
    final email = _displayEmail;
    return '@${email.split('@')[0]}';
  }

  String get _displayRole {
    if (_userData != null && _userData!['role'] != null) {
      return _userData!['role'] == 'parent' ? 'Orang Tua' : 'Anak';
    }
    return UserRole.isParent() ? 'Orang Tua' : 'Anak';
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await _authService.signOut();
      UserRole.clear();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saat logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFE07B4F),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(height: 3, color: const Color(0xFFE07B4F)),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE07B4F)),
                  )
                : RefreshIndicator(
                    onRefresh: _loadUserData,
                    color: const Color(0xFFE07B4F),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildProfileHeader(),
                          const SizedBox(height: 24),
                          _buildUserInfoCard(),
                          const SizedBox(height: 40),
                          _buildMenuGroup1(),
                          const SizedBox(height: 20),
                          _buildMenuGroup2(),
                          const SizedBox(height: 20),
                          _buildLogoutButton(),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE07B4F),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _displayUsername,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE07B4F).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _displayRole,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFE07B4F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: _displayEmail,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Role',
            value: _displayRole,
          ),
          if (_userData?['createdAt'] != null) ...[
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Bergabung',
              value: _formatDate(_userData!['createdAt']),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuGroup1() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE07B4F), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.mail_outline,
            title: 'Ubah Profil Saya',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UbahProfilPage()),
              );
            },
          ),
          Divider(height: 1, color: Colors.grey[300]),
          _buildMenuItem(
            icon: Icons.email_outlined,
            title: 'Ubah Email',
            onTap: () {
              // Navigate to change email
            },
          ),
          Divider(height: 1, color: Colors.grey[300]),
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: 'Ubah Kata Sandi',
            onTap: () {
              // Navigate to change password
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGroup2() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE07B4F), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Pengaturan',
            onTap: () {
              // Navigate to settings
            },
          ),
          Divider(height: 1, color: Colors.grey[300]),
          _buildMenuItem(
            icon: Icons.headset_mic_outlined,
            title: 'Bantuan',
            onTap: () {
              // Navigate to help
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE07B4F), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _buildMenuItem(
        icon: Icons.logout,
        title: 'Keluar',
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Keluar'),
              content: const Text('Apakah Anda yakin ingin keluar?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleLogout(context);
                  },
                  child: const Text(
                    'Keluar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
        showDivider: false,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFE07B4F)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic timestamp) {
    try {
      if (timestamp == null) return '-';
      DateTime date;
      if (timestamp is DateTime) {
        date = timestamp;
      } else {
        date = timestamp.toDate();
      }
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return '-';
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.black87),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }
}

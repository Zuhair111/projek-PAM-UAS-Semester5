import 'package:flutter/material.dart';
import 'register_page.dart';

class IzinAplikasiScreen extends StatefulWidget {
  final String childName;

  const IzinAplikasiScreen({Key? key, required this.childName}) : super(key: key);

  @override
  State<IzinAplikasiScreen> createState() => _IzinAplikasiScreenState();
}

class _IzinAplikasiScreenState extends State<IzinAplikasiScreen> {
  final List<PermissionItem> permissions = [
    PermissionItem(
      title: 'Notifikasi',
      description: 'Lorem ipsum, dolor sit amet consectetur adipisicing elit.',
      isEnabled: false,
    ),
    PermissionItem(
      title: 'Lokasi',
      description: 'Lorem ipsum, dolor sit amet consectetur adipisicing elit.',
      isEnabled: false,
    ),
    PermissionItem(
      title: 'Panggilan Darurat',
      description: 'Lorem ipsum, dolor sit amet consectetur adipisicing elit.',
      isEnabled: false,
    ),
    PermissionItem(
      title: 'SOS',
      description: 'Lorem ipsum, dolor sit amet consectetur adipisicing elit.',
      isEnabled: false,
    ),
  ];

  void _togglePermission(int index) {
    setState(() {
      permissions[index].isEnabled = !permissions[index].isEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Izin Aplikasi',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Permission Cards List
              Expanded(
                child: ListView.builder(
                  itemCount: permissions.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: PermissionCard(
                        title: permissions[index].title,
                        description: permissions[index].description,
                        isEnabled: permissions[index].isEnabled,
                        onTap: () => _togglePermission(index),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Lanjut Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE07B4F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Lanjut',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Bottom text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'Belum ada kode? Minta '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('meminta kode ke orang tua..'),
                                backgroundColor: Color(0xFFE07B4F),
                              ),
                            );
                          },
                          child: const Text(
                            'orang tuamu',
                            style: TextStyle(
                              color: Color(0xFFE07B4F),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(text: ' untuk mengundang.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class PermissionItem {
  final String title;
  final String description;
  bool isEnabled;

  PermissionItem({
    required this.title,
    required this.description,
    required this.isEnabled,
  });
}

class PermissionCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isEnabled;
  final VoidCallback onTap;

  const PermissionCard({
    Key? key,
    required this.title,
    required this.description,
    required this.isEnabled,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE07B4F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isEnabled ? 'Aktif' : 'Aktifkan',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
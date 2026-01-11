import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample notification data
    final notifications = [
      {
        'title': 'Aurellia keluar dari zona aman',
        'time': '20.00 WIB',
        'avatar': 'A',
        'color': Colors.purple,
      },
      {
        'title': 'Aurellia mengaktifkan SOS',
        'time': '20.05 WIB',
        'avatar': 'A',
        'color': Colors.purple,
      },
    ];

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
          'Notifikasi',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Orange divider
          Container(
            height: 3,
            color: const Color(0xFFE07B4F),
          ),
          
          // Notification list
          Expanded(
            child: notifications.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada notifikasi',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey[300],
                      indent: 100,
                    ),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationItem(
                        avatar: notification['avatar'] as String,
                        color: notification['color'] as Color,
                        title: notification['title'] as String,
                        time: notification['time'] as String,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required String avatar,
    required Color color,
    required String title,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Text(
                avatar,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Notification text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

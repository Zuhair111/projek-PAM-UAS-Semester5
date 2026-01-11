import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class LihatStatistikPage extends StatelessWidget {
  final String userName;

  const LihatStatistikPage({
    Key? key,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Row 1: Zona aman & Sering dikunjungi
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Keluar dari',
                    subtitle: 'Zona aman',
                    icon: Icons.not_listed_location,
                    value: '2',
                    unit: 'kali',
                    color: const Color(0xFFE8B4A0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Sering dikunjungi',
                    subtitle: 'UTY',
                    icon: Icons.trending_up,
                    value: '28',
                    unit: 'kali',
                    color: const Color(0xFFE8B4A0),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Row 2: Peringatan Kesehatan & Kontak darurat
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Peringatan',
                    subtitle: 'Kesehatan',
                    icon: Icons.monitor_heart_outlined,
                    value: '1',
                    unit: 'kali',
                    color: const Color(0xFFE8B4A0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Kontak daruratt',
                    subtitle: 'Baru',
                    icon: Icons.person_add_alt_1,
                    value: '2',
                    unit: 'kali',
                    color: const Color(0xFFE8B4A0),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Row 3: Favorit & Timeline
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Baru',
                    subtitle: 'Favorit',
                    icon: Icons.favorite,
                    value: '7',
                    unit: 'tempat',
                    color: const Color(0xFFE8B4A0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Analisis',
                    subtitle: 'Timeline',
                    icon: Icons.trending_up,
                    value: 'TBA',
                    unit: '',
                    color: const Color(0xFFE8B4A0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          // Subtitle
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Icon
          Icon(
            icon,
            size: 50,
            color: const Color(0xFFE07B4F),
          ),
          const SizedBox(height: 20),
          // Value
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

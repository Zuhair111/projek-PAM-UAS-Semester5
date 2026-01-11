import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import 'scan_qr_smartwatch.dart';
import 'iot_direct_connect_page.dart';

class JamTanganPage extends StatelessWidget {
  const JamTanganPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // IoT Device Quick Access Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IoTDirectConnectPage(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.developer_board,
                          color: Colors.orange[700],
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Perangkat IoT',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lihat lokasi Arduino/ESP32',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Title
            const Text(
              'Sambungkan ke smartwatch',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Link to supported smartwatch list
            GestureDetector(
              onTap: () {
                // TODO: Navigate to supported smartwatch list page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menampilkan list smartwatch yang didukung'),
                    backgroundColor: Color(0xFFE07B4F),
                  ),
                );
              },
              child: const Text(
                'lihat list smartwatch yang didukung',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFE07B4F),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Family with smartwatch illustration
            Container(
              width: 300,
              height: 300,
              child: Image.asset(
                'assets/jam_tangan.png',
                width: 280,
                height: 280,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.watch,
                    size: 150,
                    color: Color(0xFFE07B4F),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 80),
            
            // Connect button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to scan QR page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScanQrSmartwatchPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE07B4F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Sambungkan Sekarang',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

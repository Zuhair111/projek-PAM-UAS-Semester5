import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'smartwatch_tersambung.dart';

class ScanQrSmartwatchPage extends StatefulWidget {
  const ScanQrSmartwatchPage({super.key});

  @override
  State<ScanQrSmartwatchPage> createState() => _ScanQrSmartwatchPageState();
}

class _ScanQrSmartwatchPageState extends State<ScanQrSmartwatchPage> {
  bool _showPermissionDialog = true;
  bool _isProcessing = false;
  MobileScannerController? _cameraController;
  String? _scannedCode;

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _handleDontAllow() {
    Navigator.pop(context);
  }

  void _handleAllow() {
    setState(() {
      _showPermissionDialog = false;
    });

    // Initialize camera controller
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  Future<void> _onQrScanned(String pairingCode) async {
    if (_isProcessing || _scannedCode == pairingCode) return;

    setState(() {
      _isProcessing = true;
      _scannedCode = pairingCode;
    });

    try {
      // Pause camera
      await _cameraController?.stop();

      // Get current logged-in user from smartphone
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Anda belum login. Silakan login terlebih dahulu.');
      }

      // Get current user's email
      final email = currentUser.email;
      if (email == null) {
        throw Exception('Email user tidak ditemukan');
      }

      // Get user's display name from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('family_members')
          .where('userId', isEqualTo: currentUser.uid)
          .limit(1)
          .get();

      String userName = 'User';
      if (userDoc.docs.isNotEmpty) {
        userName = userDoc.docs.first.data()['name'] ?? 'User';
      }

      // Ask for password confirmation for security
      if (!mounted) return;
      final password = await _showPasswordConfirmationDialog(userName);

      if (password == null || password.isEmpty) {
        // User cancelled
        setState(() => _isProcessing = false);
        await _cameraController?.start();
        return;
      }

      // Verify password is correct by attempting to reauthenticate
      try {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await currentUser.reauthenticateWithCredential(credential);
      } catch (e) {
        _showError('Password salah. Silakan coba lagi.');
        setState(() => _isProcessing = false);
        await _cameraController?.start();
        return;
      }

      // Send credentials to watch via Firestore
      await _sendCredentialsToWatch(pairingCode, email, password);

      // Navigate to success page
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SmartwatchTersambungPage(memberName: userName),
        ),
      );
    } catch (e) {
      _showError('Error: ${e.toString()}');
      setState(() => _isProcessing = false);
      await _cameraController?.start();
    }
  }

  Future<String?> _getUserFamilyId(String userId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('family_members')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (userDoc.docs.isEmpty) return null;
    return userDoc.docs.first.data()['familyId'] as String?;
  }

  Future<String?> _showPasswordConfirmationDialog(String userName) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smartwatch akan login dengan akun Anda:',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE07B4F),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Anda',
                hintText: 'Masukkan password untuk konfirmasi',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE07B4F),
            ),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendCredentialsToWatch(
    String pairingCode,
    String email,
    String password,
  ) async {
    try {
      // First check if pairing document exists
      final pairingDoc = await FirebaseFirestore.instance
          .collection('watch_pairing')
          .doc(pairingCode)
          .get();

      if (!pairingDoc.exists) {
        throw Exception('QR Code tidak valid atau sudah kadaluarsa');
      }

      final data = pairingDoc.data();
      if (data?['status'] != 'pending') {
        throw Exception('QR Code sudah digunakan atau tidak valid');
      }

      // Check if QR code has expired (5 minutes)
      final createdAt = data?['createdAt'] as Timestamp?;
      if (createdAt != null) {
        final expirationTime = createdAt.toDate().add(const Duration(minutes: 5));
        if (DateTime.now().isAfter(expirationTime)) {
          throw Exception('QR Code sudah kadaluarsa. Silakan minta smartwatch untuk generate QR code baru.');
        }
      }

      // Update with credentials
      await FirebaseFirestore.instance
          .collection('watch_pairing')
          .doc(pairingCode)
          .update({
            'status': 'completed',
            'email': email,
            'password': password,
            'timestamp': FieldValue.serverTimestamp(),
          });

      print('Credentials sent to smartwatch: $pairingCode');
      print('Email: $email');
    } catch (e) {
      print('Error sending credentials: $e');
      rethrow;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan QR Code di Smartwatch',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Orange divider
          Container(height: 3, color: const Color(0xFFE07B4F)),

          // Camera preview area
          Expanded(
            child: Stack(
              children: [
                // Camera scanner
                if (!_showPermissionDialog && _cameraController != null)
                  MobileScanner(
                    controller: _cameraController,
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        if (barcode.rawValue != null) {
                          _onQrScanned(barcode.rawValue!);
                          break;
                        }
                      }
                    },
                  )
                else
                  // Black placeholder
                  Container(
                    color: Colors.black,
                    width: double.infinity,
                    height: double.infinity,
                  ),

                // Scanning frame overlay
                if (!_showPermissionDialog)
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE07B4F),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          // Corner decorations
                          ...List.generate(4, (index) {
                            final isTop = index < 2;
                            final isLeft = index % 2 == 0;
                            return Positioned(
                              top: isTop ? 0 : null,
                              bottom: !isTop ? 0 : null,
                              left: isLeft ? 0 : null,
                              right: !isLeft ? 0 : null,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: isTop
                                        ? const BorderSide(
                                            color: Color(0xFFE07B4F),
                                            width: 5,
                                          )
                                        : BorderSide.none,
                                    bottom: !isTop
                                        ? const BorderSide(
                                            color: Color(0xFFE07B4F),
                                            width: 5,
                                          )
                                        : BorderSide.none,
                                    left: isLeft
                                        ? const BorderSide(
                                            color: Color(0xFFE07B4F),
                                            width: 5,
                                          )
                                        : BorderSide.none,
                                    right: !isLeft
                                        ? const BorderSide(
                                            color: Color(0xFFE07B4F),
                                            width: 5,
                                          )
                                        : BorderSide.none,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                // Instruction text
                if (!_showPermissionDialog && !_isProcessing)
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Arahkan kamera ke QR code\ndi layar smartwatch',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                // Processing indicator
                if (_isProcessing)
                  Container(
                    color: Colors.black.withOpacity(0.7),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFE07B4F),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Menyambungkan...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Permission dialog
                if (_showPermissionDialog)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '"Kiddo" sedang meminta\nakses kamera',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Scan QR Code di smartwatchmu untuk\npengalaman yang lebih seru',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: _handleDontAllow,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: const Text(
                                    'Jangan Izinkan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextButton(
                                  onPressed: _handleAllow,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: const Text(
                                    'Izinkan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF007AFF),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

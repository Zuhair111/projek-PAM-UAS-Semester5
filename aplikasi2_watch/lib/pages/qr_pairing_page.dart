import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'dart:async';
import '../services/auth_service.dart';

class QrPairingPage extends StatefulWidget {
  const QrPairingPage({Key? key}) : super(key: key);

  @override
  State<QrPairingPage> createState() => _QrPairingPageState();
}

class _QrPairingPageState extends State<QrPairingPage> {
  final _authService = AuthService();
  late String _pairingCode;
  bool _isWaiting = false;
  String _statusMessage = 'Scan QR dari HP';
  StreamSubscription<DocumentSnapshot>? _pairingSubscription;

  @override
  void initState() {
    super.initState();
    _pairingCode = _generatePairingCode();
    _initializePairingDocument();
    _listenForPairing();
  }

  String _generatePairingCode() {
    // Generate 6 digit random code
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // Initialize pairing document in Firestore
  Future<void> _initializePairingDocument() async {
    try {
      await _authService.createPairingDocument(_pairingCode);
      setState(() {
        _statusMessage = 'Scan QR dari HP';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.toString()}';
      });
    }
  }

  void _listenForPairing() {
    _pairingSubscription?.cancel(); // Cancel previous listener if any
    
    _pairingSubscription = _authService.listenForPairing(_pairingCode).listen((snapshot) async {
      if (snapshot.exists && mounted) {
        final data = snapshot.data() as Map<String, dynamic>;

        print('Pairing data received: $data');

        // Check if QR code has expired
        final createdAt = data['createdAt'] as Timestamp?;
        if (createdAt != null) {
          final expirationTime = createdAt.toDate().add(const Duration(minutes: 5));
          if (DateTime.now().isAfter(expirationTime)) {
            print('QR Code expired');
            setState(() {
              _statusMessage = 'QR Kadaluarsa';
              _isWaiting = false;
            });
            
            // Regenerate code
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _pairingCode = _generatePairingCode();
                  _statusMessage = 'Scan QR dari HP';
                });
                _initializePairingDocument();
              }
            });
            return;
          }
        }

        if (data['status'] == 'pending') {
          setState(() {
            _isWaiting = true;
            _statusMessage = 'Menunggu scan...';
          });
        } else if (data['status'] == 'completed') {
          setState(() {
            _statusMessage = 'Login...';
          });

          // Verify credentials exist
          final email = data['email'];
          final password = data['password'];

          if (email == null || password == null) {
            print('Error: Missing credentials in pairing data');
            setState(() {
              _statusMessage = 'Error: Kredensial tidak lengkap';
              _isWaiting = false;
            });
            return;
          }

          print('Attempting login with email: $email');

          try {
            // Auto login with credentials from smartphone
            final result = await _authService.signInWithEmailAndPassword(
              email,
              password,
            );

            if (result != null && result.user != null) {
              print('Login successful: ${result.user?.email}');
              
              setState(() {
                _statusMessage = 'Login berhasil!';
              });

              // Clean up pairing document
              await _authService.cleanupPairing(_pairingCode);

              // Wait a bit before navigation (StreamBuilder will handle the navigation)
              await Future.delayed(const Duration(milliseconds: 500));
              
              // Navigation will be handled automatically by StreamBuilder in main.dart
              print('Waiting for StreamBuilder to navigate...');
            } else {
              throw Exception('Login gagal: tidak ada user credential');
            }
          } catch (e) {
            print('Login error: $e');
            setState(() {
              _statusMessage = 'Login gagal: ${e.toString()}';
              _isWaiting = false;
            });

            // Regenerate code and try again
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _pairingCode = _generatePairingCode();
                  _statusMessage = 'Scan QR dari HP';
                });
                _initializePairingDocument();
              }
            });
          }
        }
      }
    }, onError: (error) {
      print('Listener error: $error');
      if (mounted) {
        setState(() {
          _statusMessage = 'Error: ${error.toString()}';
          _isWaiting = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Scan QR',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),

              // QR Code
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: QrImageView(
                  data: _pairingCode,
                  version: QrVersions.auto,
                  size: 100,
                  backgroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 4),

              // Pairing code text
              Text(
                _pairingCode,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 4),

              // Status message with loading
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isWaiting) ...[
                    const SizedBox(
                      height: 12,
                      width: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFE07B4F),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      _statusMessage,
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pairingSubscription?.cancel();
    super.dispose();
  }
}

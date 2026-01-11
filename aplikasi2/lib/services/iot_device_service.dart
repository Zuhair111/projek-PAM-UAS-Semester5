import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class IoTDevice {
  final double latitude;
  final double longitude;
  final String status;
  final double kecepatan;
  final DateTime lastUpdate;

  IoTDevice({
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.kecepatan,
    required this.lastUpdate,
  });

  factory IoTDevice.fromMap(Map<dynamic, dynamic> map) {
    return IoTDevice(
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      status: map['status']?.toString() ?? 'Unknown',
      kecepatan: (map['kecepatan'] ?? 0).toDouble(),
      lastUpdate: DateTime.now(),
    );
  }

  bool get isOnline => status.toLowerCase() == 'online';
}

class IoTDeviceService {
  final DatabaseReference _database;
  StreamSubscription<DatabaseEvent>? _deviceSubscription;
  final StreamController<IoTDevice?> _deviceController = StreamController<IoTDevice?>.broadcast();

  // Database path - bisa diubah sesuai kebutuhan
  final String devicePath;

  IoTDeviceService({
    String? databaseUrl,
    this.devicePath = 'Posisi',
  }) : _database = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: databaseUrl ?? 'https://aplikasi2-9ab49-default-rtdb.asia-southeast1.firebasedatabase.app',
        ).ref();

  /// Stream untuk mendapatkan update real-time dari perangkat IoT
  Stream<IoTDevice?> get deviceStream => _deviceController.stream;

  /// Mulai mendengarkan update dari perangkat IoT
  void startListening() {
    _deviceSubscription?.cancel();
    
    _deviceSubscription = _database.child(devicePath).onValue.listen(
      (DatabaseEvent event) {
        if (event.snapshot.value != null) {
          try {
            final data = event.snapshot.value as Map<dynamic, dynamic>;
            final device = IoTDevice.fromMap(data);
            _deviceController.add(device);
          } catch (e) {
            print('Error parsing device data: $e');
            _deviceController.addError(e);
          }
        } else {
          _deviceController.add(null);
        }
      },
      onError: (error) {
        print('Error listening to device: $error');
        _deviceController.addError(error);
      },
    );
  }

  /// Mendapatkan data perangkat satu kali (tidak real-time)
  Future<IoTDevice?> getDeviceOnce() async {
    try {
      final snapshot = await _database.child(devicePath).get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return IoTDevice.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error getting device data: $e');
      return null;
    }
  }

  /// Cek apakah koneksi ke database berhasil
  Future<bool> testConnection() async {
    try {
      final snapshot = await _database.child(devicePath).get();
      return true;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  /// Hentikan listening dan bersihkan resources
  void dispose() {
    _deviceSubscription?.cancel();
    _deviceController.close();
  }

  /// Update database URL (untuk koneksi ke database berbeda)
  static IoTDeviceService withCustomUrl(String databaseUrl, {String devicePath = 'Posisi'}) {
    return IoTDeviceService(
      databaseUrl: databaseUrl,
      devicePath: devicePath,
    );
  }
}

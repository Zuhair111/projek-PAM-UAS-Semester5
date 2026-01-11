import 'package:flutter/foundation.dart';

/// Konfigurasi untuk koneksi IoT Device
/// Edit file ini untuk menyesuaikan dengan setup Firebase Anda
class IoTConfig {
  /// URL Firebase Realtime Database Anda
  /// Format: https://nama-project-default-rtdb.region.firebasedatabase.app
  /// 
  /// Cara mendapatkan URL:
  /// 1. Buka Firebase Console (https://console.firebase.google.com)
  /// 2. Pilih project Anda
  /// 3. Klik "Realtime Database" di menu kiri
  /// 4. Copy URL yang terlihat di bagian atas (tanpa https://)
  static const String databaseUrl = 
      'https://aplikasi2-9ab49-default-rtdb.asia-southeast1.firebasedatabase.app';

  /// Path di Realtime Database tempat data IoT disimpan
  /// Default: 'Posisi'
  /// 
  /// Struktur data yang expected:
  /// {
  ///   "Posisi": {
  ///     "latitude": -7.752281333,
  ///     "longitude": 110.356881333,
  ///     "kecepatan": 0,
  ///     "status": "Online"
  ///   }
  /// }
  static const String devicePath = 'Posisi';

  /// Device ID jika menggunakan multiple devices
  /// Set ke null jika hanya 1 device
  static const String? deviceId = null;

  /// Full path dengan device ID (jika ada)
  static String get fullPath {
    if (deviceId != null) {
      return '$devicePath/$deviceId';
    }
    return devicePath;
  }

  /// Interval refresh data (dalam detik)
  /// Tidak digunakan karena real-time, tapi bisa untuk fallback
  static const int refreshIntervalSeconds = 5;

  /// Zoom level default untuk map
  static const double defaultZoomLevel = 16.0;

  /// Apakah enable auto-zoom saat device bergerak
  static const bool enableAutoZoom = true;

  /// Threshold jarak (dalam meter) untuk trigger auto-zoom
  /// Jika device bergerak lebih dari threshold ini, map akan auto-zoom
  static const double autoZoomThresholdMeters = 100.0;

  /// Marker colors
  static const String onlineMarkerColor = 'green';  // BitmapDescriptor.hueGreen
  static const String offlineMarkerColor = 'red';   // BitmapDescriptor.hueRed

  /// Status text mapping
  static const Map<String, String> statusText = {
    'Online': 'Terhubung',
    'Offline': 'Tidak Terhubung',
    'online': 'Terhubung',
    'offline': 'Tidak Terhubung',
  };

  /// Validasi data
  /// Koordinat valid range
  static const double minLatitude = -90.0;
  static const double maxLatitude = 90.0;
  static const double minLongitude = -180.0;
  static const double maxLongitude = 180.0;

  /// Cek apakah koordinat valid
  static bool isValidCoordinate(double lat, double lng) {
    return lat >= minLatitude && 
           lat <= maxLatitude && 
           lng >= minLongitude && 
           lng <= maxLongitude &&
           lat != 0.0 && 
           lng != 0.0;
  }

  /// Format kecepatan untuk display
  static String formatSpeed(double speed) {
    return '${speed.toStringAsFixed(1)} km/h';
  }

  /// Format koordinat untuk display
  static String formatCoordinate(double value, {int decimals = 6}) {
    return value.toStringAsFixed(decimals);
  }

  /// Debug mode - print logs
  static const bool debugMode = kDebugMode;

  /// Log message jika debug mode aktif
  static void log(String message) {
    if (debugMode) {
      debugPrint('[IoT Config] $message');
    }
  }

  /// Multiple devices configuration (untuk future enhancement)
  static const List<Map<String, String>> devices = [
    {
      'id': 'device1',
      'name': 'ESP32 #1',
      'path': 'Posisi',
    },
    // Tambahkan device lain di sini jika perlu
    // {
    //   'id': 'device2',
    //   'name': 'ESP8266 #1',
    //   'path': 'Posisi/Device2',
    // },
  ];

  /// Get device config by ID
  static Map<String, String>? getDeviceConfig(String deviceId) {
    try {
      return devices.firstWhere((device) => device['id'] == deviceId);
    } catch (e) {
      log('Device not found: $deviceId');
      return null;
    }
  }

  /// Firebase Rules suggestion
  static const String firebaseRulesSuggestion = '''
{
  "rules": {
    "Posisi": {
      ".read": true,
      ".write": true,
      ".validate": "newData.hasChildren(['latitude', 'longitude', 'status'])",
      "latitude": {
        ".validate": "newData.isNumber() && newData.val() >= -90 && newData.val() <= 90"
      },
      "longitude": {
        ".validate": "newData.isNumber() && newData.val() >= -180 && newData.val() <= 180"
      },
      "kecepatan": {
        ".validate": "newData.isNumber() && newData.val() >= 0"
      },
      "status": {
        ".validate": "newData.isString()"
      }
    }
  }
}
  ''';

  /// Print configuration info
  static void printConfig() {
    if (!debugMode) return;
    
    log('=== IoT Configuration ===');
    log('Database URL: $databaseUrl');
    log('Device Path: $devicePath');
    log('Full Path: $fullPath');
    log('Device ID: ${deviceId ?? "None (single device)"}');
    log('Zoom Level: $defaultZoomLevel');
    log('Auto-zoom: $enableAutoZoom');
    log('Registered Devices: ${devices.length}');
    log('========================');
  }
}

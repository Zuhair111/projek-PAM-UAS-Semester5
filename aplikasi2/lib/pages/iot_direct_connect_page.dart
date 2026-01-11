import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../services/iot_device_service.dart';
import '../utils/iot_config.dart';

/// Halaman untuk langsung menampilkan lokasi perangkat IoT dari Realtime Database
/// Tanpa perlu scan QR code terlebih dahulu
class IoTDirectConnectPage extends StatefulWidget {
  const IoTDirectConnectPage({Key? key}) : super(key: key);

  @override
  State<IoTDirectConnectPage> createState() => _IoTDirectConnectPageState();
}

class _IoTDirectConnectPageState extends State<IoTDirectConnectPage> {
  GoogleMapController? _mapController;
  late IoTDeviceService _iotService;
  IoTDevice? _currentDevice;
  bool _isLoading = true;
  String _errorMessage = '';
  StreamSubscription<IoTDevice?>? _deviceSubscription;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    IoTConfig.printConfig(); // Print config di debug mode
    _initializeService();
  }

  @override
  void dispose() {
    _deviceSubscription?.cancel();
    _iotService.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _initializeService() {
    // Inisialisasi service dengan URL database dari config
    _iotService = IoTDeviceService.withCustomUrl(
      IoTConfig.databaseUrl,
      devicePath: IoTConfig.fullPath,
    );

    // Mulai listening untuk update real-time
    _iotService.startListening();

    // Subscribe ke stream untuk mendapatkan update real-time
    _deviceSubscription = _iotService.deviceStream.listen(
      (device) {
        setState(() {
          _currentDevice = device;
          _isLoading = false;
          _errorMessage = '';
        });

        // Update marker dan pindahkan kamera
        if (device != null) {
          _updateMarker(device);
          _moveToDeviceLocation();
        }
      },
      onError: (error) {
        setState(() {
          _errorMessage = 'Error: $error';
          _isLoading = false;
        });
      },
    );

    // Test koneksi
    _testConnection();
  }

  Future<void> _testConnection() async {
    final isConnected = await _iotService.testConnection();
    if (!isConnected && mounted) {
      setState(() {
        _errorMessage = 'Gagal terhubung ke database';
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat terhubung ke Realtime Database'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateMarker(IoTDevice device) {
    // Validasi koordinat
    if (!IoTConfig.isValidCoordinate(device.latitude, device.longitude)) {
      IoTConfig.log('Invalid coordinates: ${device.latitude}, ${device.longitude}');
      return;
    }

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('iot_device'),
          position: LatLng(device.latitude, device.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            device.isOnline ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(
            title: 'Perangkat IoT',
            snippet: '${device.status} | ${IoTConfig.formatSpeed(device.kecepatan)}',
          ),
        ),
      };
    });
  }

  void _moveToDeviceLocation() {
    if (_currentDevice != null && _mapController != null && IoTConfig.enableAutoZoom) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_currentDevice!.latitude, _currentDevice!.longitude),
            zoom: IoTConfig.defaultZoomLevel,
          ),
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    return status.toLowerCase() == 'online' ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Perangkat IoT'),
        backgroundColor: const Color(0xFFE07B4F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _testConnection();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          if (!_isLoading && _currentDevice != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentDevice!.latitude, _currentDevice!.longitude),
                zoom: 16.0,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _moveToDeviceLocation();
              },
            ),

          // Loading indicator
          if (_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Menghubungkan ke perangkat...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

          // Error message
          if (_errorMessage.isNotEmpty && !_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = '';
                      });
                      _testConnection();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),

          // Info panel di bagian bawah
          if (_currentDevice != null && !_isLoading)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.developer_board,
                            color: Colors.orange[700],
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Info Perangkat IoT',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        Icons.location_on,
                        'Lokasi',
                        '${IoTConfig.formatCoordinate(_currentDevice!.latitude)}, ${IoTConfig.formatCoordinate(_currentDevice!.longitude)}',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.speed,
                        'Kecepatan',
                        IoTConfig.formatSpeed(_currentDevice!.kecepatan),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: _getStatusColor(_currentDevice!.status),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Status:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _currentDevice!.status,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(_currentDevice!.status),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Update: ${_formatTime(_currentDevice!.lastUpdate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Connection status indicator
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _currentDevice?.isOnline == true ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _currentDevice?.isOnline == true ? 'Terhubung' : 'Offline',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../services/iot_device_service.dart';
import '../widgets/custom_app_bar.dart';

class IoTDevicePage extends StatefulWidget {
  final String? databaseUrl;
  final String? devicePath;

  const IoTDevicePage({
    Key? key,
    this.databaseUrl,
    this.devicePath,
  }) : super(key: key);

  @override
  State<IoTDevicePage> createState() => _IoTDevicePageState();
}

class _IoTDevicePageState extends State<IoTDevicePage> {
  GoogleMapController? _mapController;
  late IoTDeviceService _iotService;
  IoTDevice? _currentDevice;
  bool _isLoading = true;
  String _errorMessage = '';
  StreamSubscription<IoTDevice?>? _deviceSubscription;

  @override
  void initState() {
    super.initState();
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
    // Inisialisasi service dengan URL custom jika ada
    if (widget.databaseUrl != null) {
      _iotService = IoTDeviceService.withCustomUrl(
        widget.databaseUrl!,
        devicePath: widget.devicePath ?? 'Posisi',
      );
    } else {
      _iotService = IoTDeviceService(
        devicePath: widget.devicePath ?? 'Posisi',
      );
    }

    // Mulai listening untuk update real-time
    _iotService.startListening();

    // Subscribe ke stream
    _deviceSubscription = _iotService.deviceStream.listen(
      (device) {
        setState(() {
          _currentDevice = device;
          _isLoading = false;
          _errorMessage = '';
        });

        // Pindahkan kamera ke lokasi perangkat saat pertama kali mendapat data
        if (device != null && _mapController != null) {
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
    }
  }

  void _moveToDeviceLocation() {
    if (_currentDevice != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_currentDevice!.latitude, _currentDevice!.longitude),
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  Set<Marker> _buildMarkers() {
    if (_currentDevice == null) return {};

    return {
      Marker(
        markerId: const MarkerId('iot_device'),
        position: LatLng(_currentDevice!.latitude, _currentDevice!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _currentDevice!.isOnline ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(
          title: 'Perangkat IoT',
          snippet: '${_currentDevice!.status} - ${_currentDevice!.kecepatan.toStringAsFixed(1)} km/h',
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          // Google Maps
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE07B4F)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Menghubungkan ke perangkat IoT...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            )
          else if (_errorMessage.isNotEmpty)
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
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = '';
                      });
                      _initializeService();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE07B4F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                if (_currentDevice != null) {
                  _moveToDeviceLocation();
                }
              },
              initialCameraPosition: CameraPosition(
                target: _currentDevice != null
                    ? LatLng(_currentDevice!.latitude, _currentDevice!.longitude)
                    : const LatLng(-7.7956, 110.3695),
                zoom: 14.5,
              ),
              markers: _buildMarkers(),
              zoomControlsEnabled: false,
              mapType: MapType.normal,
            ),

          // Info Panel
          if (_currentDevice != null && !_isLoading && _errorMessage.isEmpty)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.router,
                          color: _currentDevice!.isOnline ? Colors.green : Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Perangkat IoT',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _currentDevice!.isOnline
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _currentDevice!.status,
                            style: TextStyle(
                              color: _currentDevice!.isOnline ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      Icons.speed,
                      'Kecepatan',
                      '${_currentDevice!.kecepatan.toStringAsFixed(1)} km/h',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.location_on,
                      'Latitude',
                      _currentDevice!.latitude.toStringAsFixed(6),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.location_on,
                      'Longitude',
                      _currentDevice!.longitude.toStringAsFixed(6),
                    ),
                  ],
                ),
              ),
            ),

          // Center to Device Button
          if (_currentDevice != null && !_isLoading && _errorMessage.isEmpty)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: _moveToDeviceLocation,
                backgroundColor: const Color(0xFFE07B4F),
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

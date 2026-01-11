import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'family_page.dart';
import 'iot_device_page.dart';
import '../widgets/custom_app_bar.dart';

class LocationPage extends StatefulWidget {
  final bool isInMainNavigation;
  
  const LocationPage({
    Key? key,
    this.isInMainNavigation = false,
  }) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  int _selectedIndex = 0;
  GoogleMapController? _mapController;
  
  // Real-time location tracking
  LatLng? _currentLocation;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isLoadingLocation = true;
  String _locationError = '';
  
  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }
  
  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
  
  Future<void> _initializeLocation() async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Izin lokasi ditolak';
            _isLoadingLocation = false;
          });
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Izin lokasi ditolak permanen. Aktifkan di pengaturan.';
          _isLoadingLocation = false;
        });
        return;
      }
      
      // Get current position first
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
      
      // Move camera to current location
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentLocation!,
            zoom: 16.0,
          ),
        ),
      );
      
      // Start listening to location updates
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen((Position position) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      });
      
    } catch (e) {
      setState(() {
        _locationError = 'Error: $e';
        _isLoadingLocation = false;
      });
    }
  }

  Set<Marker> _buildMarkers() {
    if (_currentLocation == null) return {};
    
    return {
      Marker(
        markerId: const MarkerId('current_location'),
        position: _currentLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(
          title: 'Lokasi Anda',
          snippet: 'Real-time GPS',
        ),
      ),
    };
  }

  void _moveToUserLocation() {
    if (_currentLocation != null) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentLocation!,
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      return;
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FamilyPage(),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const IoTDevicePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          // Google Maps
          if (_isLoadingLocation)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE07B4F)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Mendapatkan lokasi Anda...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            )
          else if (_locationError.isNotEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _locationError,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isLoadingLocation = true;
                        _locationError = '';
                      });
                      _initializeLocation();
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
                if (_currentLocation != null) {
                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: _currentLocation!,
                        zoom: 16.0,
                      ),
                    ),
                  );
                }
              },
              initialCameraPosition: CameraPosition(
                target: _currentLocation ?? const LatLng(-7.7956, 110.3695),
                zoom: 14.5,
              ),
              markers: _buildMarkers(),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
            ),

          // Lokasiku button
          if (!_isLoadingLocation && _locationError.isEmpty)
            Positioned(
              bottom: 100,
              right: 20,
              child: GestureDetector(
                onTap: _moveToUserLocation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: const Color(0xFFE07B4F), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.my_location,
                        color: Color(0xFFE07B4F),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Lokasiku',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: widget.isInMainNavigation 
          ? null 
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: const Color(0xFFE07B4F),
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.location_on),
                  label: 'Lokasi',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Keluarga',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.router),
                  label: 'Perangkat IoT',
                ),
              ],
            ),
    );
  }
}

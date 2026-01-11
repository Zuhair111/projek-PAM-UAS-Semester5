import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'lihat_statistik.dart';
import 'family_page.dart';
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
  
  // Toggle switches state
  bool _zonaAmanEnabled = true;
  bool _peringatanKesehatanEnabled = true;
  bool _setDNDEnabled = false;
  bool _semuaNotifikasiEnabled = true;
  
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

  void _showDistanceView(UserLocation user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFFFFF8F0),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFF8F0),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Jarak anda ${user.distance}km dari ${user.name}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
              
              // Map view
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      (_userLocation.latitude + user.position.latitude) / 2,
                      (_userLocation.longitude + user.position.longitude) / 2,
                    ),
                    zoom: 13.0,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('user_location'),
                      position: _userLocation,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                      infoWindow: const InfoWindow(
                        title: 'Sandhika (Saya)',
                      ),
                    ),
                    Marker(
                      markerId: MarkerId(user.name),
                      position: user.position,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        user.color == Colors.blue ? BitmapDescriptor.hueBlue :
                        user.color == Colors.green ? BitmapDescriptor.hueGreen :
                        user.color == Colors.purple ? BitmapDescriptor.hueViolet :
                        BitmapDescriptor.hueRed,
                      ),
                      infoWindow: InfoWindow(
                        title: user.name,
                      ),
                    ),
                  },
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                ),
              ),
              
              // Bottom buttons
              Container(
                padding: const EdgeInsets.all(20),
                color: const Color(0xFFFFF8F0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to target
                        },
                        icon: const Icon(Icons.navigation, color: Colors.white),
                        label: const Text(
                          'Navigasi Aurellia',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE07B4F),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LihatStatistikPage(userName: user.name),
                            ),
                          );
                        },
                        icon: const Icon(Icons.bar_chart, color: Colors.white),
                        label: const Text(
                          'Lihat Statistik',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE07B4F),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserBottomSheet(UserLocation user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Action buttons section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Kirimi pesan button
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                'Kirimi pesan ...',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.phone,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Buka navigasi button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Buka navigasi',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(Icons.near_me, color: Colors.black87),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Lihat jarak button
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Close bottom sheet first
                          _showDistanceView(user);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Lihat jarak (${user.distance} km dari anda)',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Icon(Icons.swap_horiz, color: Colors.black87),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Riwayat lokasi button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Riwayat lokasi',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(Icons.history, color: Colors.black87),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Zona aman button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE07B4F), Color(0xFFD86942)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Zona aman untuk ${user.name}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.check_circle, color: Colors.white),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Peringatan Pintar section
                      const Text(
                        'Peringatan Pintar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Toggle switches
                      _buildToggleRow('Zona aman', _zonaAmanEnabled, (value) {
                        setModalState(() => _zonaAmanEnabled = value);
                      }),
                      const SizedBox(height: 12),
                      _buildToggleRow('Peringatan Kesehatan', _peringatanKesehatanEnabled, (value) {
                        setModalState(() => _peringatanKesehatanEnabled = value);
                      }),
                      const SizedBox(height: 12),
                      _buildToggleRow('Set DND', _setDNDEnabled, (value) {
                        setModalState(() => _setDNDEnabled = value);
                      }),
                      const SizedBox(height: 12),
                      _buildToggleRow('Semua Notifikasi', _semuaNotifikasiEnabled, (value) {
                        setModalState(() => _semuaNotifikasiEnabled = value);
                      }),
                      
                      const SizedBox(height: 30),
                      
                      // Bottom buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE07B4F), width: 2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.bookmark_border, color: Color(0xFFE07B4F)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Tandai Tempat',
                                    style: TextStyle(
                                      color: Color(0xFFE07B4F),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LihatStatistikPage(userName: user.name),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE07B4F),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.bar_chart, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Lihat Statistik',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggleRow(String title, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: Colors.black87,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey[300],
        ),
      ],
    );
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      // Sudah di halaman lokasi, tidak perlu navigasi
      return;
    } else if (index == 1) {
      // Navigasi ke halaman keluarga
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FamilyPage()),
      );
    } else if (index == 2) {
      // Navigasi ke halaman jam tangan (belum dibuat)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Halaman Jam Tangan belum tersedia')),
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
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 14.5,
            ),
            markers: _buildMarkers(),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
          ),

          // Lokasiku button
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
                      Icons.home,
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
                  icon: Icon(Icons.schedule),
                  label: 'Jam Tangan',
                ),
              ],
            ),
    );
  }
}

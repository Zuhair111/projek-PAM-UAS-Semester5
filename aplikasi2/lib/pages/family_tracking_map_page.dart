import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/family_tracking_service.dart';

class FamilyTrackingMapPage extends StatefulWidget {
  const FamilyTrackingMapPage({super.key});

  @override
  State<FamilyTrackingMapPage> createState() => _FamilyTrackingMapPageState();
}

class _FamilyTrackingMapPageState extends State<FamilyTrackingMapPage> {
  final FamilyTrackingService _trackingService = FamilyTrackingService();
  GoogleMapController? _mapController;
  String? _familyId;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  
  // Default camera position (Jakarta)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-6.2088, 106.8456),
    zoom: 12,
  );
  
  @override
  void initState() {
    super.initState();
    _loadFamily();
  }
  
  Future<void> _loadFamily() async {
    final family = await _trackingService.getUserFamily();
    if (family != null && family.exists) {
      setState(() {
        _familyId = family.id;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      _showNoFamilyDialog();
    }
  }
  
  void _showNoFamilyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Belum Ada Keluarga'),
        content: const Text(
          'Anda belum terdaftar dalam keluarga. Silakan buat keluarga baru atau join dengan kode undangan.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showCreateFamilyDialog();
            },
            child: const Text('Buat Keluarga'),
          ),
        ],
      ),
    );
  }
  
  void _showCreateFamilyDialog() {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Keluarga Baru'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nama Keluarga',
            hintText: 'Contoh: Keluarga Budi',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama keluarga harus diisi')),
                );
                return;
              }
              
              Navigator.pop(context);
              
              try {
                final familyId = await _trackingService.createFamily(
                  nameController.text.trim(),
                );
                
                setState(() {
                  _familyId = familyId;
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Keluarga berhasil dibuat!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Buat'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pelacakan Keluarga')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_familyId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pelacakan Keluarga')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.family_restroom, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Belum ada keluarga',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showCreateFamilyDialog,
                icon: const Icon(Icons.add),
                label: const Text('Buat Keluarga'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Anggota Keluarga'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
            tooltip: 'Pengaturan',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _trackingService.getFamilyMembersWithSmartwatchStream(_familyId!),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final members = snapshot.data!.docs;
          
          if (members.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.watch_off, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada anggota dengan smartwatch',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          _updateMarkers(members);
          
          return Column(
            children: [
              // Map View
              Expanded(
                flex: 2,
                child: GoogleMap(
                  initialCameraPosition: _initialPosition,
                  markers: _markers,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _fitMapToMarkers();
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapType: MapType.normal,
                ),
              ),
              
              // Members List
              Expanded(
                child: _buildMembersList(members),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _updateMarkers(List<QueryDocumentSnapshot> members) {
    _markers.clear();
    
    for (var member in members) {
      final data = member.data() as Map<String, dynamic>;
      final location = data['currentLocation'];
      
      if (location != null && location['latitude'] != null) {
        final isOnline = data['isOnline'] ?? false;
        final name = data['name'] ?? 'Unknown';
        final role = data['role'] ?? 'anak';
        
        _markers.add(
          Marker(
            markerId: MarkerId(member.id),
            position: LatLng(
              location['latitude'],
              location['longitude'],
            ),
            infoWindow: InfoWindow(
              title: name,
              snippet: isOnline 
                ? 'Online • ${_formatTimestamp(location['timestamp'])}'
                : 'Offline • ${_formatTimestamp(data['lastSeen'])}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isOnline
                ? (role == 'orang_tua' ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueGreen)
                : BitmapDescriptor.hueRed
            ),
            alpha: isOnline ? 1.0 : 0.5,
          ),
        );
      }
    }
  }
  
  void _fitMapToMarkers() {
    if (_markers.isEmpty || _mapController == null) return;
    
    double minLat = _markers.first.position.latitude;
    double maxLat = _markers.first.position.latitude;
    double minLng = _markers.first.position.longitude;
    double maxLng = _markers.first.position.longitude;
    
    for (var marker in _markers) {
      if (marker.position.latitude < minLat) minLat = marker.position.latitude;
      if (marker.position.latitude > maxLat) maxLat = marker.position.latitude;
      if (marker.position.longitude < minLng) minLng = marker.position.longitude;
      if (marker.position.longitude > maxLng) maxLng = marker.position.longitude;
    }
    
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50, // padding
      ),
    );
  }
  
  Widget _buildMembersList(List<QueryDocumentSnapshot> members) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Anggota Keluarga (${members.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: members.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final data = members[index].data() as Map<String, dynamic>;
                final location = data['currentLocation'];
                final isOnline = data['isOnline'] ?? false;
                final battery = data['batteryLevel'] ?? 0;
                final name = data['name'] ?? 'Unknown';
                
                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: isOnline ? Colors.green : Colors.grey,
                        child: const Icon(Icons.watch, color: Colors.white),
                      ),
                      if (isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (location != null && location['address'] != null)
                        Text(
                          location['address'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        const Text('Lokasi tidak tersedia'),
                      const SizedBox(height: 4),
                      Text(
                        isOnline 
                          ? 'Online • ${_formatTimestamp(data['lastSeen'])}'
                          : 'Offline • ${_formatTimestamp(data['lastSeen'])}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOnline ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.battery_full,
                        color: _getBatteryColor(battery),
                        size: 24,
                      ),
                      Text(
                        '$battery%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    if (location != null && location['latitude'] != null) {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(location['latitude'], location['longitude']),
                          16,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Tidak diketahui';
    
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else {
      return 'Invalid';
    }
    
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return DateFormat('dd MMM, HH:mm').format(date);
  }
  
  Color _getBatteryColor(int level) {
    if (level > 50) return Colors.green;
    if (level > 20) return Colors.orange;
    return Colors.red;
  }
  
  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pengaturan'),
        content: const Text('Coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

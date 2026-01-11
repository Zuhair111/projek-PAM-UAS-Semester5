import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../utils/user_role.dart';
import 'tambah_anggota_page.dart';
import '../widgets/custom_app_bar.dart';
import '../services/family_tracking_service.dart';

class FamilyPage extends StatefulWidget {
  final bool isInMainNavigation;
  
  const FamilyPage({
    Key? key,
    this.isInMainNavigation = false,
  }) : super(key: key);

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  final FamilyTrackingService _trackingService = FamilyTrackingService();
  int _selectedIndex = 1; // Set to 1 karena ini halaman Keluarga
  String? _familyId;
  bool _isLoadingFamily = true;
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  bool _showMap = false;

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
        _isLoadingFamily = false;
      });
    } else {
      setState(() {
        _isLoadingFamily = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      // Kembali ke halaman lokasi
      Navigator.pop(context);
    } else if (index == 1) {
      // Sudah di halaman keluarga, tidak perlu navigasi
      return;
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
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          // Tab untuk switch antara List dan Map
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _showMap = false),
                    icon: Icon(Icons.list, size: 18),
                    label: const Text('Daftar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_showMap ? const Color(0xFFE07B4F) : Colors.grey[300],
                      foregroundColor: !_showMap ? Colors.white : Colors.black87,
                      elevation: !_showMap ? 2 : 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _showMap = true),
                    icon: Icon(Icons.map, size: 18),
                    label: const Text('Peta Lokasi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showMap ? const Color(0xFFE07B4F) : Colors.grey[300],
                      foregroundColor: _showMap ? Colors.white : Colors.black87,
                      elevation: _showMap ? 2 : 0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _showMap ? _buildMapView() : _buildListView(),
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

  // Build List View (existing family list)
  Widget _buildListView() {
    if (_isLoadingFamily) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_familyId == null) {
      return _buildNoFamilyView();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _trackingService.getFamilyMembersStream(_familyId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final members = snapshot.data!.docs;

        if (members.isEmpty) {
          return _buildNoMembersView();
        }

        return Column(
          children: [
            // Family members list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final data = members[index].data() as Map<String, dynamic>;
                  return _buildFamilyMemberCard(data);
                },
              ),
            ),

            // Atur anggota keluarga section
            _buildFamilyManagementSection(members),
          ],
        );
      },
    );
  }

  // Build Map View
  Widget _buildMapView() {
    if (_isLoadingFamily) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_familyId == null) {
      return _buildNoFamilyView();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _trackingService.getFamilyMembersWithSmartwatchStream(_familyId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
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
                SizedBox(height: 8),
                Text(
                  'Aktifkan tracking di smartwatch untuk melihat lokasi',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        _updateMarkers(members);

        return GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(-6.2088, 106.8456),
            zoom: 12,
          ),
          markers: _markers,
          onMapCreated: (controller) {
            _mapController = controller;
            _fitMapToMarkers();
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          mapType: MapType.normal,
        );
      },
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
        50,
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

  Widget _buildNoFamilyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.family_restroom, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Belum ada keluarga',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Buat keluarga untuk mulai melacak anggota',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateFamilyDialog,
            icon: const Icon(Icons.add),
            label: const Text('Buat Keluarga'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE07B4F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMembersView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_add, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Belum ada anggota keluarga',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TambahAnggotaPage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Anggota'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE07B4F),
              foregroundColor: Colors.white,
            ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE07B4F),
            ),
            child: const Text('Buat'),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMemberCard(Map<String, dynamic> data) {
    final name = data['name'] ?? 'Unknown';
    final email = data['email'] ?? '';
    final role = data['role'] ?? 'anak';
    final location = data['currentLocation'];
    final isOnline = data['isOnline'] ?? false;
    final battery = data['batteryLevel'] ?? 0;
    final hasSmartwatch = data['hasSmartwatch'] ?? false;

    // Generate avatar color based on name
    final colors = [Colors.purple, Colors.blue, Colors.pink, Colors.orange, Colors.teal];
    final colorIndex = name.hashCode % colors.length;
    final color = colors[colorIndex.abs()];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.2),
                child: Text(
                  name[0].toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              if (hasSmartwatch)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.watch,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: role == 'orang_tua' ? Colors.blue.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        role == 'orang_tua' ? 'Ortu' : 'Anak',
                        style: TextStyle(
                          fontSize: 10,
                          color: role == 'orang_tua' ? Colors.blue : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (location != null && location['address'] != null)
                  Text(
                    location['address'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (hasSmartwatch && location != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      isOnline 
                        ? 'Online • ${_formatTimestamp(data['lastSeen'])}'
                        : 'Offline • ${_formatTimestamp(data['lastSeen'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOnline ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (hasSmartwatch)
            Column(
              children: [
                Icon(
                  Icons.battery_full,
                  color: _getBatteryColor(battery),
                  size: 24,
                ),
                Text(
                  '$battery%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Color _getBatteryColor(int level) {
    if (level > 50) return Colors.green;
    if (level > 20) return Colors.orange;
    return Colors.red;
  }

  Widget _buildFamilyManagementSection(List<QueryDocumentSnapshot> members) {
    // Pisahkan anak dan ortu
    final children = members.where((m) {
      final data = m.data() as Map<String, dynamic>;
      return data['role'] == 'anak';
    }).toList();

    final parents = members.where((m) {
      final data = m.data() as Map<String, dynamic>;
      return data['role'] == 'orang_tua';
    }).toList();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Atur anggota keluarga anda',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<String?>(
                valueListenable: UserRole.roleNotifier,
                builder: (context, role, child) {
                  if (role == 'parent') {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TambahAnggotaPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE07B4F),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          if (children.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Anak',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: children.map((member) {
                final data = member.data() as Map<String, dynamic>;
                return _buildFamilyTag(data['name'] ?? 'Unknown');
              }).toList(),
            ),
          ],
          if (parents.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Ortu / Wali',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: parents.map((member) {
                final data = member.data() as Map<String, dynamic>;
                return _buildFamilyTag(data['name'] ?? 'Unknown');
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFamilyTag(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE07B4F),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.close,
            color: Colors.white,
            size: 18,
          ),
        ],
      ),
    );
  }
}


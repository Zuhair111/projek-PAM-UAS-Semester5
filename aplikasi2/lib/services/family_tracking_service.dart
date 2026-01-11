import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class FamilyTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===== GET USER'S FAMILY =====
  Future<DocumentSnapshot?> getUserFamily() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    try {
      // Get user's family member document
      final memberDoc = await _firestore
          .collection('family_members')
          .doc(userId)
          .get();

      if (!memberDoc.exists) return null;

      final familyId = memberDoc.data()?['familyId'];
      if (familyId == null) return null;

      // Get family document
      return await _firestore.collection('families').doc(familyId).get();
    } catch (e) {
      print('Error getting user family: $e');
      return null;
    }
  }

  // ===== STREAM SEMUA ANGGOTA KELUARGA DENGAN LOKASI REAL-TIME =====
  Stream<QuerySnapshot> getFamilyMembersStream(String familyId) {
    return _firestore
        .collection('family_members')
        .where('familyId', isEqualTo: familyId)
        .snapshots();
  }

  // ===== STREAM HANYA ANGGOTA DENGAN SMARTWATCH =====
  Stream<QuerySnapshot> getFamilyMembersWithSmartwatchStream(String familyId) {
    return _firestore
        .collection('family_members')
        .where('familyId', isEqualTo: familyId)
        .where('hasSmartwatch', isEqualTo: true)
        .snapshots();
  }

  // ===== UPDATE LOKASI USER (Dipanggil dari smartwatch) =====
  Future<void> updateUserLocation(Position position) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    // Get address from coordinates (reverse geocoding)
    String? address;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address = '${place.street}, ${place.locality}';
      }
    } catch (e) {
      print('Address lookup failed: $e');
      // Continue without address
    }

    // Update current location
    await _firestore.collection('family_members').doc(userId).update({
      'currentLocation': {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': FieldValue.serverTimestamp(),
        'address': address,
      },
      'lastSeen': FieldValue.serverTimestamp(),
      'isOnline': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Add to location history
    await _addToLocationHistory(userId, position);
  }

  // ===== ADD TO LOCATION HISTORY =====
  Future<void> _addToLocationHistory(String userId, Position position) async {
    try {
      // Get current history
      final doc = await _firestore.collection('family_members').doc(userId).get();
      List<dynamic> history = List.from(doc.data()?['locationHistory'] ?? []);

      // Add new location
      history.add({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': Timestamp.now(),
      });

      // Keep only last 50 locations
      if (history.length > 50) {
        history = history.sublist(history.length - 50);
      }

      // Update Firestore
      await _firestore.collection('family_members').doc(userId).update({
        'locationHistory': history,
      });
    } catch (e) {
      print('Error adding to location history: $e');
    }
  }

  // ===== GET CURRENT LOCATION DARI GPS =====
  Future<Position?> getCurrentLocation() async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      // Get location with high accuracy
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  // ===== CALCULATE DISTANCE BETWEEN TWO POINTS =====
  double calculateDistance(
    double lat1, double lon1, 
    double lat2, double lon2
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // ===== UPDATE BATTERY LEVEL (Dipanggil dari smartwatch) =====
  Future<void> updateBatteryLevel(int batteryLevel) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('family_members').doc(userId).update({
      'batteryLevel': batteryLevel,
      'lastSeen': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ===== SET TRACKING STATUS (On/Off) =====
  Future<void> setTrackingStatus(bool isOnline) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('family_members').doc(userId).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  // ===== CREATE OR JOIN FAMILY =====
  Future<String> createFamily(String familyName) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    // Generate invite code
    final inviteCode = _generateInviteCode();

    // Create family
    final familyRef = await _firestore.collection('families').add({
      'familyName': familyName,
      'createdBy': userId,
      'members': [userId],
      'createdAt': FieldValue.serverTimestamp(),
      'inviteCode': inviteCode,
    });

    // Update user's family member document
    await _firestore.collection('family_members').doc(userId).set({
      'userId': userId,
      'familyId': familyRef.id,
      'name': _auth.currentUser?.displayName ?? 'Orang Tua',
      'role': 'orang_tua',
      'email': _auth.currentUser?.email,
      'hasSmartwatch': false,
      'joinedAt': FieldValue.serverTimestamp(),
    });

    return familyRef.id;
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => 
      chars[(DateTime.now().millisecondsSinceEpoch + index) % chars.length]
    ).join();
  }

  // ===== CHECK IF USER HAS FAMILY =====
  Future<bool> userHasFamily() async {
    final family = await getUserFamily();
    return family != null && family.exists;
  }

  // ===== JOIN FAMILY WITH CODE =====
  Future<bool> joinFamilyWithCode(String inviteCode) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      // Find family with invite code
      final querySnapshot = await _firestore
          .collection('families')
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return false;
      }

      final familyDoc = querySnapshot.docs.first;
      final familyId = familyDoc.id;

      // Add user to family members
      await _firestore.collection('families').doc(familyId).update({
        'members': FieldValue.arrayUnion([userId]),
      });

      // Create family member document
      await _firestore.collection('family_members').doc(userId).set({
        'userId': userId,
        'familyId': familyId,
        'name': _auth.currentUser?.displayName ?? 'Member',
        'role': 'anak',
        'email': _auth.currentUser?.email,
        'hasSmartwatch': false,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error joining family: $e');
      return false;
    }
  }
}

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<Position>? _positionStream;
  bool _isTracking = false;

  bool get isTracking => _isTracking;

  Future<bool> checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission == LocationPermission.whileInUse ||
           permission == LocationPermission.always;
  }

  Future<void> startTracking() async {
    if (_isTracking) return;
    
    final hasPermission = await checkPermissions();
    if (!hasPermission) {
      throw Exception('Location permission denied');
    }

    _isTracking = true;

    // Get initial position
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _updateLocationInFirestore(position);
    } catch (e) {
      print('Error getting initial position: $e');
    }

    // Start listening to position updates
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen(
      (Position position) async {
        await _updateLocationInFirestore(position);
      },
      onError: (error) {
        print('Location stream error: $error');
        // Continue tracking despite errors
      },
      cancelOnError: false, // Don't cancel stream on errors
    );
  }

  Future<void> _updateLocationInFirestore(Position position) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Get user's family_member document
      final memberQuery = await _firestore
          .collection('family_members')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (memberQuery.docs.isEmpty) {
        print('User is not a family member');
        return;
      }

      final memberDoc = memberQuery.docs.first;
      
      // Update location
      await memberDoc.reference.update({
        'currentLocation': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'lastSeen': FieldValue.serverTimestamp(),
        'isOnline': true,
        'hasSmartwatch': true,
      });

      // Add to location history
      await memberDoc.reference.collection('location_history').add({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Location updated: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  Future<void> stopTracking() async {
    if (!_isTracking) return;
    
    await _positionStream?.cancel();
    _positionStream = null;
    _isTracking = false;

    // Mark as offline
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        final memberQuery = await _firestore
            .collection('family_members')
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();

        if (memberQuery.docs.isNotEmpty) {
          await memberQuery.docs.first.reference.update({
            'isOnline': false,
            'lastSeen': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        print('Error marking offline: $e');
      }
    }
  }

  void dispose() {
    stopTracking();
  }
}

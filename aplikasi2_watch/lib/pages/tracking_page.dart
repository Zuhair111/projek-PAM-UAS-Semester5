import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/auth_service.dart';
import 'package:geolocator/geolocator.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({Key? key}) : super(key: key);

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final _locationService = LocationService();
  final _authService = AuthService();
  Position? _lastPosition;
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  Future<void> _startTracking() async {
    try {
      await _locationService.startTracking();
      setState(() => _isTracking = true);
      
      // Listen to position updates for UI
      Geolocator.getPositionStream().listen((position) {
        setState(() => _lastPosition = position);
      });
    } catch (e) {
      _showError('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isTracking ? Icons.location_on : Icons.location_off,
                size: 36,
                color: _isTracking ? Colors.green : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                _isTracking ? 'Tracking Aktif' : 'Tracking Mati',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  if (_isTracking) {
                    await _locationService.stopTracking();
                    setState(() => _isTracking = false);
                  } else {
                    await _startTracking();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTracking ? Colors.red : Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                  minimumSize: Size.zero,
                ),
                child: Text(_isTracking ? 'Stop' : 'Start', style: const TextStyle(fontSize: 14)),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  await _locationService.stopTracking();
                  await _authService.signOut();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Logout', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }
}

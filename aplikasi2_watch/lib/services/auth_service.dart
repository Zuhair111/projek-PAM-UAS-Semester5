import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Create initial pairing document
  Future<void> createPairingDocument(String pairingCode) async {
    try {
      await _firestore.collection('watch_pairing').doc(pairingCode).set({
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Pairing document created: $pairingCode');
    } catch (e) {
      print('Error creating pairing document: $e');
      rethrow;
    }
  }

  // Listen for pairing credentials from smartphone
  Stream<DocumentSnapshot> listenForPairing(String pairingCode) {
    return _firestore.collection('watch_pairing').doc(pairingCode).snapshots();
  }

  // Clean up pairing document after successful login
  Future<void> cleanupPairing(String pairingCode) async {
    try {
      await _firestore.collection('watch_pairing').doc(pairingCode).delete();
      print('Pairing document cleaned up: $pairingCode');
    } catch (e) {
      print('Error cleaning up pairing: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/qr_pairing_page.dart';
import 'pages/tracking_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Tracker Watch',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFFE07B4F),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFE07B4F),
        ),
      ),
      home: StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          print('Auth state changed: ${snapshot.connectionState}, hasData: ${snapshot.hasData}, data: ${snapshot.data}');
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.hasData && snapshot.data != null) {
            print('User logged in: ${snapshot.data?.email}');
            return const TrackingPage();
          }
          
          print('User not logged in, showing QR pairing page');
          return const QrPairingPage();
        },
      ),
    );
  }
}

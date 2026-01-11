import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/splash_screen.dart';
import '../pages/main_navigation_page.dart';

/// Widget untuk mengecek status autentikasi user
/// Jika user sudah login, langsung ke MainNavigationPage
/// Jika belum login, ke SplashScreen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFFFF8F0),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFE07B4F)),
            ),
          );
        }

        // User is logged in
        if (snapshot.hasData) {
          return const MainNavigationPage();
        }

        // User is not logged in
        return const SplashScreen();
      },
    );
  }
}

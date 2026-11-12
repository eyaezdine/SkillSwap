import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skillswap/features/auth/data/auth_service.dart';
import 'package:skillswap/features/auth/presentation/login_screen.dart';
import 'package:skillswap/features/home/presentation/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key, required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          return const HomeScreen();
        }
        return LoginScreen(authService: authService);
      },
    );
  }
}

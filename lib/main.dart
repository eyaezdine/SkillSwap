import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/app_theme.dart';
import 'package:skillswap/features/auth/data/auth_service.dart';
import 'package:skillswap/features/auth/presentation/auth_wrapper.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const SkillSwapApp());
}

class SkillSwapApp extends StatelessWidget {
  const SkillSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return MaterialApp(
      title: 'SkillSwap',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: AuthWrapper(authService: authService),
    );
  }
}

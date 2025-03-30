import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:walkwise/screens/auth/auth_home.dart';
import 'package:walkwise/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    // First load environment variables
    await dotenv.load();

    // Then initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(const MyApp());
  } catch (e) {
    // ignore: avoid_print
    print('Initialization error: $e');
    // Still run the app even if there's an initialization error
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WalkWise',
      theme: AppTheme.lightTheme,
      home: const AuthHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

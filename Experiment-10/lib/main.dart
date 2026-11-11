import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/user_profile.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isFirebaseInitialized = false;
  String? initError;

  // Initialize Firebase using existing configuration if configured
  if (DefaultFirebaseOptions.isConfigured) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      isFirebaseInitialized = true;
    } catch (e) {
      initError = e.toString();
    }
  }

  runApp(AuthApp(
    isFirebaseInitialized: isFirebaseInitialized,
    initError: initError,
  ));
}

/// Root Application Widget for Experiment 10
class AuthApp extends StatelessWidget {
  final bool isFirebaseInitialized;
  final String? initError;
  final AuthService? authService;
  final UserProfile? initialUser;

  const AuthApp({
    super.key,
    required this.isFirebaseInitialized,
    this.initError,
    this.authService,
    this.initialUser,
  });

  @override
  Widget build(BuildContext context) {
    final activeAuthService = authService ??
        AuthService(
          isFirebaseAvailable: isFirebaseInitialized,
        );

    return MaterialApp(
      title: 'Firebase User Authentication',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          primary: const Color(0xFF1976D2),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
        ),
      ),
      home: initialUser != null
          ? DashboardScreen(
              userProfile: initialUser,
              authService: activeAuthService,
              isFirebaseInitialized: isFirebaseInitialized,
            )
          : LoginScreen(
              authService: activeAuthService,
              isFirebaseInitialized: isFirebaseInitialized,
              initError: initError,
            ),
    );
  }
}

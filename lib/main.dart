import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'otp_verification.dart';
import 'driver_home_screen.dart';

void main() {
  runApp(const BONUSBUSApp());
}

class BONUSBUSApp extends StatelessWidget {
  const BONUSBUSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BONUS BUS - Driver App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/otp': (context) => const OTPVerificationScreen(
              phoneNumber: '',
       ), // This will be overridden by onGenerateRoute),
        '/home': (context) => const DriverHomeScreen(),
      },
      // Add this to handle passing phone number to OTP screen
      onGenerateRoute: (settings) {
        if (settings.name == '/otp') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              phoneNumber: args?['phoneNumber'] ?? '',
            ),
          );
        }
        return null;
      },
    );
  }
}
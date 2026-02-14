import 'package:driver_app/otp_verification.dart';
import 'package:flutter/material.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _useGreenTheme = false; // Toggle between blue and green themes

  void _sendOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Simulate API call to send OTP
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() => _isLoading = false);
      
      // Navigate to OTP verification
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationScreen(
            phoneNumber: _phoneController.text,
          ),
        ),
      );
    }
  }

  void _toggleTheme() {
    setState(() {
      _useGreenTheme = !_useGreenTheme;
    });
  }

  // Blue theme colors
  final Color _bluePrimary = const Color(0xFF0A2472);
  final Color _blueSecondary = const Color(0xFF4263EB);
  final Color _blueLight = const Color(0xFF6C8DFF);
  final Color _blueAccent = const Color(0xFF2196F3);

  // Green theme colors
  final Color _greenPrimary = const Color(0xFF1B5E20);
  final Color _greenSecondary = const Color(0xFF4CAF50);
  final Color _greenLight = const Color(0xFF81C784);
  final Color _greenAccent = const Color(0xFF00E676);

  @override
  Widget build(BuildContext context) {
    final primaryColor = _useGreenTheme ? _greenPrimary : _bluePrimary;
    final secondaryColor = _useGreenTheme ? _greenSecondary : _blueSecondary;
    final lightColor = _useGreenTheme ? _greenLight : _blueLight;
    final accentColor = _useGreenTheme ? _greenAccent : _blueAccent;
    final oppositeColor = _useGreenTheme ? _bluePrimary : _greenPrimary;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor,
              secondaryColor,
              lightColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button and theme toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      IconButton(
                        icon: Icon(
                          _useGreenTheme ? Icons.grass : Icons.water,
                          color: Colors.white,
                        ),
                        onPressed: _toggleTheme,
                        tooltip: _useGreenTheme ? 'Switch to Blue Theme' : 'Switch to Green Theme',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Logo and Welcome text
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.directions_bus,
                            size: 50,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _useGreenTheme ? 'Green Theme Active' : 'Blue Theme Active',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withAlpha(200),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Sign in to your driver account',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withAlpha(200),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Login form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Phone number field
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Mobile Number',
                              labelStyle: TextStyle(color: primaryColor),
                              prefixIcon: Icon(Icons.phone, color: primaryColor),
                              prefixText: '+91 ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: accentColor, width: 2),
                              ),
                              filled: true,
                              fillColor: primaryColor.withAlpha(10),
                            ),
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your mobile number';
                              }
                              if (value.length != 10) {
                                return 'Mobile number must be 10 digits';
                              }
                              if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                                return 'Please enter valid mobile number';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Send OTP button (Primary Color)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _sendOTP,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 5,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'SEND OTP',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: 15),
                          
                          //                          
                          const SizedBox(height: 20),
                          
                          // Divider with theme colors
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: primaryColor.withAlpha(100),
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: primaryColor.withAlpha(100),
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Register button (Secondary Color)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegistrationScreen(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: secondaryColor, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: secondaryColor.withAlpha(10),
                              ),
                              child: Text(
                                'CREATE NEW ACCOUNT',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: secondaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 15),
                          
                          // Theme info box
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: oppositeColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: oppositeColor.withAlpha(50)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _useGreenTheme ? Icons.eco : Icons.water_drop,
                                  color: oppositeColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _useGreenTheme 
                                      ? 'Using Green-White Theme. Tap the leaf icon to switch.'
                                      : 'Using Blue-White Theme. Tap the water icon to switch.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: oppositeColor.withAlpha(200),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 10),
                          
                          // OTP info box
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: accentColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: accentColor.withAlpha(50)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info, color: accentColor, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'We\'ll send a 6-digit OTP to verify your number',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: accentColor.withAlpha(200),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // App info with theme indicator
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: primaryColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: primaryColor.withAlpha(50)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _useGreenTheme ? Icons.check_circle : Icons.check_circle,
                                color: primaryColor,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _useGreenTheme ? 'Green Theme' : 'Blue Theme',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'BONUS BUS Driver App',
                          style: TextStyle(
                            color: Colors.white.withAlpha(150),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Version 2.0.1 • © 2024',
                          style: TextStyle(
                            color: Colors.white.withAlpha(100),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
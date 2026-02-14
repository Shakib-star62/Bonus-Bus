import 'package:flutter/material.dart';
import 'driver_home_screen.dart';

// OTP Verification Screen with theme support
class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  
  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 30;
  bool _useGreenTheme = false; // Match login theme

  final Color _bluePrimary = const Color(0xFF0A2472);
  final Color _greenPrimary = const Color(0xFF1B5E20);
  final Color _blueAccent = const Color(0xFF2196F3);
  final Color _greenAccent = const Color(0xFF00E676);
  final Color _blueSecondary = const Color(0xFF4263EB);
  final Color _greenSecondary = const Color(0xFF4CAF50);

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() => _resendTimer--);
        _startResendTimer();
      }
    });
  }

  void _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == 6) {
      setState(() => _isLoading = true);
      
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() => _isLoading = false);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DriverHomeScreen(),
        ),
      );
    }
  }

  void _resendOTP() async {
    if (_resendTimer == 0) {
      setState(() {
        _isResending = true;
        _resendTimer = 30;
      });
      
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() => _isResending = false);
      _startResendTimer();
    }
  }

  void _handleOTPInput(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
    
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
    
    final allFilled = _otpControllers.every((controller) => controller.text.isNotEmpty);
    if (allFilled) {
      _verifyOTP();
    }
  }

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _useGreenTheme ? _greenPrimary : _bluePrimary;
    final accentColor = _useGreenTheme ? _greenAccent : _blueAccent;
    final secondaryColor = _useGreenTheme ? _greenSecondary : _blueSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Header with theme indicator
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _useGreenTheme ? Icons.eco : Icons.water_drop,
                        color: primaryColor,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _useGreenTheme ? 'Green' : 'Blue',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            const Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'We sent a 6-digit code to +91 ${widget.phoneNumber}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // OTP Input Fields with theme colors
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 50,
                  height: 60,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: accentColor, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                    ),
                    onChanged: (value) => _handleOTPInput(value, index),
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 40),
            
            // Verify Button (Primary Color)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                    : const Text(
                        'VERIFY OTP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Alternate action button (Accent Color)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  // Alternate action
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: accentColor, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: accentColor.withAlpha(10),
                ),
                child: Text(
                  'USE DIFFERENT NUMBER',
                  style: TextStyle(
                    fontSize: 16,
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Resend OTP
            Center(
              child: Column(
                children: [
                  Text(
                    _resendTimer > 0
                        ? 'Resend OTP in $_resendTimer seconds'
                        : 'Didn\'t receive the code?',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _resendTimer == 0 && !_isResending ? _resendOTP : null,
                    child: _isResending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF4CAF50),
                            ),
                          )
                        : Text(
                            _resendTimer == 0 ? 'RESEND OTP' : 'Wait $_resendTimer seconds',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: secondaryColor,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Help text with theme color
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accentColor.withAlpha(50)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: accentColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'The OTP is valid for 10 minutes. Make sure you have network connectivity.',
                      style: TextStyle(
                        color: accentColor.withAlpha(200),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Theme toggle for OTP screen
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Theme:',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      _buildThemeOption(Icons.water_drop, 'Blue', false),
                      const SizedBox(width: 10),
                      _buildThemeOption(Icons.eco, 'Green', true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(IconData icon, String label, bool isGreen) {
    final bool isSelected = _useGreenTheme == isGreen;
    final Color color = isGreen ? _greenPrimary : _bluePrimary;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _useGreenTheme = isGreen;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(20) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
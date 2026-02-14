import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _soundAlerts = true;
  bool _vibration = true;
  bool _autoNavigation = true;
  bool _darkMode = false;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Settings
            const Text(
              'ACCOUNT SETTINGS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 15),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: const Text('Profile Settings'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      // Navigate to profile settings
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.security, color: Colors.blue),
                    title: const Text('Privacy & Security'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      // Navigate to privacy settings
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock, color: Colors.blue),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      // Change password
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Notification Settings
            const Text(
              'NOTIFICATIONS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 15),

            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive push notifications'),
                    value: _pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        _pushNotifications = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Email Notifications'),
                    subtitle: const Text('Receive email alerts'),
                    value: _emailNotifications,
                    onChanged: (value) {
                      setState(() {
                        _emailNotifications = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Sound Alerts'),
                    subtitle: const Text('Play sound for notifications'),
                    value: _soundAlerts,
                    onChanged: (value) {
                      setState(() {
                        _soundAlerts = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Vibration'),
                    subtitle: const Text('Vibrate for notifications'),
                    value: _vibration,
                    onChanged: (value) {
                      setState(() {
                        _vibration = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // App Settings
            const Text(
              'APP SETTINGS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 15),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language, color: Colors.blue),
                    title: const Text('Language'),
                    subtitle: Text(_language),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: _changeLanguage,
                  ),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Switch to dark theme'),
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() {
                        _darkMode = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Auto Navigation'),
                    subtitle: const Text('Automatic route suggestions'),
                    value: _autoNavigation,
                    onChanged: (value) {
                      setState(() {
                        _autoNavigation = value;
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.storage, color: Colors.blue),
                    title: const Text('Clear Cache'),
                    subtitle: const Text('Clear app cache data'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: _clearCache,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Support & About
            const Text(
              'SUPPORT & ABOUT',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 15),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help, color: Colors.blue),
                    title: const Text('Help Center'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: _openHelpCenter,
                  ),
                  ListTile(
                    leading: const Icon(Icons.feedback, color: Colors.blue),
                    title: const Text('Send Feedback'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: _sendFeedback,
                  ),
                  ListTile(
                    leading: const Icon(Icons.description, color: Colors.blue),
                    title: const Text('Terms & Conditions'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: _showTerms,
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip, color: Colors.blue),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: _showPrivacyPolicy,
                  ),
                  ListTile(
                    leading: const Icon(Icons.info, color: Colors.blue),
                    title: const Text('About App'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: _showAbout,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // App Version
            Center(
              child: Column(
                children: [
                  Text(
                    'BONUS BUS Driver App',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Version 2.0.1',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '© 2024 BONUS BUS. All rights reserved.',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeLanguage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: _language == 'English' ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() {
                  _language = 'English';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Spanish'),
              trailing: _language == 'Spanish' ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() {
                  _language = 'Spanish';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('French'),
              trailing: _language == 'French' ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() {
                  _language = 'French';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Clear all cached data? This will not affect your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }

  void _openHelpCenter() {
    // Open help center
  }

  void _sendFeedback() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Subject',
                hintText: 'Enter feedback subject',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Message',
                hintText: 'Enter your feedback',
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feedback sent successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('SEND'),
          ),
        ],
      ),
    );
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: const SingleChildScrollView(
          child: Text(
            'Terms and conditions content would be displayed here...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy policy content would be displayed here...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About BONUS BUS'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('BONUS BUS Driver App'),
              SizedBox(height: 10),
              Text('Version: 2.0.1'),
              Text('Build: 2024.01.15'),
              SizedBox(height: 10),
              Text('An EV Fleet Management System for professional drivers.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
}
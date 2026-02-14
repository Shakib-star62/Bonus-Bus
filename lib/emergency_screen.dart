import 'package:flutter/material.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency & Safety'),
        backgroundColor: Colors.blue[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Emergency SOS
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color.fromARGB(255, 237, 239, 240)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.sos,
                    color: Colors.blue,
                    size: 60,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'EMERGENCY SOS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Press the button below in case of emergency',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 41, 89, 184),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () => _triggerSOS(context),
                      icon: const Icon(Icons.warning, size: 30),
                      label: const Text(
                        'ACTIVATE EMERGENCY SOS',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Quick Emergency Contacts
            const Text(
              'QUICK CONTACTS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.2,
              children: [
                _buildEmergencyContact(context, 'Police', Icons.local_police, Colors.blue, '112'),
                _buildEmergencyContact(context, 'Ambulance', Icons.medical_services, Colors.green, '108'),
                _buildEmergencyContact(context, 'Fire', Icons.fire_truck, Colors.blue, '101'),
                _buildEmergencyContact(context, 'Control Room', Icons.security, Colors.green, '1800-123-456'),
              ],
            ),

            const SizedBox(height: 30),

            // Emergency Procedures
            const Text(
              'EMERGENCY PROCEDURES',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 30, 244, 48),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color.fromARGB(255, 218, 221, 218)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProcedureStep('1. Stay Calm', 'Keep calm and assess the situation'),
                  _buildProcedureStep('2. Activate SOS', 'Press SOS button for immediate help'),
                  _buildProcedureStep('3. Secure Vehicle', 'Pull over to safe location if possible'),
                  _buildProcedureStep('4. Contact Control', 'Inform control room of situation'),
                  _buildProcedureStep('5. Assist Passengers', 'Ensure passenger safety first'),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Emergency Reports
            const Text(
              'EMERGENCY REPORTS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            Column(
              children: [
                _buildEmergencyReportButton(context, 'Accident Report', Icons.car_crash),
                _buildEmergencyReportButton(context, 'Medical Emergency', Icons.medical_services),
                _buildEmergencyReportButton(context, 'Vehicle Breakdown', Icons.miscellaneous_services),
                _buildEmergencyReportButton(context, 'Passenger Emergency', Icons.person_off),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContact(BuildContext context, String title, IconData icon, Color color, String number) {
    return GestureDetector(
      onTap: () => _callEmergency(context, number),
      child: Container(
        decoration: BoxDecoration(
          color: color.withAlpha(25), // Fixed: replaced withOpacity with withAlpha
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withAlpha(75)), // Fixed: replaced withOpacity with withAlpha
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              number,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcedureStep(String step, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                step.split('.')[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyReportButton(BuildContext context, String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => _fileEmergencyReport(context, title),
      ),
    );
  }

  void _triggerSOS(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('EMERGENCY SOS ACTIVATION'),
        content: const Text('Are you sure you want to activate Emergency SOS?\n\n'
            'This will immediately alert emergency services and dispatch help.'),
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
                  content: Text('Emergency SOS activated! Help is on the way.'),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 5),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('ACTIVATE SOS'),
          ),
        ],
      ),
    );
  }

  void _callEmergency(BuildContext context, String number) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Emergency'),
        content: Text('Call $number?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling $number...'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('CALL'),
          ),
        ],
      ),
    );
  }

  void _fileEmergencyReport(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$type Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Location',
                hintText: 'Enter current location',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Details',
                hintText: 'Describe the emergency',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
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
                SnackBar(
                  content: Text('$type report submitted'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('SUBMIT'),
          ),
        ],
      ),
    );
  }
}
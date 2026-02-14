import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'route_map_screen.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final double _batteryHealth = 92.0;
  final double _batteryLevel = 75.0;
  List<MaintenanceTask> _maintenanceTasks = [];
  List<ChargingSession> _chargingHistory = [];
  List<ChargingStation> _nearbyStations = [];

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    _maintenanceTasks = [
      MaintenanceTask(
        id: 'M001',
        type: 'Tire Rotation',
        dueIn: '2,000 km',
        lastDone: DateTime.now().subtract(const Duration(days: 60)),
        status: 'upcoming',
        severity: 'low',
      ),
      MaintenanceTask(
        id: 'M002',
        type: 'Brake Inspection',
        dueIn: '1,500 km',
        lastDone: DateTime.now().subtract(const Duration(days: 45)),
        status: 'urgent',
        severity: 'high',
      ),
      MaintenanceTask(
        id: 'M003',
        type: 'Battery Check',
        dueIn: '3 months',
        lastDone: DateTime.now().subtract(const Duration(days: 90)),
        status: 'pending',
        severity: 'medium',
      ),
    ];

    _chargingHistory = [
      ChargingSession(
        id: 'C001',
        stationName: 'SuperCharge Hub',
        date: DateTime.now().subtract(const Duration(days: 1)),
        energy: 85.5,
        cost: 42.75,
        duration: '45 min',
        chargeLevel: '20% → 85%',
      ),
      ChargingSession(
        id: 'C002',
        stationName: 'Green EV Station',
        date: DateTime.now().subtract(const Duration(days: 3)),
        energy: 92.0,
        cost: 36.80,
        duration: '1h 15min',
        chargeLevel: '15% → 90%',
      ),
      ChargingSession(
        id: 'C003',
        stationName: 'EcoPower Center',
        date: DateTime.now().subtract(const Duration(days: 7)),
        energy: 78.0,
        cost: 46.80,
        duration: '35 min',
        chargeLevel: '25% → 80%',
      ),
    ];

    _nearbyStations = [
      ChargingStation(
        name: 'SuperCharge Hub',
        distance: 2.5,
        availablePorts: 4,
        totalPorts: 8,
        powerLevel: '150kW',
        estimatedWaitTime: 15,
        costPerKwh: 0.35,
        stationType: 'fast',
      ),
      ChargingStation(
        name: 'Green EV Station',
        distance: 5.1,
        availablePorts: 6,
        totalPorts: 12,
        powerLevel: '75kW',
        estimatedWaitTime: 5,
        costPerKwh: 0.28,
        stationType: 'standard',
      ),
      ChargingStation(
        name: 'EcoPower Center',
        distance: 7.8,
        availablePorts: 2,
        totalPorts: 6,
        powerLevel: '250kW',
        estimatedWaitTime: 25,
        costPerKwh: 0.42,
        stationType: 'ultraFast',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // This removes the back button
          title: const Text('Maintenance & Battery'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Maintenance'),
              Tab(text: 'Battery'),
              Tab(text: 'Charging'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Maintenance Tab
            _buildMaintenanceTab(),
            // Battery Tab
            _buildBatteryTab(),
            // Charging Tab
            _buildChargingTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {});
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Maintenance Tasks
            const Text(
              'MAINTENANCE TASKS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            ..._maintenanceTasks.map((task) => _buildMaintenanceTaskCard(task)),
            const SizedBox(height: 20),

            // Schedule Maintenance Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _scheduleMaintenance,
                icon: const Icon(Icons.calendar_today),
                label: const Text('SCHEDULE MAINTENANCE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Maintenance History
            const Text(
              'MAINTENANCE HISTORY',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildMaintenanceHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceTaskCard(MaintenanceTask task) {
    Color color;
    IconData icon;

    switch (task.severity) {
      case 'high':
        color = Colors.red;
        icon = Icons.warning;
        break;
      case 'medium':
        color = Colors.orange;
        icon = Icons.error_outline;
        break;
      default:
        color = Colors.yellow;
        icon = Icons.info_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          task.type,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Due in: ${task.dueIn}'),
            Text('Last done: ${DateFormat('MMM dd').format(task.lastDone)}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(task.status),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            task.status.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () => _showTaskDetails(task),
      ),
    );
  }

  Widget _buildMaintenanceHistory() {
    return Column(
      children: [
        // _buildHistoryItem('Oil Change', '2 weeks ago', 'Completed', Colors.green),
        _buildHistoryItem('Brake Pads', '1 month ago', 'Completed', Colors.green),
        _buildHistoryItem('Air Filter', '2 months ago', 'Completed', Colors.green),
        _buildHistoryItem('Tire Replacement', '3 months ago', 'Completed', Colors.green),
      ],
    );
  }

  Widget _buildHistoryItem(String service, String date, String status, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.check_circle, color: color),
        ),
        title: Text(service),
        subtitle: Text(date),
        trailing: Text(
          status,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBatteryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Battery Health Gauge
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: _batteryHealth / 100,
                  strokeWidth: 15,
                  backgroundColor: Colors.grey[200],
                  color: _getBatteryColor(_batteryHealth),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${_batteryHealth.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Battery Health',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Battery Details
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildBatteryDetail('Current Level', '${_batteryLevel.toInt()}%', Icons.battery_charging_full),
                const Divider(),
                _buildBatteryDetail('Cycles Count', '1,243', Icons.repeat),
                const Divider(),
                _buildBatteryDetail('Temperature', '28°C', Icons.thermostat),
                const Divider(),
                _buildBatteryDetail('Voltage', '400V', Icons.bolt),
                const Divider(),
                _buildBatteryDetail('Last Charged', '2 hours ago', Icons.access_time),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Battery Tips
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Battery Care Tips',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 10),
                Text('• Charge between 20-80% for best battery life'),
                Text('• Avoid fast charging when not necessary'),
                Text('• Keep battery cool in hot weather'),
                Text('• Schedule regular battery checks'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryDetail(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nearby Charging Stations
          const Text(
            'NEARBY CHARGING STATIONS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          ..._nearbyStations.map((station) => _buildStationCard(station)),
          const SizedBox(height: 20),

          // Charging History
          const Text(
            'CHARGING HISTORY',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          ..._chargingHistory.map((session) => _buildChargingSessionCard(session)),
        ],
      ),
    );
  }

  Widget _buildStationCard(ChargingStation station) {
    Color color = _getStationColor(station.stationType);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.ev_station, color: color),
        ),
        title: Text(
          station.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${station.distance} km • ${station.powerLevel}'),
            Text('${station.availablePorts}/${station.totalPorts} ports available'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$${station.costPerKwh}/kWh',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${station.estimatedWaitTime} min wait',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChargingSessionCard(ChargingSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.bolt, color: Colors.green),
        ),
        title: Text(session.stationName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${session.energy} kWh • ${session.duration}'),
            Text(DateFormat('MMM dd, hh:mm a').format(session.date)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$${session.cost}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              session.chargeLevel,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'urgent':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'upcoming':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getBatteryColor(double level) {
    if (level > 80) return Colors.green;
    if (level > 60) return Colors.yellow;
    if (level > 40) return Colors.orange;
    return Colors.red;
  }

  Color _getStationColor(String type) {
    switch (type) {
      case 'ultraFast':
        return Colors.purple;
      case 'fast':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  void _scheduleMaintenance() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Maintenance'),
        content: const Text('Choose maintenance type:'),
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
                  content: Text('Maintenance scheduled successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('SCHEDULE'),
          ),
        ],
      ),
    );
  }

  void _showTaskDetails(MaintenanceTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.type),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${task.status.toUpperCase()}'),
            Text('Due in: ${task.dueIn}'),
            Text('Last done: ${DateFormat('MMM dd, yyyy').format(task.lastDone)}'),
            Text('Severity: ${task.severity.toUpperCase()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Mark as completed
            },
            child: const Text('MARK DONE'),
          ),
        ],
      ),
    );
  }
}

class MaintenanceTask {
  final String id;
  final String type;
  final String dueIn;
  final DateTime lastDone;
  final String status;
  final String severity;

  MaintenanceTask({
    required this.id,
    required this.type,
    required this.dueIn,
    required this.lastDone,
    required this.status,
    required this.severity,
  });
}

class ChargingSession {
  final String id;
  final String stationName;
  final DateTime date;
  final double energy;
  final double cost;
  final String duration;
  final String chargeLevel;

  ChargingSession({
    required this.id,
    required this.stationName,
    required this.date,
    required this.energy,
    required this.cost,
    required this.duration,
    required this.chargeLevel,
  });
}
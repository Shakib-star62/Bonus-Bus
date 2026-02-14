import 'dart:async';
import 'package:driver_app/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'route_map_screen.dart';
import 'maintenance_screen.dart';
import 'emergency_screen.dart';
import 'settings_screen.dart';
import 'passenger_onboarding_screen.dart';

// All Model Classes
class TripRequest {
  final String id;
  final String route;
  final int passengerCount;
  final String pickup;
  final String dropoff;
  final double distance;
  final double fare;
  final String time;
  final String status;
  final String busNumber;
  final String driverName;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final List<Passenger>? passengers;

  TripRequest({
    required this.id,
    required this.route,
    required this.passengerCount,
    required this.pickup,
    required this.dropoff,
    required this.distance,
    required this.fare,
    required this.time,
    required this.status,
    required this.busNumber,
    required this.driverName,
    required this.departureTime,
    required this.arrivalTime,
    this.passengers,
  });
}

class Passenger {
  final String id;
  final String name;
  final String seatNumber;
  final String onboardingCode;
  final DateTime onboardTime;
  final String status;

  Passenger({
    required this.id,
    required this.name,
    required this.seatNumber,
    required this.onboardingCode,
    required this.onboardTime,
    required this.status,
  });
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final String type;
  bool read;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.read,
  });
}

// Main Screen Class
class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int _currentIndex = 0;
  bool _isOnline = false;
  Timer? _onlineTimer;
  double _earningsToday = 600.00;
  int _completedTrips = 3;
  final int _maxCapacity = 35;
  final double _batteryLevel = 75.0;
  List<TripRequest> _tripRequestsList = [];
  List<NotificationItem> _notifications = [];
  TripRequest? _currentTrip;
  double _tripProgress = 0.0;
  bool _isTripStarted = false;
  bool _isTripPaused = false;
  int _currentPassengers = 0;
  final double _tripFare = 200.00;
  Timer? _tripProgressTimer;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    _tripRequestsList = [
      TripRequest(
        id: 'TR001',
        route: 'Narsipatnam',
        passengerCount: 24,
        pickup: 'VISHAKAPATNAM',
        dropoff: 'NARSIPATNAM',
        distance: 84.5,
        fare: _tripFare,
        time: '08:30 AM',
        status: 'pending',
        busNumber: 'EVB-2024-007',
        driverName: 'Driver SHIVA',
        departureTime: DateTime.now(),
        arrivalTime: DateTime.now().add(const Duration(hours: 1)),
        passengers: [],
      ),
      TripRequest(
        id: 'TR002',
        route: 'KAKINADA',
        passengerCount: 28,
        pickup: 'KAKINADA',
        dropoff: 'VISHAKAPATNAM',
        distance: 120.0,
        fare: _tripFare,
        time: '10:15 AM',
        status: 'pending',
        busNumber: 'EVB-2024-007',
        driverName: 'Driver SHIVA',
        departureTime: DateTime.now().add(const Duration(hours: 2)),
        arrivalTime: DateTime.now().add(const Duration(hours: 3)),
        passengers: [],
      ),
    ];

    _notifications = [
      NotificationItem(
        id: 'N1',
        title: 'New Trip Assigned',
        message: 'You have been assigned Trip #TR001 from VISHAKAPATNAM to NARSIPATNAM.',
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        type: 'trip',
        read: false,
      ),
    ];
  }

  void _toggleOnlineStatus() {
    setState(() {
      _isOnline = !_isOnline;
      if (_isOnline) {
        _startOnlineSession();
        if (_tripRequestsList.isEmpty) {
          _loadMockData();
        }
      } else {
        _stopOnlineSession();
        _tripRequestsList.clear();
      }
    });
  }

  void _startOnlineSession() {
    _onlineTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          if (_isOnline && _tripRequestsList.length < 5 && _currentTrip == null) {
            final randomPassengers = 20 + (_tripRequestsList.length * 3);
            _tripRequestsList.add(TripRequest(
              id: 'TR00${_tripRequestsList.length + 1}',
              route: 'Express Service ${_tripRequestsList.length + 1}',
              passengerCount: randomPassengers,
              pickup: 'Location ${_tripRequestsList.length + 1}',
              dropoff: 'Destination ${_tripRequestsList.length + 1}',
              distance: 10.0 + (_tripRequestsList.length * 2),
              fare: _tripFare,
              time: DateFormat('hh:mm a').format(DateTime.now()),
              status: 'pending',
              busNumber: 'EVB-2024-007',
              driverName: 'SHIVA',
              departureTime: DateTime.now(),
              arrivalTime: DateTime.now().add(const Duration(hours: 1)),
              passengers: [],
            ));
          }
        });
      }
    });
  }

  void _stopOnlineSession() {
    _onlineTimer?.cancel();
    _onlineTimer = null;
  }

  void _startTripProgress() {
    if (_currentTrip != null && !_isTripStarted) {
      setState(() {
        _isTripStarted = true;
        _isTripPaused = false;
      });
      
      _startProgressTimer();
    }
  }

  void _pauseTripProgress() {
    setState(() {
      _isTripPaused = true;
    });
    _tripProgressTimer?.cancel();
  }

  void _resumeTripProgress() {
    setState(() {
      _isTripPaused = false;
    });
    _startProgressTimer();
  }

  void _startProgressTimer() {
    _tripProgressTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted && _isTripStarted && !_isTripPaused && _tripProgress < 1.0) {
        setState(() {
          _tripProgress += 0.05;
          if (_tripProgress >= 1.0) {
            _tripProgress = 1.0;
            timer.cancel();
          }
        });
      } else if (_tripProgress >= 1.0) {
        timer.cancel();
      }
    });
  }

  void _completeTrip() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Trip'),
        content: Text('Complete Trip #${_currentTrip!.id}?\n\n'
            'Route: ${_currentTrip!.route}\n'
            'Passengers: $_currentPassengers/${_currentTrip!.passengerCount}\n'
            'Fare Earned: \$$_tripFare'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _completedTrips++;
                _earningsToday += _tripFare;
                _currentTrip = null;
                _isTripStarted = false;
                _isTripPaused = false;
                _tripProgress = 0.0;
                _currentPassengers = 0;
                _tripProgressTimer?.cancel();
                if (_isOnline) {
                  _loadMockData();
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Trip completed! Earned \$200'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('COMPLETE'),
          ),
        ],
      ),
    );
  }

  void _navigateToOnboarding() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PassengerOnboardingScreen(
          currentTrip: _currentTrip,
          currentPassengers: _currentPassengers,
          maxCapacity: _maxCapacity,
        ),
      ),
    );
    
    if (result != null && mounted) {
      setState(() {
        _currentPassengers = result;
      });
    }
  }

  @override
  void dispose() {
    _onlineTimer?.cancel();
    _tripProgressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.directions_bus, size: 20),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'BONUS BUS',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_currentTrip != null) ...[
                  const SizedBox(width: 4),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${_currentTrip!.id}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    _isOnline ? 'ONLINE' : 'OFFLINE',
                    style: TextStyle(
                      color: _isOnline ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: _isOnline,
                    onChanged: _currentTrip == null ? (value) => _toggleOnlineStatus() : null,
                    activeThumbColor: Colors.green,
                    activeTrackColor: const Color.fromARGB(255, 243, 246, 243).withOpacity(0.5),
                    inactiveThumbColor: Colors.red,
                    inactiveTrackColor: const Color.fromARGB(255, 252, 248, 248).withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardTab(),
          const RouteMapScreen(),
          ProfileScreen(earningsToday: _earningsToday),
          const MaintenanceScreen(),
        ],
      ),
      drawer: _buildDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard, size: 22),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.route, size: 22),
            label: 'Route',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet, size: 22),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build, size: 22),
            label: 'Maintenance',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue[900],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'SHIVA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: EVB-2024-007',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
                Text(
                  'Tesla eBus Pro (35 seats)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
                Text(
                  'Earnings: \$$_earningsToday',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.blue, size: 22),
            title: const Text('Notifications', style: TextStyle(fontSize: 14)),
            trailing: Badge(
              label: Text(_notifications.where((n) => !n.read).length.toString()),
              backgroundColor: Colors.red,
            ),
            onTap: () {
              Navigator.pop(context);
              _showNotifications();
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.schedule, color: Colors.blue, size: 22),
            title: const Text('Schedule', style: TextStyle(fontSize: 14)),
            onTap: () {
              Navigator.pop(context);
              _showSchedule();
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.bar_chart, color: Colors.blue, size: 22),
            title: const Text('Performance', style: TextStyle(fontSize: 14)),
            onTap: () {
              Navigator.pop(context);
              _showPerformance();
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.emergency, color: Colors.red, size: 22),
            title: const Text('Emergency', style: TextStyle(fontSize: 14)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EmergencyScreen()),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.blue, size: 22),
            title: const Text('Settings', style: TextStyle(fontSize: 14)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.help, color: Colors.blue, size: 22),
            title: const Text('Help & Support', style: TextStyle(fontSize: 14)),
            onTap: () {
              Navigator.pop(context);
              _showSupport();
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red, size: 22),
            title: const Text('Logout', style: TextStyle(fontSize: 14)),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {});
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 16),

            if (_currentTrip != null) ...[
              _buildMergedTripSection(),
              const SizedBox(height: 16),
            ],

            if (_currentTrip == null) ...[
              if (_isOnline) ...[
                _buildTripRequestsSection(),
              ] else ...[
                _buildOfflineMessage(),
              ],
              const SizedBox(height: 16),
            ],

            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildMergedTripSection() {
    if (_currentTrip == null) return Container();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ACTIVE TRIP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Trip #${_currentTrip!.id}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isTripPaused 
                      ? Colors.orange.withOpacity(0.1)
                      : _isTripStarted 
                          ? Colors.green.withOpacity(0.1) 
                          : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _isTripPaused 
                      ? 'PAUSED'
                      : _isTripStarted 
                          ? 'IN PROGRESS' 
                          : 'READY',
                  style: TextStyle(
                    color: _isTripPaused 
                        ? Colors.orange[800]
                        : _isTripStarted 
                            ? Colors.green[800] 
                            : Colors.orange[800],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Route Information with adjusted font sizes
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.route, color: Colors.blue, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentTrip!.route,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_currentTrip!.distance} km • ${_currentTrip!.time}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '\$${_currentTrip!.fare}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildLocationCard(
                        'PICKUP',
                        _currentTrip!.pickup,
                        Icons.location_on,
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildLocationCard(
                        'DROPOFF',
                        _currentTrip!.dropoff,
                        Icons.flag,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bus & Trip Details Grid with adjusted sizes
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.6,
            children: [
              _buildDetailCard(
                'Passengers',
                '$_currentPassengers/$_maxCapacity',
                Icons.people,
                Colors.blue,
                _buildPassengerProgress(),
              ),
              _buildDetailCard(
                'Battery',
                '${_batteryLevel.toInt()}%',
                Icons.battery_charging_full,
                Colors.green,
                LinearProgressIndicator(
                  value: _batteryLevel / 100,
                  backgroundColor: Colors.grey[200],
                  color: _batteryLevel > 20 ? Colors.green : Colors.red,
                  minHeight: 3,
                ),
              ),
              _buildDetailCard(
                'Trip Progress',
                '${(_tripProgress * 100).toInt()}%',
                Icons.timeline,
                Colors.purple,
                LinearProgressIndicator(
                  value: _tripProgress,
                  backgroundColor: Colors.grey[200],
                  color: Colors.purple,
                  minHeight: 3,
                ),
              ),
              _buildDetailCard(
                'Online Hours',
                '5h',
                Icons.timer,
                Colors.orange,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons with Pause/Resume option
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _isTripStarted && !_isTripPaused
                        ? ElevatedButton.icon(
                            onPressed: _pauseTripProgress,
                            icon: const Icon(Icons.pause, size: 18),
                            label: const Text('PAUSE TRIP'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          )
                        : _isTripPaused
                            ? ElevatedButton.icon(
                                onPressed: _resumeTripProgress,
                                icon: const Icon(Icons.play_arrow, size: 18),
                                label: const Text('RESUME TRIP'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: _startTripProgress,
                                icon: const Icon(Icons.play_arrow, size: 18),
                                label: const Text('START TRIP'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                              ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentIndex = 1;
                        });
                      },
                      icon: const Icon(Icons.navigation, size: 18),
                      label: const Text('NAVIGATION'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _navigateToOnboarding,
                      icon: const Icon(Icons.qr_code_scanner, size: 18),
                      label: const Text('ONBOARD'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _completeTrip,
                      icon: const Icon(Icons.flag, size: 18),
                      label: const Text('COMPLETE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(String title, String location, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon, Color color, Widget? extra) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          if (extra != null) ...[
            const SizedBox(height: 6),
            extra,
          ],
        ],
      ),
    );
  }

  Widget _buildPassengerProgress() {
    final percentage = _currentPassengers / _maxCapacity;
    return Column(
      children: [
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[200],
          color: percentage >= 1.0 ? Colors.red : Colors.blue,
          minHeight: 3,
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(percentage * 100).toInt()}%',
              style: TextStyle(
                fontSize: 9,
                color: percentage >= 1.0 ? Colors.red : Colors.blue,
              ),
            ),
            Text(
              '${_maxCapacity - _currentPassengers} left',
              style: const TextStyle(
                fontSize: 9,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOfflineMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off,
            size: 50,
            color: Colors.grey,
          ),
          const SizedBox(height: 12),
          const Text(
            'You are OFFLINE',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Go online to receive trip requests',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _toggleOnlineStatus,
            icon: const Icon(Icons.wifi, size: 18),
            label: const Text('GO ONLINE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[800]!,
            Colors.blue[600]!,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, SHIVA!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ready to ${_isOnline ? 'accept trips' : 'go online'}?',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildStatCard('Trips', '$_completedTrips', Icons.directions_bus),
              const SizedBox(width: 8),
              _buildStatCard('Earnings', '\$$_earningsToday', Icons.monetization_on),
              const SizedBox(width: 8),
              _buildStatCard('Rating', '4.8★', Icons.star),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripRequestsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TRIP REQUESTS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.wifi, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    'ONLINE',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Badge(
                    label: Text(_tripRequestsList.length.toString()),
                    backgroundColor: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_tripRequestsList.isNotEmpty)
            ..._tripRequestsList.map((request) => _buildTripRequestCard(request)),
          if (_tripRequestsList.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.hourglass_empty, color: Colors.grey, size: 36),
                    SizedBox(height: 8),
                    Text(
                      'No trip requests',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTripRequestCard(TripRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trip #${request.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  request.time,
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTripDetail('Route', request.route, Icons.route),
              ),
              Expanded(
                child: _buildTripDetail('Pass.', '${request.passengerCount}/$_maxCapacity', Icons.people),
              ),
              Expanded(
                child: _buildTripDetail('Dist.', '${request.distance} km', Icons.directions),
              ),
              Expanded(
                child: _buildTripDetail('Fare', '\$${request.fare}', Icons.monetization_on),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _declineTrip(request),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('DECLINE', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _acceptTrip(request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('ACCEPT', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 14, color: Colors.blue),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QUICK ACTIONS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
            children: [
              _buildQuickActionButton('Navigation', Icons.navigation, Colors.purple, () {
                setState(() {
                  _currentIndex = 1;
                });
              }),
              _buildQuickActionButton('Onboard', Icons.qr_code_scanner, Colors.blue, _navigateToOnboarding),
              _buildQuickActionButton('Wallet', Icons.account_balance_wallet, Colors.orange, () {
                setState(() {
                  _currentIndex = 2;
                });
              }),
              _buildQuickActionButton('Emergency', Icons.sos, Colors.red, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EmergencyScreen()),
                );
              }),
              _buildQuickActionButton('Support', Icons.support_agent, Colors.teal, _contactSupport),
              _buildQuickActionButton('Settings', Icons.settings, Colors.grey, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _acceptTrip(TripRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Trip', style: TextStyle(fontSize: 18)),
        content: Text(
          'Accept trip #${request.id}?\n\n'
          'Route: ${request.route}\n'
          'Passengers: ${request.passengerCount}/$_maxCapacity\n'
          'Fare: \$${request.fare}',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentTrip = request;
                _tripRequestsList.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Trip #${request.id} accepted!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('ACCEPT', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _declineTrip(TripRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Trip', style: TextStyle(fontSize: 18)),
        content: Text(
          'Decline trip #${request.id}?\n\n'
          'Route: ${request.route}\n'
          'Passengers: ${request.passengerCount}',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _tripRequestsList.remove(request);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Trip #${request.id} declined'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('DECLINE', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          for (var notification in _notifications) {
                            notification.read = true;
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Mark all read', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: notification.read ? Colors.white : Colors.blue[50],
                      child: ListTile(
                        leading: Icon(
                          _getNotificationIcon(notification.type),
                          color: _getNotificationColor(notification.type),
                          size: 22,
                        ),
                        title: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          notification.message,
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Text(
                          _formatTimeAgo(notification.time),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        onTap: () {
                          setState(() {
                            notification.read = true;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'trip':
        return Icons.directions_bus;
      case 'warning':
        return Icons.warning;
      case 'maintenance':
        return Icons.build;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'trip':
        return Colors.blue;
      case 'warning':
        return Colors.orange;
      case 'maintenance':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }

  void _showSchedule() {
    // Implementation
  }

  void _showPerformance() {
    // Implementation
  }

  void _showSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support', style: TextStyle(fontSize: 18)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.phone, color: Colors.blue, size: 22),
              title: Text('Call Support', style: TextStyle(fontSize: 14)),
              subtitle: Text('+1 (800) 123-4567', style: TextStyle(fontSize: 12)),
            ),
            ListTile(
              leading: Icon(Icons.email, color: Colors.blue, size: 22),
              title: Text('Email Support', style: TextStyle(fontSize: 14)),
              subtitle: Text('support@bonusbus.com', style: TextStyle(fontSize: 12)),
            ),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.blue, size: 22),
              title: Text('Live Chat', style: TextStyle(fontSize: 14)),
              subtitle: Text('Available 24/7', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE', style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('START CHAT', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support', style: TextStyle(fontSize: 18)),
        content: const Text('Choose your preferred contact method:', style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('CHAT', style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('CALL', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout', style: TextStyle(fontSize: 18)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('LOGOUT', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

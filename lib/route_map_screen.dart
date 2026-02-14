import 'dart:async';
// import 'package:driver_app/driver_home_screen.dart';
import 'package:flutter/material.dart';

class RouteMapScreen extends StatefulWidget {
  const RouteMapScreen({super.key});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> with SingleTickerProviderStateMixin {
  // Navigation states
  bool _isNavigating = false;
  double _navigationProgress = 0.6;
  String _nextStop = 'NAD';
  final String _eta = '08:45 AM';
  final double _distanceToNextStop = 10.5;
  // ignore: unused_field
  final String _trafficCondition = 'Light';
  
  // Map controls
  double _mapZoom = 1.0;
  bool _showTraffic = true;
  bool _showStations = true;
  bool _showStops = true;
  bool _liveTracking = true;
  Timer? _locationUpdateTimer;
  
  // Data
  List<MapStop> _stops = [];
  List<Map<String, dynamic>> _trafficAlerts = [];
  List<ChargingStation> _nearbyStations = [];
  
  // Animation
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _startLocationUpdates();
    
    // Setup pulse animation for current location
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _initializeData() {
    // Route stops
    _stops = [
      MapStop(
        id: 'S1',
        name: 'NAD',
        sequence: 1,
        arrivalTime: '08:00 AM',
        isCompleted: false,
        passengers: 5,
      ),
      MapStop(
        id: 'S2',
        name: 'GAJUWAKA',
        sequence: 2,
        arrivalTime: '08:30 AM',
        isCompleted: false,
        passengers: 8,
      ),
      MapStop(
        id: 'S3',
        name: 'LANKELAPALEM',
        sequence: 3,
        arrivalTime: '09:00 AM',
        isCompleted: false,
        passengers: 15,
      ),
      MapStop(
        id: 'S4',
        name: 'THALAPALEM',
        sequence: 4,
        arrivalTime: '09:45 AM',
        isCompleted: false,
        passengers: 10,
      ),
      MapStop(
        id: 'S5',
        name: 'NARSIPATNAM',
        sequence: 5,
        arrivalTime: '10:00 AM',
        isCompleted: false,
        passengers: 20,
      ),
    ];

    // Traffic alerts
    _trafficAlerts = [
      {
        'id': 'T1',
        'type': 'accident',
        'title': 'Accident Ahead',
        'description': 'Multi-vehicle accident on I-80',
        'severity': 'high',
        'distance': '2.1 km',
        'delay': '15 min',
      },
      {
        'id': 'T2',
        'type': 'construction',
        'title': 'Road Construction',
        'description': 'Lane closure for maintenance',
        'severity': 'medium',
        'distance': '4.5 km',
        'delay': '10 min',
      },
      {
        'id': 'T3',
        'type': 'congestion',
        'title': 'Heavy Traffic',
        'description': 'Slow moving traffic ahead',
        'severity': 'low',
        'distance': '3.2 km',
        'delay': '5 min',
      },
    ];

    // Charging stations
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

  void _startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _liveTracking) {
        setState(() {
          // Simulate location updates
          _navigationProgress += 0.05;
          if (_navigationProgress > 1.0) {
            _navigationProgress = 0.0;
            // Move to next stop
            final currentStopIndex = _stops.indexWhere((stop) => !stop.isCompleted);
            if (currentStopIndex != -1 && currentStopIndex < _stops.length - 1) {
              _stops[currentStopIndex].isCompleted = true;
              _nextStop = _stops[currentStopIndex + 1].name;
            }
          }
        });
      }
    });
  }

  void _toggleNavigation() {
    setState(() {
      _isNavigating = !_isNavigating;
      if (_isNavigating) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Navigation started'),
            backgroundColor: Colors.green[800],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Navigation stopped'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  void _toggleLiveTracking() {
    setState(() {
      _liveTracking = !_liveTracking;
      if (_liveTracking) {
        _startLocationUpdates();
      } else {
        _locationUpdateTimer?.cancel();
      }
    });
  }

  void _zoomIn() {
    setState(() {
      if (_mapZoom < 2.0) _mapZoom += 0.1;
    });
  }

  void _zoomOut() {
    setState(() {
      if (_mapZoom > 0.5) _mapZoom -= 0.1;
    });
  }

  void _showStopDetails(MapStop stop) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    stop.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: stop.isCompleted ? Colors.green[100] : Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      stop.isCompleted ? 'COMPLETED' : 'UPCOMING',
                      style: TextStyle(
                        color: stop.isCompleted ? Colors.green[800] : Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _buildDetailRow('Arrival Time', stop.arrivalTime, Icons.access_time),
              _buildDetailRow('Passengers', '${stop.passengers} boarding', Icons.people),
              _buildDetailRow('Stop Sequence', '#${stop.sequence}', Icons.numbers),
              const SizedBox(height: 20),
              if (!stop.isCompleted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _arriveAtStop(stop);
                    },
                    icon: const Icon(Icons.directions_bus),
                    label: const Text('ARRIVE AT STOP'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
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

  void _arriveAtStop(MapStop stop) {
    setState(() {
      stop.isCompleted = true;
      final nextStopIndex = _stops.indexWhere((s) => !s.isCompleted);
      if (nextStopIndex != -1) {
        _nextStop = _stops[nextStopIndex].name;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Arrived at ${stop.name}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showTrafficAlertDetails(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alert['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert['description']),
            const SizedBox(height: 15),
            _buildAlertDetail('Distance', alert['distance']),
            _buildAlertDetail('Delay', alert['delay']),
            _buildAlertDetail('Severity', alert['severity'].toString().toUpperCase()),
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
              _rerouteAroundAlert(alert);
            },
            child: const Text('REROUTE'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Text(value),
        ],
      ),
    );
  }

  void _rerouteAroundAlert(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reroute Confirmation'),
        content: const Text('Find alternative route around traffic alert?'),
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
                  content: Text('Rerouting...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('REROUTE'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with navigation controls
          _buildHeader(),
          
          // Map Area
          Expanded(
            child: Stack(
              children: [
                // Map Background
                Container(
                  color: Colors.blue[50],
                  child: _buildMapVisualization(),
                ),
                
                // Current Vehicle Indicator
                Positioned.fill(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.green,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.directions_bus,
                              color: Colors.green,
                              size: 24,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Map Controls
                Positioned(
                  top: 16,
                  right: 16,
                  child: Column(
                    children: [
                      _buildMapControlButton(
                        _liveTracking ? Icons.gps_fixed : Icons.gps_off,
                        _liveTracking ? 'Live Tracking ON' : 'Live Tracking OFF',
                        _toggleLiveTracking,
                        _liveTracking ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      _buildMapControlButton(
                        Icons.add,
                        'Zoom In',
                        _zoomIn,
                        Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      _buildMapControlButton(
                        Icons.remove,
                        'Zoom Out',
                        _zoomOut,
                        Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      _buildMapControlButton(
                        _showTraffic ? Icons.traffic : Icons.traffic_outlined,
                        _showTraffic ? 'Hide Traffic' : 'Show Traffic',
                        () => setState(() => _showTraffic = !_showTraffic),
                        _showTraffic ? Colors.orange : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      _buildMapControlButton(
                        _showStations ? Icons.ev_station : Icons.ev_station_outlined,
                        _showStations ? 'Hide Stations' : 'Show Stations',
                        () => setState(() => _showStations = !_showStations),
                        _showStations ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      _buildMapControlButton(
                        _showStops ? Icons.location_on : Icons.location_off,
                        _showStops ? 'Hide Stops' : 'Show Stops',
                        () => setState(() => _showStops = !_showStops),
                        _showStops ? Colors.purple : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Navigation Panel
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      decoration: BoxDecoration(
        color: Colors.blue[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Route 42 - VISHAKAPATNAM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'VISHAKAPATNAM → KANNURPALEM',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusIndicator(),
            ],
          ),
          const SizedBox(height: 10),
          _buildNavigationInfo(),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isNavigating ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isNavigating ? Icons.navigation : Icons.pause,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            _isNavigating ? 'NAVIGATING' : 'PAUSED',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Stop: $_nextStop',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ETA: $_eta • ${_distanceToNextStop.toStringAsFixed(1)} km',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: _toggleNavigation,
            icon: Icon(
              _isNavigating ? Icons.pause : Icons.play_arrow,
              size: 16,
            ),
            label: Text(
              _isNavigating ? 'PAUSE' : 'START',
              style: const TextStyle(fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isNavigating ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapVisualization() {
    return CustomPaint(
      size: Size.infinite,
      painter: _MapPainter(
        stops: _showStops ? _stops : [],
        trafficAlerts: _showTraffic ? _trafficAlerts : [],
        stations: _showStations ? _nearbyStations : [],
        navigationProgress: _navigationProgress,
        zoom: _mapZoom,
      ),
    );
  }

  Widget _buildMapControlButton(IconData icon, String tooltip, VoidCallback onPressed, Color color) {
    return Tooltip(
      message: tooltip,
      child: FloatingActionButton.small(
        heroTag: tooltip,
        onPressed: onPressed,
        backgroundColor: Colors.white,
        child: Icon(icon, color: color),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: const TabBar(
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: [
                  Tab(text: 'Route Stops'),
                  Tab(text: 'Traffic Alerts'),
                  Tab(text: 'Charging Stations'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Route Stops Tab
                  _buildStopsList(),
                  // Traffic Alerts Tab
                  _buildTrafficAlertsList(),
                  // Charging Stations Tab
                  _buildChargingStationsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _stops.length,
      itemBuilder: (context, index) {
        final stop = _stops[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: stop.isCompleted ? Colors.green[100] : Colors.blue[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                stop.isCompleted ? Icons.check_circle : Icons.location_on,
                color: stop.isCompleted ? Colors.green : Colors.blue,
              ),
            ),
            title: Text(
              stop.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: stop.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text('Stop #${stop.sequence} • ${stop.arrivalTime} • ${stop.passengers} passengers'),
            trailing: Text(
              stop.isCompleted ? '✓' : '${index + 1}/${_stops.length}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: stop.isCompleted ? Colors.green : Colors.blue,
              ),
            ),
            onTap: () => _showStopDetails(stop),
          ),
        );
      },
    );
  }

  Widget _buildTrafficAlertsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _trafficAlerts.length,
      itemBuilder: (context, index) {
        final alert = _trafficAlerts[index];
        Color color;
        IconData icon;
        
        switch (alert['severity']) {
          case 'high':
            color = Colors.red;
            icon = Icons.error;
            break;
          case 'medium':
            color = Colors.orange;
            icon = Icons.warning;
            break;
          default:
            color = Colors.yellow;
            icon = Icons.info;
        }
        
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
              child: Icon(icon, color: color),
            ),
            title: Text(
              alert['title'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert['description']),
                const SizedBox(height: 4),
                Text('${alert['distance']} • Delay: ${alert['delay']}'),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                alert['severity'].toString().toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () => _showTrafficAlertDetails(alert),
          ),
        );
      },
    );
  }

  Widget _buildChargingStationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _nearbyStations.length,
      itemBuilder: (context, index) {
        final station = _nearbyStations[index];
        Color color;
        IconData icon;
        
        switch (station.stationType) {
          case 'ultraFast':
            color = Colors.purple;
            icon = Icons.bolt;
            break;
          case 'fast':
            color = Colors.orange;
            icon = Icons.ev_station;
            break;
          default:
            color = Colors.blue;
            icon = Icons.charging_station;
        }

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
              child: Icon(icon, color: color),
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
      },
    );
  }
}

// Custom Painter for Map Visualization
class _MapPainter extends CustomPainter {
  final List<MapStop> stops;
  final List<Map<String, dynamic>> trafficAlerts;
  final List<ChargingStation> stations;
  final double navigationProgress;
  final double zoom;

  _MapPainter({
    required this.stops,
    required this.trafficAlerts,
    required this.stations,
    required this.navigationProgress,
    required this.zoom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final _ = Offset(size.width / 2, size.height / 2);
    
    // Draw background
    final backgroundPaint = Paint()
      ..color = Colors.blue[50]!
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), backgroundPaint);
    
    // Draw route line
    _drawRoute(canvas, size);
    
    // Draw stops
    for (final stop in stops) {
      _drawStop(canvas, size, stop);
    }
    
    // Draw traffic alerts
    for (final alert in trafficAlerts) {
      _drawTrafficAlert(canvas, size, alert);
    }
    
    // Draw charging stations
    for (final station in stations) {
      _drawChargingStation(canvas, size, station);
    }
    
    // Draw navigation progress
    _drawNavigationProgress(canvas, size);
  }

  void _drawRoute(Canvas canvas, Size size) {
    if (stops.isEmpty) return;
    
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3 * zoom
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    
    // Draw curved route line
    for (int i = 0; i < stops.length; i++) {
      final offset = _getStopOffset(i, size);
      
      if (i == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        final prevOffset = _getStopOffset(i - 1, size);
        final controlPoint = Offset(
          (prevOffset.dx + offset.dx) / 2,
          (prevOffset.dy + offset.dy) / 2 - 50 * zoom,
        );
        
        path.quadraticBezierTo(
          controlPoint.dx,
          controlPoint.dy,
          offset.dx,
          offset.dy,
        );
      }
    }
    
    canvas.drawPath(path, paint);
  }

  void _drawStop(Canvas canvas, Size size, MapStop stop) {
    final index = stops.indexOf(stop);
    final offset = _getStopOffset(index, size);
    final radius = 6 * zoom;
    
    // Draw stop circle
    final circlePaint = Paint()
      ..color = stop.isCompleted ? Colors.green : Colors.purple
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(offset, radius, circlePaint);
    
    // Draw stop number
    final textPainter = TextPainter(
      text: TextSpan(
        text: stop.sequence.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 10 * zoom,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    
    textPainter.paint(canvas, offset - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  void _drawTrafficAlert(Canvas canvas, Size size, Map<String, dynamic> alert) {
    final progress = stops.isNotEmpty ? 0.3 : 0.5;
    final offset = Offset(
      size.width * 0.7,
      size.height * progress,
    );
    final radius = 8 * zoom;
    
    Color color;
    switch (alert['severity']) {
      case 'high':
        color = Colors.red;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      default:
        color = Colors.yellow;
    }
    
    // Draw alert icon
    final iconPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(offset, radius, iconPaint);
    
    // Draw warning triangle
    final trianglePath = Path()
      ..moveTo(offset.dx, offset.dy - radius)
      ..lineTo(offset.dx - radius, offset.dy + radius)
      ..lineTo(offset.dx + radius, offset.dy + radius)
      ..close();
    
    final trianglePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(trianglePath, trianglePaint);
  }

  void _drawChargingStation(Canvas canvas, Size size, ChargingStation station) {
    final offset = Offset(
      size.width * 0.3,
      size.height * 0.6,
    );
    final radius = 7 * zoom;
    
    Color color;
    switch (station.stationType) {
      case 'ultraFast':
        color = Colors.purple;
        break;
      case 'fast':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
    }
    
    // Draw station icon
    final stationPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(offset, radius, stationPaint);
    
    // Draw lightning bolt
    final boltPath = Path()
      ..moveTo(offset.dx, offset.dy - radius / 2)
      ..lineTo(offset.dx - radius / 3, offset.dy + radius / 6)
      ..lineTo(offset.dx - radius / 6, offset.dy + radius / 6)
      ..lineTo(offset.dx, offset.dy + radius / 2)
      ..lineTo(offset.dx + radius / 3, offset.dy - radius / 6)
      ..lineTo(offset.dx + radius / 6, offset.dy - radius / 6)
      ..close();
    
    final boltPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(boltPath, boltPaint);
  }

  void _drawNavigationProgress(Canvas canvas, Size size) {
    if (stops.isEmpty) return;
    
    final totalProgress = navigationProgress.clamp(0.0, 1.0);
    final segmentIndex = (totalProgress * (stops.length - 1)).floor();
    final segmentProgress = (totalProgress * (stops.length - 1)) - segmentIndex;
    
    if (segmentIndex < stops.length - 1) {
      final start = _getStopOffset(segmentIndex, size);
      final end = _getStopOffset(segmentIndex + 1, size);
      
      final currentOffset = Offset(
        start.dx + (end.dx - start.dx) * segmentProgress,
        start.dy + (end.dy - start.dy) * segmentProgress,
      );
      
      // Draw progress indicator
      final progressPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 4 * zoom
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(currentOffset, 6 * zoom, progressPaint);
    }
  }

  Offset _getStopOffset(int index, Size size) {
    final segmentWidth = size.width / (stops.length + 1);
    final x = segmentWidth * (index + 1);
    final y = size.height / 2 + (index % 2 == 0 ? -50 : 50) * zoom;
    
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MapStop {
  final String id;
  final String name;
  final int sequence;
  final String arrivalTime;
  bool isCompleted;
  final int passengers;

  MapStop({
    required this.id,
    required this.name,
    required this.sequence,
    required this.arrivalTime,
    required this.isCompleted,
    required this.passengers,
  });
}

class ChargingStation {
  final String name;
  final double distance;
  final int availablePorts;
  final int totalPorts;
  final String powerLevel;
  final int estimatedWaitTime;
  final double costPerKwh;
  final String stationType;

  ChargingStation({
    required this.name,
    required this.distance,
    required this.availablePorts,
    required this.totalPorts,
    required this.powerLevel,
    required this.estimatedWaitTime,
    required this.costPerKwh,
    required this.stationType,
  });
}
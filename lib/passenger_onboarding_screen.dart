//===========================================
// COMPLETE PASSENGER ONBOARDING SYSTEM
// ALL 4 SCREENS WITH FULL NAVIGATION
// 6-DIGIT CODE ONLY FOR PREFILLED PASSENGERS
// FIXED: ONBOARDED PASSENGERS PERSISTENCE
// ADDED: DAILY PASS SEATS IN PREFILLED (PURPLE COLOR)
// MODIFIED: REMOVED DAILY PASS FROM TOP INDICATOR
//===========================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//===========================================
// REAL-TIME DATA SERVICE
//===========================================
class RealTimeOnboardingService {
  static final RealTimeOnboardingService _instance = RealTimeOnboardingService._internal();
  factory RealTimeOnboardingService() => _instance;
  RealTimeOnboardingService._internal();

  TripRequest? currentTrip;
  final Map<String, DateTime> _activeCodes = {};
  final Map<String, String> _codeToPassengerMap = {};
  final _seatUpdatesController = StreamController<SeatUpdate>.broadcast();
  final _passengerOnboardedController = StreamController<OnboardedPassenger>.broadcast();
  final _bookingUpdatesController = StreamController<Booking>.broadcast();
  final List<VoidCallback> _listeners = [];
  
  // Track seat availability (35 total seats)
  final Map<int, bool> _seatAvailability = { for (var i = 1; i <= 35; i++) i: true };
  // Track pre-filled seats from trip
  final Map<int, Map<String, dynamic>> _preFilledSeatData = {};
  
  // Store all onboarded passengers globally
  final List<OnboardedPassenger> _globalOnboardedPassengers = [];
  
  // Track current trip ID to maintain state
  String? _currentTripId;

  Stream<SeatUpdate> get seatUpdates => _seatUpdatesController.stream;
  Stream<OnboardedPassenger> get passengerOnboarded => _passengerOnboardedController.stream;
  Stream<Booking> get bookingUpdates => _bookingUpdatesController.stream;
  
  // Get onboarded passengers for current trip
  List<OnboardedPassenger> getOnboardedPassengers(String tripId) {
    return _globalOnboardedPassengers
        .where((p) => p.tripId == tripId)
        .toList();
  }
  
  // Clear trip data when starting new trip
  void clearTripData(String tripId) {
    if (_currentTripId != tripId) {
      _currentTripId = tripId;
      _preFilledSeatData.clear();
      // Reset seat availability
      for (var i = 1; i <= 35; i++) {
        _seatAvailability[i] = true;
      }
    }
  }

  void addListener(VoidCallback callback) => _listeners.add(callback);
  void removeListener(VoidCallback callback) => _listeners.remove(callback);
  void _notifyListeners() {
    for (var fn in _listeners) {
      fn();
    }
  }

  // Get all seats with their status
  Map<int, Map<String, dynamic>> getAllSeatStatus(String tripId) {
    final Map<int, Map<String, dynamic>> seatStatus = {};
    
    // First, mark all onboarded passengers from this trip
    final tripOnboardedPassengers = getOnboardedPassengers(tripId);
    final Map<int, bool> onboardedSeats = {};
    for (var passenger in tripOnboardedPassengers) {
      int seatNum = int.tryParse(passenger.seatNumber) ?? 0;
      if (seatNum > 0) {
        onboardedSeats[seatNum] = true;
      }
    }
    
    for (var i = 1; i <= 35; i++) {
      // Check if seat is onboarded from previous session
      if (onboardedSeats.containsKey(i)) {
        seatStatus[i] = {
          'status': 'onboarded',
          'passengerName': tripOnboardedPassengers.firstWhere(
            (p) => p.seatNumber == i.toString(),
            orElse: () => tripOnboardedPassengers.first
          ).name,
          'isAvailable': false,
          'seatNumber': i,
          'onboarded': true,
          'passengerType': tripOnboardedPassengers.firstWhere(
            (p) => p.seatNumber == i.toString(),
            orElse: () => tripOnboardedPassengers.first
          ).passengerType,
        };
      }
      // Check if seat is pre-filled
      else if (_preFilledSeatData.containsKey(i)) {
        // Check if this pre-filled seat was onboarded
        final wasOnboarded = _preFilledSeatData[i]!['onboarded'] == true ||
                            onboardedSeats.containsKey(i);
        
        seatStatus[i] = {
          'status': 'prefilled',
          'passengerName': _preFilledSeatData[i]!['passengerName'],
          'isAvailable': false,
          'seatNumber': i,
          'onboarded': wasOnboarded,
          'passengerType': _preFilledSeatData[i]!['passengerType'] ?? 'Regular',
        };
        
        // Update pre-filled seat status
        if (wasOnboarded) {
          _preFilledSeatData[i]!['onboarded'] = true;
          _seatAvailability[i] = false;
        }
      }
      // Check if seat is available
      else if (_seatAvailability[i] == true) {
        seatStatus[i] = {
          'status': 'available',
          'passengerName': null,
          'isAvailable': true,
          'seatNumber': i,
          'passengerType': null,
        };
      }
      // Seat is booked/onboarded
      else {
        seatStatus[i] = {
          'status': 'onboarded',
          'passengerName': 'Passenger',
          'isAvailable': false,
          'seatNumber': i,
          'onboarded': true,
          'passengerType': 'Regular',
        };
      }
    }
    return seatStatus;
  }

  // Set pre-filled seats for a trip
  void setPreFilledSeats(String tripId) {
    // Only set if not already set for this trip
    if (_currentTripId == tripId && _preFilledSeatData.isNotEmpty) {
      return;
    }
    
    _currentTripId = tripId;
    _preFilledSeatData.clear();
    
    // Different pre-filled seats for different trips (YOUR ORIGINAL CONFIGURATION)
    if (tripId == 'TR001') {
      _addPreFilledSeats([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], 'Trip Passenger');
      // Add Daily Pass seats (some of the pre-filled seats will be Daily Pass)
      _addDailyPassSeats([10, 15, 20], 'Daily Pass'); // Seats 10, 15, 20 are Daily Pass
    } else if (tripId == 'TR002') {
      _addPreFilledSeats([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28], 'Trip Passenger');
      // Add Daily Pass seats
      _addDailyPassSeats([12, 18, 24, 28], 'Daily Pass'); // Seats 12, 18, 24, 28 are Daily Pass
    } else if (tripId == 'TR003') {
      _addPreFilledSeats([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26], 'Trip Passenger');
      // Add Daily Pass seats
      _addDailyPassSeats([8, 16, 22, 26], 'Daily Pass'); // Seats 8, 16, 22, 26 are Daily Pass
    } else if (tripId == 'TR004') {
      _addPreFilledSeats([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], 'Trip Passenger');
      // Add Daily Pass seats
      _addDailyPassSeats([9, 14, 19, 25, 29], 'Daily Pass'); // Seats 9, 14, 19, 25, 29 are Daily Pass
    } else if (tripId == 'TR005') {
      _addPreFilledSeats([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32], 'Trip Passenger');
      // Add Daily Pass seats
      _addDailyPassSeats([11, 17, 23, 30, 32], 'Daily Pass'); // Seats 11, 17, 23, 30, 32 are Daily Pass
    }
    
    // Mark these seats as unavailable in seat availability
    for (var seat in _preFilledSeatData.keys) {
      _seatAvailability[seat] = false;
    }
  }

  void _addPreFilledSeats(List<int> seats, String passengerName) {
    for (var seat in seats) {
      _preFilledSeatData[seat] = {
        'passengerName': '$passengerName - Seat $seat',
        'bookedTime': DateTime.now().subtract(const Duration(hours: 2)),
        'onboarded': false,
        'passengerType': 'Regular',
      };
    }
  }

  void _addDailyPassSeats(List<int> seats, String passengerName) {
    for (var seat in seats) {
      _preFilledSeatData[seat] = {
        'passengerName': '$passengerName - Seat $seat',
        'bookedTime': DateTime.now().subtract(const Duration(hours: 2)),
        'onboarded': false,
        'passengerType': 'Daily Pass',
        'dailyPassNumber': 'DP${1000 + seat}',
        'validUntil': DateTime.now().add(const Duration(days: 1)),
      };
    }
  }

  // Mark pre-filled seat as onboarded
  void onboardPreFilledSeat(int seatNumber, String passengerName, String code, String tripId) {
    if (_preFilledSeatData.containsKey(seatNumber)) {
      _preFilledSeatData[seatNumber]!['onboarded'] = true;
      _preFilledSeatData[seatNumber]!['passengerName'] = passengerName;
      _preFilledSeatData[seatNumber]!['onboardedTime'] = DateTime.now();
      _preFilledSeatData[seatNumber]!['onboardingCode'] = code;
      _preFilledSeatData[seatNumber]!['status'] = 'onboarded';
      _preFilledSeatData[seatNumber]!['tripId'] = tripId;
    }
    _seatAvailability[seatNumber] = false;
  }

  // Check if pre-filled seat is onboarded
  bool isPreFilledSeatOnboarded(int seatNumber) {
    return _preFilledSeatData.containsKey(seatNumber) && 
           _preFilledSeatData[seatNumber]!['onboarded'] == true;
  }

  // Get available seats
  List<int> getAvailableSeats() {
    return _seatAvailability.entries
        .where((entry) => entry.value && !_preFilledSeatData.containsKey(entry.key))
        .map((entry) => entry.key)
        .toList();
  }

  // Get pre-filled seats that are not yet onboarded
  List<int> getPendingPreFilledSeats() {
    return _preFilledSeatData.entries
        .where((entry) => entry.value['onboarded'] == false)
        .map((entry) => entry.key)
        .toList();
  }

  // Get pre-filled seats
  Map<int, Map<String, dynamic>> getPreFilledSeats() {
    return Map.from(_preFilledSeatData);
  }

  // Check if seat is available
  bool isSeatAvailable(int seatNumber) {
    return _seatAvailability[seatNumber] ?? false;
  }

  // Check if seat is pre-filled
  bool isSeatPreFilled(int seatNumber) {
    return _preFilledSeatData.containsKey(seatNumber);
  }

  // Get passenger type for a seat
  String? getPassengerType(int seatNumber) {
    return _preFilledSeatData[seatNumber]?['passengerType'];
  }

  // Check if seat is Daily Pass
  bool isDailyPassSeat(int seatNumber) {
    return _preFilledSeatData[seatNumber]?['passengerType'] == 'Daily Pass';
  }

  // Book a seat
  void bookSeat(int seatNumber) {
    if (_seatAvailability.containsKey(seatNumber)) {
      _seatAvailability[seatNumber] = false;
    }
  }

  // Release a seat (if needed)
  void releaseSeat(int seatNumber) {
    if (_seatAvailability.containsKey(seatNumber) && !_preFilledSeatData.containsKey(seatNumber)) {
      _seatAvailability[seatNumber] = true;
    }
  }

  // Verify onboarding code (always returns true for any 6-digit code)
  bool verifyOnboardingCode(String code, String passengerId) {
    if (code.length != 6) return false;
    // Accept any 6-digit code
    return true;
  }

  void sendSeatUpdate(SeatUpdate update) {
    _seatUpdatesController.add(update);
    _notifyListeners();
  }

  void sendPassengerOnboarded(OnboardedPassenger passenger) {
    // Add to global list
    _globalOnboardedPassengers.add(passenger);
    _passengerOnboardedController.add(passenger);
    _notifyListeners();
  }

  void sendBookingUpdate(Booking booking) {
    _bookingUpdatesController.add(booking);
    _notifyListeners();
  }

  void dispose() {
    _seatUpdatesController.close();
    _passengerOnboardedController.close();
    _bookingUpdatesController.close();
  }
}

//===========================================
// MODELS
//===========================================
class SeatUpdate {
  final int seatNumber; final String status; final String? passengerName;
  final DateTime timestamp; final String? bookingId; final String? passengerType;
  SeatUpdate({required this.seatNumber, required this.status, this.passengerName, required this.timestamp, this.bookingId, this.passengerType});
}

class OnboardedPassenger {
  final String id; final String name; final String seatNumber;
  final String onboardingCode; final DateTime onboardTime; final String status;
  final String? pnr; final String? phone; final String? idType; final String? idNumber;
  final bool isPrefilled;
  final String tripId;
  final String passengerType;
  final String? dailyPassNumber;
  
  OnboardedPassenger({
    required this.id, 
    required this.name, 
    required this.seatNumber,
    required this.onboardingCode, 
    required this.onboardTime, 
    required this.status,
    this.pnr, 
    this.phone, 
    this.idType, 
    this.idNumber,
    this.isPrefilled = false,
    required this.tripId,
    this.passengerType = 'Regular',
    this.dailyPassNumber,
  });
}

class TripRequest {
  final String id; final String route; final int passengerCount;
  final String pickup; final String dropoff; final double distance; final double fare;
  final String time; final String status; final String busNumber; final String driverName;
  final DateTime departureTime; final DateTime arrivalTime; final List<Passenger>? passengers;
  TripRequest({required this.id, required this.route, required this.passengerCount,
    required this.pickup, required this.dropoff, required this.distance, required this.fare,
    required this.time, required this.status, required this.busNumber, required this.driverName,
    required this.departureTime, required this.arrivalTime, this.passengers});
}

class Passenger {
  final String id; final String name; final String seatNumber;
  final String onboardingCode; final DateTime onboardTime; final String status;
  Passenger({required this.id, required this.name, required this.seatNumber,
    required this.onboardingCode, required this.onboardTime, required this.status});
}

class Booking {
  final String pnr; final int seatNumber; final String passengerName;
  final String phone; final String email; final String age; final String gender;
  final String idType; final String idNumber; final String? verificationCode;
  final DateTime verifiedAt; final DateTime bookingTime; final double price;
  final String deck; final String berth; final String status;
  final bool isOnboarded; final DateTime? onboardedTime; final String? onboardingCode;
  Booking({required this.pnr, required this.seatNumber, required this.passengerName,
    required this.phone, required this.email, required this.age, required this.gender,
    required this.idType, required this.idNumber, this.verificationCode,
    required this.verifiedAt, required this.bookingTime, required this.price,
    required this.deck, required this.berth, required this.status,
    this.isOnboarded = false, this.onboardedTime, this.onboardingCode});
}

//===========================================
// SEAT GRID WIDGET - Shows all 35 seats with status
//===========================================
class SeatGridWidget extends StatelessWidget {
  final Map<int, Map<String, dynamic>> seatStatus;
  final Function(int) onSeatSelected;

  const SeatGridWidget({
    super.key,
    required this.seatStatus,
    required this.onSeatSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.event_seat, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'SEAT AVAILABILITY (35 Total)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Legend
          Row(
            children: [
              _buildLegendItem(Colors.grey[300]!, 'Available'),
              const SizedBox(width: 16),
              _buildLegendItem(Colors.orange[100]!, 'Pre-filled (Regular)'),
              const SizedBox(width: 16),
              // _buildLegendItem(Colors.purple[100]!, 'Daily Pass'),
              // const SizedBox(width: 16),
              _buildLegendItem(Colors.green[100]!, 'Onboarded'),
            ],
          ),
          const SizedBox(height: 16),
          
          // Seat Grid - 7 columns x 5 rows = 35 seats
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 35,
            itemBuilder: (context, index) {
              final seatNumber = index + 1;
              final seatInfo = seatStatus[seatNumber];
              
              Color backgroundColor;
              IconData icon;
              String statusText = '';
              bool isOnboarded = seatInfo?['onboarded'] == true;
              String? passengerType = seatInfo?['passengerType'];
              
              if (seatInfo?['status'] == 'prefilled') {
                if (isOnboarded) {
                  backgroundColor = Colors.green[100]!;
                  icon = Icons.check_circle;
                  statusText = '✓$seatNumber';
                } else if (passengerType == 'Daily Pass') {
                  backgroundColor = Colors.purple[100]!;
                  icon = Icons.confirmation_number;
                  statusText = 'D$seatNumber';
                } else {
                  backgroundColor = Colors.orange[100]!;
                  icon = Icons.event_seat;
                  statusText = 'P$seatNumber';
                }
              } else if (seatInfo?['status'] == 'onboarded' || seatInfo?['status'] == 'booked') {
                backgroundColor = Colors.green[100]!;
                icon = Icons.person;
                statusText = 'B$seatNumber';
              } else {
                backgroundColor = Colors.grey[300]!;
                icon = Icons.chair;
                statusText = '$seatNumber';
              }
              
              return GestureDetector(
                onTap: () => onSeatSelected(seatNumber),
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: passengerType == 'Daily Pass' && !isOnboarded
                          ? Colors.purple
                          : seatInfo?['status'] == 'prefilled' && !isOnboarded
                              ? Colors.orange
                              : seatInfo?['status'] == 'onboarded' || isOnboarded
                                  ? Colors.green 
                                  : Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 20, color: isOnboarded ? Colors.green[700] : Colors.grey[700]),
                      const SizedBox(height: 2),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isOnboarded ? Colors.green[800] : Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Regular Pre-filled',
                  seatStatus.values.where((s) => s['status'] == 'prefilled' && s['onboarded'] != true && s['passengerType'] != 'Daily Pass').length.toString(),
                  Colors.orange,
                ),
                _buildSummaryItem(
                  'Daily Pass',
                  seatStatus.values.where((s) => s['passengerType'] == 'Daily Pass' && s['onboarded'] != true).length.toString(),
                  Colors.purple,
                ),
                _buildSummaryItem(
                  'Onboarded',
                  seatStatus.values.where((s) => s['status'] == 'onboarded' || s['onboarded'] == true).length.toString(),
                  Colors.green,
                ),
                _buildSummaryItem(
                  'Available',
                  seatStatus.values.where((s) => s['status'] == 'available').length.toString(),
                  Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[400]!),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

//===========================================
// SCREEN 1: MAIN ONBOARDING SCREEN (DRIVER VIEW)
//===========================================
class PassengerOnboardingScreen extends StatefulWidget {
  final dynamic currentTrip; final int currentPassengers; final int maxCapacity;
  const PassengerOnboardingScreen({super.key, required this.currentTrip, required this.currentPassengers, required this.maxCapacity});

  @override
  State<PassengerOnboardingScreen> createState() => _PassengerOnboardingScreenState();
}

class _PassengerOnboardingScreenState extends State<PassengerOnboardingScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  List<OnboardedPassenger> _onboardedPassengers = [];
  final _realtimeService = RealTimeOnboardingService();
  StreamSubscription? _seatUpdateSubscription;
  StreamSubscription? _passengerOnboardedSubscription;
  StreamSubscription? _bookingUpdateSubscription;
  Map<int, Map<String, dynamic>> _seatStatus = {};
  int _selectedSeatForManual = 0;

  @override
  void initState() {
    super.initState();
    _initializeTripSeats();
    _subscribeToRealtimeUpdates();
    _loadExistingPassengers();
  }

  void _loadExistingPassengers() {
    // Load existing onboarded passengers for this trip
    if (widget.currentTrip != null) {
      final existingPassengers = _realtimeService.getOnboardedPassengers(widget.currentTrip!.id);
      setState(() {
        _onboardedPassengers = existingPassengers;
      });
    }
  }

  void _initializeTripSeats() {
    // Set pre-filled seats based on trip ID
    if (widget.currentTrip != null) {
      _realtimeService.clearTripData(widget.currentTrip!.id);
      _realtimeService.setPreFilledSeats(widget.currentTrip!.id);
    }
    
    // Get initial seat status
    _seatStatus = _realtimeService.getAllSeatStatus(widget.currentTrip?.id ?? '');
  }

  void _subscribeToRealtimeUpdates() {
    _bookingUpdateSubscription = _realtimeService.bookingUpdates.listen((booking) {
      if (mounted) {
        setState(() {
          _seatStatus[booking.seatNumber] = {
            'status': 'booked',
            'passengerName': booking.passengerName,
            'isAvailable': false,
            'seatNumber': booking.seatNumber,
          };
          _realtimeService.bookSeat(booking.seatNumber);
        });
      }
    });
    
    _seatUpdateSubscription = _realtimeService.seatUpdates.listen((update) {
      if (mounted) {
        setState(() {
          _seatStatus[update.seatNumber] = {
            'status': update.status,
            'passengerName': update.passengerName,
            'isAvailable': false,
            'seatNumber': update.seatNumber,
            'passengerType': update.passengerType,
          };
          if (update.status == 'onboarded') {
            _realtimeService.bookSeat(update.seatNumber);
          }
        });
      }
    });
    
    // Listen to passenger onboarded events
    _passengerOnboardedSubscription = _realtimeService.passengerOnboarded.listen((passenger) {
      if (mounted) {
        // Only add if it belongs to current trip
        if (passenger.tripId == widget.currentTrip?.id) {
          setState(() {
            // Check if passenger already exists
            final exists = _onboardedPassengers.any((p) => 
              p.seatNumber == passenger.seatNumber && p.tripId == passenger.tripId
            );
            if (!exists) {
              _onboardedPassengers.add(passenger);
            }
          });
        }
      }
    });
  }

  //===========================================
  // ONBOARD PREFILLED PASSENGER - ONLY for pre-filled seats with 6-digit code
  //===========================================
  Future<void> _onboardPreFilledPassenger(String code, int seatNumber) async {
    if (code.isEmpty) { 
      _showSnackBar('Please enter a 6-digit code', Colors.red); 
      return; 
    }
    if (code.length != 6) { 
      _showSnackBar('Code must be 6 digits', Colors.red); 
      return; 
    }
    
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Get passenger name from pre-filled data
    String passengerName = _seatStatus[seatNumber]?['passengerName'] ?? 'Trip Passenger';
    String passengerType = _seatStatus[seatNumber]?['passengerType'] ?? 'Regular';
    
    // Mark pre-filled seat as onboarded
    _realtimeService.onboardPreFilledSeat(seatNumber, passengerName, code, widget.currentTrip!.id);
    
    final passenger = OnboardedPassenger(
      id: 'P${DateTime.now().millisecondsSinceEpoch}', 
      name: passengerName,
      seatNumber: seatNumber.toString(), 
      onboardingCode: code,
      onboardTime: DateTime.now(), 
      status: 'Active',
      isPrefilled: true,
      pnr: 'PNR${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      tripId: widget.currentTrip!.id,
      passengerType: passengerType,
      dailyPassNumber: passengerType == 'Daily Pass' ? 'DP${1000 + seatNumber}' : null,
    );
    
    _realtimeService.sendPassengerOnboarded(passenger);
    _realtimeService.sendSeatUpdate(SeatUpdate(
      seatNumber: seatNumber,
      status: 'onboarded',
      passengerName: passenger.name,
      timestamp: DateTime.now(),
      passengerType: passengerType,
    ));
    
    setState(() { 
      _seatStatus[seatNumber] = {
        ..._seatStatus[seatNumber]!,
        'status': 'prefilled',
        'onboarded': true,
        'passengerName': passenger.name,
        'isAvailable': false,
        'passengerType': passengerType,
      };
      _isLoading = false; 
      _codeController.clear();
      _selectedSeatForManual = 0;
    });
    
    _showSeatConfirmedDialog(passenger, isPrefilled: true);
  }

  //===========================================
  // ONBOARD NEW PASSENGER - For available seats (NO CODE REQUIRED)
  //===========================================
  void _onboardNewPassenger({
    required int seatNumber,
    required String name, 
    required String phone, 
    String? idType, 
    String? idNumber,
  }) {
    // Check if seat is still available
    if (!_realtimeService.isSeatAvailable(seatNumber)) {
      _showSnackBar('Seat $seatNumber is no longer available!', Colors.red);
      return;
    }
    
    final passenger = OnboardedPassenger(
      id: 'P${DateTime.now().millisecondsSinceEpoch}', 
      name: name, 
      seatNumber: seatNumber.toString(),
      onboardingCode: 'MANUAL-${DateTime.now().millisecond}', 
      onboardTime: DateTime.now(), 
      status: 'Active',
      pnr: 'PNR${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      phone: phone, 
      idType: idType, 
      idNumber: idNumber,
      isPrefilled: false,
      tripId: widget.currentTrip!.id,
      passengerType: 'Regular',
    );
    
    _realtimeService.sendPassengerOnboarded(passenger);
    _realtimeService.sendSeatUpdate(SeatUpdate(
      seatNumber: seatNumber,
      status: 'onboarded',
      passengerName: passenger.name,
      timestamp: DateTime.now(),
      passengerType: 'Regular',
    ));
    
    setState(() {
      _seatStatus[seatNumber] = {
        'status': 'onboarded',
        'passengerName': passenger.name,
        'isAvailable': false,
        'seatNumber': seatNumber,
        'passengerType': 'Regular',
      };
      _realtimeService.bookSeat(seatNumber);
    });
    
    _showSeatConfirmedDialog(passenger, isPrefilled: false);
  }

  void _onboardingByCode(String code) {
    // ONLY onboard pre-filled passengers with code
    if (_selectedSeatForManual > 0 && 
        _seatStatus[_selectedSeatForManual]?['status'] == 'prefilled' &&
        _seatStatus[_selectedSeatForManual]?['onboarded'] != true) {
      _onboardPreFilledPassenger(code, _selectedSeatForManual);
    } else {
      // No valid pre-filled seat selected for code entry
      _showSnackBar('Please select an ORANGE or PURPLE pre-filled seat to enter 6-digit code', Colors.orange);
      _codeController.clear();
    }
  }

  void _simulateQRScan() {
    // Simulate QR code scan - generate random 6-digit code
    final randomCode = (Random().nextInt(900000) + 100000).toString();
    _codeController.text = randomCode;
    
    // ONLY onboard pre-filled passengers with QR code
    if (_selectedSeatForManual > 0 && 
        _seatStatus[_selectedSeatForManual]?['status'] == 'prefilled' &&
        _seatStatus[_selectedSeatForManual]?['onboarded'] != true) {
      _onboardPreFilledPassenger(randomCode, _selectedSeatForManual);
    } else {
      _showSnackBar('QR code is ONLY for pre-filled passengers. Select an ORANGE or PURPLE seat first.', Colors.orange);
      _codeController.clear();
    }
  }

  void _onSeatSelected(int seatNumber) {
    setState(() {
      _selectedSeatForManual = seatNumber;
    });
    
    // Check seat status
    String status = _seatStatus[seatNumber]?['status'] ?? '';
    bool isOnboarded = _seatStatus[seatNumber]?['onboarded'] == true;
    String? passengerType = _seatStatus[seatNumber]?['passengerType'];
    
    if (status == 'available') {
      // Available seat - open manual onboarding for new passenger (NO CODE)
      _showManualOnboardingDialog(seatNumber);
    } else if (status == 'prefilled' && !isOnboarded) {
      if (passengerType == 'Daily Pass') {
        _showSnackBar('Seat $seatNumber: Daily Pass - Enter 6-digit code to onboard', Colors.purple);
      } else {
        _showSnackBar('Seat $seatNumber: Enter 6-digit code to onboard pre-filled passenger', Colors.orange);
      }
      // Focus on code field
      FocusScope.of(context).requestFocus(FocusNode());
    } else if (status == 'prefilled' && isOnboarded) {
      _showSnackBar('Seat $seatNumber is already onboarded', Colors.green);
      setState(() {
        _selectedSeatForManual = 0;
      });
    } else {
      _showSnackBar('Seat $seatNumber is already taken', Colors.red);
      setState(() {
        _selectedSeatForManual = 0;
      });
    }
  }

  void _showManualOnboardingDialog(int seatNumber) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final idNumberController = TextEditingController();
    String selectedIdType = 'Aadhar Card';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('New Passenger Onboarding', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_seat, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text('Seat Number: $seatNumber', 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'New passenger - No code required',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: nameController, 
              decoration: const InputDecoration(
                labelText: 'Passenger Name *', 
                border: OutlineInputBorder(), 
                prefixIcon: Icon(Icons.person)
              )
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: phoneController, 
              decoration: const InputDecoration(
                labelText: 'Mobile Number *', 
                border: OutlineInputBorder(), 
                prefixIcon: Icon(Icons.phone)
              ), 
              keyboardType: TextInputType.phone
            ),
            
            const SizedBox(height: 12),
            
            DropdownButtonFormField<String>(
              value: selectedIdType,
              decoration: const InputDecoration(
                labelText: 'ID Type (Optional)', 
                border: OutlineInputBorder(), 
                prefixIcon: Icon(Icons.badge)
              ),
              items: ['Aadhar Card', 'Driving License', 'Voter ID', 'Passport', 'None'].map((type) => 
                DropdownMenuItem(value: type, child: Text(type))
              ).toList(),
              onChanged: (value) { 
                if (value != null) {
                  setState(() {
                    selectedIdType = value;
                    if (value == 'None') {
                      idNumberController.clear();
                    }
                  });
                }
              },
            ),
            
            if (selectedIdType != 'None') ...[
              const SizedBox(height: 12),
              TextField(
                controller: idNumberController, 
                decoration: InputDecoration(
                  labelText: '$selectedIdType Number', 
                  border: const OutlineInputBorder(), 
                  prefixIcon: const Icon(Icons.numbers),
                  hintText: 'Optional',
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  const Text(
                    'PAYMENT QR CODE',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.qr_code_2,
                              size: 100,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scan to pay ₹1,500.00',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        const Text(
                          'UPI ID: busonboard@paytm',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && 
                  phoneController.text.isNotEmpty) {
                
                Navigator.pop(context);
                _onboardNewPassenger(
                  seatNumber: seatNumber,
                  name: nameController.text, 
                  phone: phoneController.text, 
                  idType: selectedIdType == 'None' ? null : selectedIdType, 
                  idNumber: selectedIdType == 'None' ? null : idNumberController.text,
                );
              } else {
                _showSnackBar('Please fill all required fields', Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, 
              foregroundColor: Colors.white
            ),
            child: const Text('CONFIRM SEAT & ONBOARD'),
          ),
        ],
      ),
    );
  }

  void _showSeatConfirmedDialog(OnboardedPassenger passenger, {required bool isPrefilled}) {
    showDialog(
      context: context, 
      builder: (BuildContext context) => AlertDialog(
        title: Text(isPrefilled ? '✅ Pre-filled Passenger Onboarded!' : '✅ Seat Confirmed!'), 
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(isPrefilled ? Icons.check_circle : Icons.event_seat, 
            size: 60, color: Colors.green),
          const SizedBox(height: 16), 
          Text('Passenger: ${passenger.name}'), 
          Text('Seat: ${passenger.seatNumber}'),
          if (passenger.passengerType == 'Daily Pass') 
            const Text('Daily Pass verified', style: TextStyle(fontSize: 12, color: Colors.purple)),
          if (passenger.isPrefilled && passenger.passengerType != 'Daily Pass') 
            const Text('Pre-filled booking verified & onboarded', style: TextStyle(fontSize: 12, color: Colors.orange)),
          Text('Time: ${DateFormat('hh:mm:ss a').format(passenger.onboardTime)}'),
        ]), 
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('CONTINUE'))],
      )
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color)
    );
  }

  void _finishOnboarding() => Navigator.pop(context, _onboardedPassengers.length);

  @override
  void dispose() { 
    _codeController.dispose(); 
    _seatUpdateSubscription?.cancel(); 
    _passengerOnboardedSubscription?.cancel();
    _bookingUpdateSubscription?.cancel(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    final totalCapacity = 35;
    final regularPrefilledCount = _seatStatus.values.where((s) => s['status'] == 'prefilled' && s['onboarded'] != true && s['passengerType'] != 'Daily Pass').length;
    final dailyPassCount = _seatStatus.values.where((s) => s['passengerType'] == 'Daily Pass' && s['onboarded'] != true).length;
    final onboardedCount = _onboardedPassengers.length;
    final availableCount = _seatStatus.values.where((s) => s['status'] == 'available').length;
    final currentTotal = regularPrefilledCount + dailyPassCount + onboardedCount;
    final remainingSeats = availableCount;
    final progress = totalCapacity > 0 ? currentTotal / totalCapacity : 0.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Passenger Onboarding'),
        backgroundColor: Colors.blue[800], 
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), 
          onPressed: () => Navigator.pop(context, _onboardedPassengers.length)
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner), 
            onPressed: _simulateQRScan, 
            tooltip: 'Scan QR Code (Pre-filled only)'
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[800]!, Colors.blue[600]!]
              ), 
              borderRadius: BorderRadius.circular(15)
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('LIVE ONBOARDING', 
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.2)
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    children: [
                      Icon(Icons.fiber_manual_record, size: 10, color: Colors.white), 
                      SizedBox(width: 4), 
                      Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))
                    ]
                  )
                ),
              ]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Trip #${widget.currentTrip?.id ?? 'TR005'}', 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                  Text(widget.currentTrip?.route ?? 'Express Service 5', 
                    style: const TextStyle(fontSize: 14, color: Colors.white70)
                  ),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      Text('$onboardedCount/$totalCapacity', 
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)
                      ), 
                      const Text('Onboarded', style: TextStyle(fontSize: 12, color: Colors.white70))
                    ]
                  )
                ),
              ]),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress, 
                backgroundColor: Colors.white.withValues(alpha: 0.3), 
                color: Colors.green, 
                minHeight: 12, 
                borderRadius: BorderRadius.circular(6)
              ),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('$remainingSeats seats available', 
                  style: const TextStyle(fontSize: 12, color: Colors.white)
                ),
                // REMOVED Daily Pass from top indicator - only showing Regular and Onboarded now
                Text('Regular: $regularPrefilledCount • Onboarded: $onboardedCount', 
                  style: const TextStyle(fontSize: 12, color: Colors.white70)
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 20),

          SeatGridWidget(
            seatStatus: _seatStatus,
            onSeatSelected: _onSeatSelected,
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(15), 
              boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10)]
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  const Icon(Icons.qr_code, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Text('PREFILLED PASSENGER BOARDING', 
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange)
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '6-digit code is ONLY for pre-filled passengers (ORANGE & PURPLE seats)',
                        style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.airline_seat_recline_normal, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Available seats (GREY): Click to onboard new passenger - No code required',
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: _selectedSeatForManual > 0 && 
                                  _seatStatus[_selectedSeatForManual]?['status'] == 'prefilled' &&
                                  _seatStatus[_selectedSeatForManual]?['onboarded'] != true
                          ? 'Enter 6-digit Code for Seat $_selectedSeatForManual'
                          : 'Select ORANGE or PURPLE seat first',
                        prefixIcon: const Icon(Icons.qr_code),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        hintText: '000000',
                        counterText: '',
                        enabled: _selectedSeatForManual > 0 && 
                                _seatStatus[_selectedSeatForManual]?['status'] == 'prefilled' &&
                                _seatStatus[_selectedSeatForManual]?['onboarded'] != true,
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      onSubmitted: _onboardingByCode,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: _selectedSeatForManual > 0 && 
                              _seatStatus[_selectedSeatForManual]?['status'] == 'prefilled' &&
                              _seatStatus[_selectedSeatForManual]?['onboarded'] != true
                          ? Colors.orange[700] 
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: _selectedSeatForManual > 0 && 
                                _seatStatus[_selectedSeatForManual]?['status'] == 'prefilled' &&
                                _seatStatus[_selectedSeatForManual]?['onboarded'] != true
                          ? _simulateQRScan 
                          : null,
                      icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                      tooltip: 'Scan QR Code (Pre-filled only)',
                    ),
                  ),
                ],
              ),
              if (_selectedSeatForManual > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _seatStatus[_selectedSeatForManual]?['passengerType'] == 'Daily Pass'
                        ? Colors.purple[50]
                        : _seatStatus[_selectedSeatForManual]?['status'] == 'prefilled'
                            ? Colors.orange[50]
                            : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _seatStatus[_selectedSeatForManual]?['passengerType'] == 'Daily Pass'
                          ? Colors.purple
                          : _seatStatus[_selectedSeatForManual]?['status'] == 'prefilled'
                              ? Colors.orange
                              : Colors.grey,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _seatStatus[_selectedSeatForManual]?['passengerType'] == 'Daily Pass'
                            ? Icons.confirmation_number
                            : _seatStatus[_selectedSeatForManual]?['status'] == 'prefilled'
                                ? Icons.event_seat
                                : Icons.chair,
                        size: 16, 
                        color: _seatStatus[_selectedSeatForManual]?['passengerType'] == 'Daily Pass'
                            ? Colors.purple[800]
                            : _seatStatus[_selectedSeatForManual]?['status'] == 'prefilled'
                                ? Colors.orange[800]
                                : Colors.grey[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seat $_selectedSeatForManual',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _seatStatus[_selectedSeatForManual]?['passengerType'] == 'Daily Pass'
                                    ? Colors.purple[800]
                                    : _seatStatus[_selectedSeatForManual]?['status'] == 'prefilled'
                                        ? Colors.orange[800]
                                        : Colors.grey[800],
                              ),
                            ),
                            Text(
                              _seatStatus[_selectedSeatForManual]?['passengerType'] == 'Daily Pass'
                                  ? 'Daily Pass passenger - Enter 6-digit code'
                                  : _seatStatus[_selectedSeatForManual]?['status'] == 'prefilled'
                                      ? 'Pre-filled passenger - Enter 6-digit code'
                                      : 'Available seat - Click to onboard new passenger (No code)',
                              style: TextStyle(
                                fontSize: 11,
                                color: _seatStatus[_selectedSeatForManual]?['passengerType'] == 'Daily Pass'
                                    ? Colors.purple[600]
                                    : _seatStatus[_selectedSeatForManual]?['status'] == 'prefilled'
                                        ? Colors.orange[600]
                                        : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          setState(() {
                            _selectedSeatForManual = 0;
                            _codeController.clear();
                          });
                        },
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, 
                child: ElevatedButton.icon(
                  onPressed: _isLoading 
                      ? null 
                      : (_selectedSeatForManual > 0 && 
                         _seatStatus[_selectedSeatForManual]?['status'] == 'prefilled' &&
                         _seatStatus[_selectedSeatForManual]?['onboarded'] != true)
                        ? () => _onboardingByCode(_codeController.text)
                        : null,
                  icon: const Icon(Icons.qr_code),
                  label: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                    : Text(_selectedSeatForManual > 0 && 
                           _seatStatus[_selectedSeatForManual]?['status'] == 'prefilled' &&
                           _seatStatus[_selectedSeatForManual]?['onboarded'] != true
                        ? 'VERIFY & ONBOARD PREFILLED PASSENGER'
                        : 'SELECT ORANGE OR PURPLE SEAT FIRST'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedSeatForManual > 0 && 
                                    _seatStatus[_selectedSeatForManual]?['status'] == 'prefilled' &&
                                    _seatStatus[_selectedSeatForManual]?['onboarded'] != true
                        ? Colors.orange[700] 
                        : Colors.grey[500], 
                    foregroundColor: Colors.white, 
                    padding: const EdgeInsets.symmetric(vertical: 16), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(15), 
              boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10)]
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('LIVE ONBOARDING FEED', 
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), 
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
                  child: const Text('REAL-TIME', 
                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)
                  )
                ),
              ]),
              const SizedBox(height: 16),
              StreamBuilder<SeatUpdate>(
                stream: _realtimeService.seatUpdates,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      height: 60, 
                      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                      child: const Center(
                        child: Text('Waiting for passenger activity...', 
                          style: TextStyle(color: Colors.grey)
                        )
                      )
                    );
                  }
                  final update = snapshot.data!;
                  return Container(
                    padding: const EdgeInsets.all(12), 
                    decoration: BoxDecoration(
                      color: Colors.green[50], 
                      borderRadius: BorderRadius.circular(8), 
                      border: Border.all(color: Colors.green[200]!)
                    ),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 16, 
                        backgroundColor: Colors.green[100], 
                        child: const Icon(Icons.check_circle, size: 16, color: Colors.green)
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Passenger Boarded', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${update.passengerName ?? 'Passenger'} - Seat ${update.seatNumber}', 
                            style: TextStyle(fontSize: 12, color: Colors.grey[700])
                          ),
                          if (update.passengerType != null)
                            Text('Type: ${update.passengerType}', 
                              style: TextStyle(fontSize: 10, color: update.passengerType == 'Daily Pass' ? Colors.purple : Colors.orange)
                            ),
                        ]),
                      ),
                      Text(DateFormat('HH:mm:ss').format(update.timestamp), 
                        style: TextStyle(fontSize: 11, color: Colors.grey[600])
                      ),
                    ]),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('ONBOARDED PASSENGERS', 
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), 
                  decoration: BoxDecoration(color: Colors.blue[600], borderRadius: BorderRadius.circular(20)),
                  child: Text(_onboardedPassengers.length.toString(), 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  )
                ),
              ]),
              const SizedBox(height: 16),
              if (_onboardedPassengers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Column(children: [
                    Icon(Icons.airline_seat_recline_normal, size: 60, color: Colors.grey),
                    SizedBox(height: 16), 
                    Text('No passengers onboarded yet', style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 8), 
                    Text('Select ORANGE seat and enter code for pre-filled passengers', 
                      style: TextStyle(fontSize: 12, color: Colors.grey), 
                      textAlign: TextAlign.center
                    ),
                    SizedBox(height: 4),
                    Text('Select PURPLE seat for Daily Pass passengers', 
                      style: TextStyle(fontSize: 12, color: Colors.purple), 
                      textAlign: TextAlign.center
                    ),
                    SizedBox(height: 4),
                    Text('Click GREY seat for new passenger onboarding (No code)', 
                      style: TextStyle(fontSize: 12, color: Colors.grey), 
                      textAlign: TextAlign.center
                    ),
                  ]),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _onboardedPassengers.length,
                  itemBuilder: (context, index) {
                    final p = _onboardedPassengers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: p.passengerType == 'Daily Pass' 
                              ? Colors.purple[100] 
                              : p.isPrefilled 
                                  ? Colors.orange[100] 
                                  : Colors.green[100], 
                          child: Icon(
                            p.passengerType == 'Daily Pass' 
                                ? Icons.confirmation_number
                                : p.isPrefilled 
                                    ? Icons.event_seat 
                                    : Icons.person, 
                            color: p.passengerType == 'Daily Pass' 
                                ? Colors.purple 
                                : p.isPrefilled 
                                    ? Colors.orange 
                                    : Colors.green
                          )
                        ),
                        title: Text(p.name), 
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, 
                          children: [
                            Text('Seat: ${p.seatNumber}'), 
                            if (p.passengerType == 'Daily Pass') 
                              Text('Daily Pass ${p.dailyPassNumber ?? ''}', style: const TextStyle(fontSize: 11, color: Colors.purple)),
                            if (p.isPrefilled && p.passengerType != 'Daily Pass') 
                              const Text('Pre-filled passenger (Code verified)', style: TextStyle(fontSize: 11, color: Colors.orange)),
                            if (!p.isPrefilled) 
                              const Text('New passenger (No code)', style: TextStyle(fontSize: 11, color: Colors.green)),
                            if (p.pnr != null) Text('PNR: ${p.pnr}', style: const TextStyle(fontSize: 11)),
                          ]
                        ),
                        trailing: Text(DateFormat('hh:mm a').format(p.onboardTime), 
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                        ),
                      ),
                    );
                  },
                ),
            ]),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity, 
            child: ElevatedButton.icon(
              onPressed: _finishOnboarding,
              icon: const Icon(Icons.done_all),
              label: Text('COMPLETE ONBOARDING (${_onboardedPassengers.length} new)', 
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800], 
                foregroundColor: Colors.white, 
                padding: const EdgeInsets.symmetric(vertical: 16), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

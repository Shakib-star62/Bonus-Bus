import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  final double earningsToday;

  const ProfileScreen({
    super.key,
    required this.earningsToday,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double _walletBalance = 2875.50;
  final double _todayEarnings = 287.50;
  final double _weeklyEarnings = 1542.75;
  List<WalletTransaction> _transactions = [];
  List<Incentive> _incentives = [];

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    _transactions = [
      WalletTransaction(
        id: 'T001',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        amount: 45.00,
        type: 'trip_earnings',
        description: 'Trip #TR001 - Downtown Express',
        status: 'completed',
      ),
      WalletTransaction(
        id: 'T002',
        date: DateTime.now().subtract(const Duration(hours: 4)),
        amount: 85.00,
        type: 'trip_earnings',
        description: 'Trip #TR002 - Airport Shuttle',
        status: 'completed',
      ),
      WalletTransaction(
        id: 'T003',
        date: DateTime.now().subtract(const Duration(days: 1)),
        amount: 32.50,
        type: 'trip_earnings',
        description: 'Trip #TR003 - School Route',
        status: 'completed',
      ),
      WalletTransaction(
        id: 'I001',
        date: DateTime.now().subtract(const Duration(days: 3)),
        amount: 100.00,
        type: 'incentive',
        description: 'Safety Bonus - Accident-free month',
        status: 'credited',
      ),
      WalletTransaction(
        id: 'B001',
        date: DateTime.now().subtract(const Duration(days: 7)),
        amount: 50.00,
        type: 'bonus',
        description: 'Overtime Duty - Weekend shift',
        status: 'credited',
      ),
    ];

    _incentives = [
      Incentive(
        id: 'INC001',
        title: 'Safety Performance',
        description: 'Maintain accident-free record',
        amount: 100.00,
        type: 'safety',
        status: 'available',
      ),
      Incentive(
        id: 'INC002',
        title: 'Fuel Efficiency',
        description: 'Achieve 2.5+ mi/kWh average',
        amount: 75.00,
        type: 'efficiency',
        status: 'available',
      ),
      Incentive(
        id: 'INC003',
        title: 'On-time Performance',
        description: '95% on-time arrivals this month',
        amount: 50.00,
        type: 'punctuality',
        status: 'pending',
      ),
      Incentive(
        id: 'INC004',
        title: 'Overtime Duty',
        description: 'Weekend and holiday shifts',
        amount: 25.00,
        type: 'overtime',
        status: 'claimed',
      ),
      Incentive(
        id: 'INC005',
        title: 'Passenger Rating',
        description: 'Maintain 4.8+ average rating',
        amount: 25.00,
        type: 'rating',
        status: 'available',
      ),
    ];
  }

  void _showVehicleDocuments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleDocumentsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // This removes the back button
          title: const Text('Profile & Wallet'),
          backgroundColor: const Color(0xFF0A2472), // Dark blue
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Profile'),
              Tab(text: 'Wallet'),
              Tab(text: 'Incentives'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Profile Tab
            _buildProfileTab(context),
            // Wallet Tab
            _buildWalletTab(context),
            // Incentives Tab
            _buildIncentivesTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF0A2472).withAlpha(20),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Color(0xFF0A2472),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'SAMUEL',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: EVB-2024-007',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Quick Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProfileStat('Trips', '142', Icons.directions_bus),
                    const SizedBox(width: 20),
                    _buildProfileStat('Rating', '4.8★', Icons.star),
                    const SizedBox(width: 20),
                    _buildProfileStat('Hours', '750', Icons.timer),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Personal Information
          const Text(
            'PERSONAL INFORMATION',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(25),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildProfileDetail('Phone', '+91 9876543210', Icons.phone),
                const Divider(),
                _buildProfileDetail('Email', 'driver.samuel@bonusbus.com', Icons.email),
                const Divider(),
                _buildProfileDetail('License', 'DL-2020-456789', Icons.badge),
                const Divider(),
                _buildProfileDetail('Joined', 'Jan 15, 2023', Icons.calendar_today),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Vehicle Information
          const Text(
            'VEHICLE INFORMATION',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(25),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildProfileDetail('Vehicle Type', 'Tesla eBus Pro', Icons.directions_bus),
                const Divider(),
                _buildProfileDetail('Registration', 'EVB-2024-007', Icons.confirmation_number),
                const Divider(),
                _buildVehicleDocuments(),
                const Divider(),
                _buildProfileDetail('Capacity', '35 passengers', Icons.people),
                const Divider(),
                _buildProfileDetail('Battery', '500 kWh', Icons.battery_full),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Action Buttons
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _editProfile(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('EDIT PROFILE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A2472),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0A2472).withAlpha(10),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: const Color(0xFF0A2472), size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
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

  Widget _buildProfileDetail(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0A2472)),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDocuments() {
    return InkWell(
      onTap: () => _showVehicleDocuments(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Color(0xFF0A2472)),
            const SizedBox(width: 15),
            const Expanded(
              child: Text(
                'Vehicle Documents',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  'View Documents',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue[700],
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Wallet Balance
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A2472), // Dark blue
                  Color(0xFF4263EB), // Medium blue
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0A2472).withAlpha(75),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'TOTAL BALANCE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${_walletBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildWalletStat('Today', _todayEarnings, const Color(0xFF4CAF50)), // Green
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildWalletStat('This Week', _weeklyEarnings, Colors.orange),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildWalletStat('Available', _walletBalance, Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Quick Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _requestPayout(context),
                  icon: const Icon(Icons.monetization_on),
                  label: const Text('REQUEST PAYOUT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50), // Green
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewBankDetails(context),
                  icon: const Icon(Icons.account_balance),
                  label: const Text('BANK DETAILS'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF0A2472)),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Recent Transactions
          const Text(
            'RECENT TRANSACTIONS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          
          ..._transactions.map((transaction) => _buildTransactionCard(transaction)),
          
          const SizedBox(height: 20),
          
          // View All Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _viewAllTransactions,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0A2472)),
              ),
              child: const Text('VIEW ALL TRANSACTIONS'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletStat(String period, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            period,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(WalletTransaction transaction) {
    Color color;
    IconData icon;
    String typeLabel;

    switch (transaction.type) {
      case 'trip_earnings':
        color = const Color(0xFF0A2472); // Dark blue
        icon = Icons.directions_bus;
        typeLabel = 'Trip Earnings';
        break;
      case 'incentive':
        color = const Color(0xFF4CAF50); // Green
        icon = Icons.card_giftcard;
        typeLabel = 'Incentive';
        break;
      case 'bonus':
        color = Colors.orange;
        icon = Icons.emoji_events;
        typeLabel = 'Bonus';
        break;
      default:
        color = Colors.grey;
        icon = Icons.payment;
        typeLabel = 'Payment';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          typeLabel,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.description),
            Text(
              DateFormat('MMM dd, hh:mm a').format(transaction.date),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$${transaction.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              transaction.status.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: transaction.status == 'completed' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncentivesTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Incentives
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1B5E20), // Dark green
                  Color(0xFF4CAF50), // Green
                ],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.white, size: 40),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL INCENTIVES EARNED',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '\$${_getTotalIncentives()}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Available for payout',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Available Incentives
          const Text(
            'AVAILABLE INCENTIVES',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          
          ..._incentives.where((i) => i.status == 'available').map((incentive) => _buildIncentiveCard(incentive)),
          
          const SizedBox(height: 20),
          
          // Overtime Duty Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withAlpha(10),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFF4CAF50).withAlpha(50)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer, color: Color(0xFF4CAF50), size: 30),
                    const SizedBox(width: 10),
                    const Text(
                      'OVERTIME DUTY',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Earn extra by taking weekend, holiday, or night shifts',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    _buildOvertimeStat('Weekend', '+25%', Icons.weekend),
                    const SizedBox(width: 15),
                    _buildOvertimeStat('Holiday', '+50%', Icons.celebration),
                    const SizedBox(width: 15),
                    _buildOvertimeStat('Night', '+30%', Icons.nightlight),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _applyForOvertime(context),
                    icon: const Icon(Icons.add_circle),
                    label: const Text('APPLY FOR OVERTIME'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Pending & Claimed Incentives
          const Text(
            'PENDING & CLAIMED',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          
          ..._incentives.where((i) => i.status != 'available').map((incentive) => _buildIncentiveCard(incentive)),
        ],
      ),
    );
  }

  Widget _buildIncentiveCard(Incentive incentive) {
    Color color;
    IconData icon;
    
    switch (incentive.type) {
      case 'safety':
        color = const Color(0xFF4CAF50); // Green
        icon = Icons.safety_check;
        break;
      case 'efficiency':
        color = const Color(0xFF0A2472); // Dark blue
        icon = Icons.eco;
        break;
      case 'punctuality':
        color = Colors.orange;
        icon = Icons.timer;
        break;
      case 'overtime':
        color = const Color(0xFF4CAF50); // Green
        icon = Icons.timer;
        break;
      case 'rating':
        color = const Color(0xFF0A2472); // Dark blue
        icon = Icons.star;
        break;
      default:
        color = Colors.grey;
        icon = Icons.card_giftcard;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          incentive.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(incentive.description),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${incentive.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getIncentiveStatusColor(incentive.status),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                incentive.status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _claimIncentive(context, incentive),
      ),
    );
  }

  Widget _buildOvertimeStat(String type, String bonus, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF4CAF50).withAlpha(50)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF4CAF50), size: 20),
            const SizedBox(height: 8),
            Text(
              bonus,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
            Text(
              type,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getIncentiveStatusColor(String status) {
    switch (status) {
      case 'available':
        return const Color(0xFF4CAF50); // Green
      case 'pending':
        return Colors.orange;
      case 'claimed':
        return const Color(0xFF0A2472); // Dark blue
      default:
        return Colors.grey;
    }
  }

  String _getTotalIncentives() {
    double total = 0;
    for (var incentive in _incentives) {
      total += incentive.amount;
    }
    return total.toStringAsFixed(2);
  }

  void _editProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(labelText: 'Email'),
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
                  content: Text('Profile updated successfully'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A2472),
            ),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }


  void _requestPayout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Payout'),
        content: Text('You have \$${_walletBalance.toStringAsFixed(2)} available for payout.\n\n'
            'Payouts are processed within 24-48 hours to your registered bank account.'),
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
                  content: Text('Payout request submitted successfully!'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A2472),
            ),
            child: const Text('REQUEST PAYOUT'),
          ),
        ],
      ),
    );
  }

  void _viewBankDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bank Details'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bank: City Bank'),
            Text('Account Number: **** **** **** 1234'),
            Text('Account Holder: Driver Samuel'),
            Text('IFSC Code: CITY0000123'),
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
              // Edit bank details
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A2472),
            ),
            child: const Text('EDIT'),
          ),
        ],
      ),
    );
  }

  void _viewAllTransactions() {
    // Navigate to all transactions screen
  }

  void _applyForOvertime(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply for Overtime'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select overtime type:'),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.weekend, color: Color(0xFF4CAF50)),
              title: Text('Weekend Shift'),
              subtitle: Text('Saturday & Sunday'),
            ),
            ListTile(
              leading: Icon(Icons.celebration, color: Color(0xFF4CAF50)),
              title: Text('Holiday Shift'),
              subtitle: Text('Public holidays'),
            ),
            ListTile(
              leading: Icon(Icons.nightlight, color: Color(0xFF4CAF50)),
              title: Text('Night Shift'),
              subtitle: Text('8 PM - 6 AM'),
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
                  content: Text('Overtime application submitted'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A2472),
            ),
            child: const Text('APPLY'),
          ),
        ],
      ),
    );
  }

  void _claimIncentive(BuildContext context, Incentive incentive) {
    if (incentive.status == 'available') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Claim Incentive'),
          content: Text('Claim \$${incentive.amount.toStringAsFixed(2)} for ${incentive.title}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  incentive.status = 'claimed';
                  _walletBalance += incentive.amount;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Incentive claimed: \$${incentive.amount.toStringAsFixed(2)}'),
                    backgroundColor: const Color(0xFF4CAF50),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A2472),
              ),
              child: const Text('CLAIM'),
            ),
          ],
        ),
      );
    }
  }
}

// New Vehicle Documents Screen
class VehicleDocumentsScreen extends StatelessWidget {
  final List<VehicleDocument> documents = [
    VehicleDocument(
      id: '1',
      title: 'Registration Certificate',
      description: 'Official vehicle registration document',
      documentNumber: 'RC-2024-007',
      expiryDate: DateTime(2025, 12, 31),
      icon: Icons.description,
    ),
    VehicleDocument(
      id: '2',
      title: 'Insurance Papers',
      description: 'Vehicle insurance policy document',
      documentNumber: 'INS-2024-789',
      expiryDate: DateTime(2024, 12, 31),
      icon: Icons.security,
    ),
    VehicleDocument(
      id: '3',
      title: 'Vehicle Fitness Papers',
      description: 'Vehicle fitness certification',
      documentNumber: 'FIT-2024-456',
      expiryDate: DateTime(2025, 6, 30),
      icon: Icons.health_and_safety,
    ),
  ];

  VehicleDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Vehicle Documents'),
        backgroundColor: const Color(0xFF0A2472),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final document = documents[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentViewerScreen(
                      document: document,
                    ),
                  ),
                );
              },
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2472).withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(document.icon, color: const Color(0xFF0A2472), size: 28),
              ),
              title: Text(
                document.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(document.description),
                  const SizedBox(height: 4),
                  Text(
                    'Document No: ${document.documentNumber}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Expires: ${DateFormat('MMM dd, yyyy').format(document.expiryDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: document.expiryDate.isBefore(DateTime.now().add(const Duration(days: 30)))
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}

// Document Viewer Screen for viewing individual documents
class DocumentViewerScreen extends StatelessWidget {
  final VehicleDocument document;

  const DocumentViewerScreen({
    super.key,
    required this.document,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(document.title),
        backgroundColor: const Color(0xFF0A2472),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document Header
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2472).withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  document.icon,
                  size: 50,
                  color: const Color(0xFF0A2472),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Document Title
            Center(
              child: Text(
                document.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            
            // Document Description
            Center(
              child: Text(
                document.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            
            // Document Details Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDocumentDetail('Document Number', document.documentNumber, Icons.confirmation_number),
                    const Divider(),
                    _buildDocumentDetail('Issued Date', 'Jan 15, 2024', Icons.calendar_today),
                    const Divider(),
                    _buildDocumentDetail('Expiry Date', 
                      DateFormat('MMMM dd, yyyy').format(document.expiryDate), 
                      Icons.event,
                      isExpiring: document.expiryDate.isBefore(DateTime.now().add(const Duration(days: 30))),
                    ),
                    const Divider(),
                    _buildDocumentDetail('Status', 
                      document.expiryDate.isBefore(DateTime.now()) ? 'Expired' : 'Active',
                      Icons.verified,
                      statusColor: document.expiryDate.isBefore(DateTime.now()) 
                          ? Colors.red 
                          : Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Mock Document Image/Preview
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    size: 100,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${document.title} PDF Preview',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Document #: ${document.documentNumber}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Mock action for viewing document
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening ${document.title}...'),
                          backgroundColor: const Color(0xFF0A2472),
                        ),
                      );
                    },
                    icon: const Icon(Icons.remove_red_eye),
                    label: const Text('VIEW DOCUMENT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A2472),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('BACK'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentDetail(String label, String value, IconData icon, {bool isExpiring = false, Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0A2472), size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: statusColor ?? (isExpiring ? Colors.orange : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class WalletTransaction {
  final String id;
  final DateTime date;
  final double amount;
  final String type;
  final String description;
  final String status;

  WalletTransaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    required this.description,
    required this.status,
  });
}

class Incentive {
  final String id;
  final String title;
  final String description;
  final double amount;
  final String type;
  String status; // available, pending, claimed

  Incentive({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.status,
  });
}

class VehicleDocument {
  final String id;
  final String title;
  final String description;
  final String documentNumber;
  final DateTime expiryDate;
  final IconData icon;

  VehicleDocument({
    required this.id,
    required this.title,
    required this.description,
    required this.documentNumber,
    required this.expiryDate,
    required this.icon,
  });
}
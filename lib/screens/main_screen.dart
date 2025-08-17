import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkers/models/booking.dart';
import 'package:trekkers/screens/bookings_screen.dart';
import 'home_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/bookings_provider.dart';

class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({super.key});

  @override
  State<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final tabs = [
      const HomeScreen(), // Home tab
      ProfileTab(auth: auth), // Profile tab
      const SettingsTab(), // Settings tab
    ];

    return Scaffold(
      body: tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

// ---------------- Profile Tab ----------------
class ProfileTab extends StatelessWidget {
  final AuthProvider auth;

  const ProfileTab({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text('Username: ${auth.userData?.username ?? ''}'),
            // Text('Email: ${auth.user?.email ?? ''}'),
            // Text('Address: ${auth.userData?.address ?? ''}'),
            // Text('DOB: ${auth.userData?.dob ?? ''}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                );
              },
              child: const Text('My Bookings'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Settings tab content goes here'));
  }
}

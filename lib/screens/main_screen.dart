import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkers/screens/bookings_screen.dart';
import 'package:trekkers/screens/bookmarks_screen.dart';
import 'package:trekkers/screens/settings_screen.dart';
import 'home_screen.dart';
import '../providers/auth_provider.dart';

class MainTabsScreen extends StatelessWidget {
  const MainTabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: TabBarView(
          physics:
              const NeverScrollableScrollPhysics(), // optional: disable swipe
          children: [
            const HomeScreen(),
            const BookmarksScreen(),
            MyBookingsScreen(),
            const SettingsTab(),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.green,
          child: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.bookmark), text: 'Bookmarks'),
              Tab(icon: Icon(Icons.book), text: 'Bookings'),
              Tab(icon: Icon(Icons.person), text: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

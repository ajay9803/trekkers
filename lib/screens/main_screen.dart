import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkers/screens/bookings_screen.dart';
import 'package:trekkers/screens/settings_screen.dart';
import 'package:trekkers/screens/trek_admin_screen.dart';
import 'package:trekkers/screens/manage_bookings_screen.dart';
import 'package:trekkers/screens/bookmarks_screen.dart';
import 'home_screen.dart';
import '../providers/auth_provider.dart';

class MainTabsScreen extends StatelessWidget {
  const MainTabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (!auth.isLoggedIn || auth.userData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isAdmin = auth.role == 'admin';

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const HomeScreen(),
            isAdmin ? const ManageBookingsScreen() : const BookmarksScreen(),
            isAdmin ? const TreksAdminScreen() : MyBookingsScreen(),
            const SettingsTab(),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.green,
          child: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              const Tab(icon: Icon(Icons.home), text: 'Home'),
              isAdmin
                  ? const Tab(icon: Icon(Icons.list), text: 'Manage Bookings')
                  : const Tab(icon: Icon(Icons.bookmark), text: 'Bookmarks'),
              isAdmin
                  ? const Tab(icon: Icon(Icons.landscape), text: 'Treks')
                  : const Tab(icon: Icon(Icons.book), text: 'Bookings'),
              const Tab(icon: Icon(Icons.person), text: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

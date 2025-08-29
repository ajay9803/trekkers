import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'privacy_screen.dart';
import 'about_screen.dart';
import 'manage_users_screen.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  Future<String?> _getUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Return role if it exists, else "user"
      return doc.data()?['role'] ?? 'user';
    } catch (e) {
      debugPrint("Error fetching role: $e");
      return 'user'; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizeQuery = MediaQuery.of(context).size;

    return FutureBuilder<String?>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final role = snapshot.data ?? 'user';

        // Settings options
        final List<Map<String, dynamic>> settingsOptions = [
          {'title': 'Account', 'icon': Icons.person, 'onTap': () {}},
          {
            'title': 'Privacy',
            'icon': Icons.lock,
            'onTap': () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyScreen()),
              );
            },
          },
          {
            'title': 'About',
            'icon': Icons.info_outline,
            'onTap': () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          },
          if (role == 'admin') // 👈 show only if admin
            {
              'title': 'Manage Users',
              'icon': Icons.supervised_user_circle,
              'onTap': () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
                );
              },
            },
          {
            'title': 'Log Out',
            'icon': Icons.logout,
            'onTap': () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          },
        ];

        return Stack(
          children: [
            // Rectangle header
            Container(
              width: double.infinity,
              height: sizeQuery.height * 0.18,
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
            ),

            // Circular avatar overlapping rectangle
            Positioned(
              top: sizeQuery.height * 0.12 - 50,
              left: sizeQuery.width / 2 - 50,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.green.shade700,
                ),
              ),
            ),

            // Settings options list
            Container(
              margin: EdgeInsets.only(top: sizeQuery.height * 0.35 / 2 + 40),
              child: SingleChildScrollView(
                child: Column(
                  children: settingsOptions.map((option) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(
                          option['icon'],
                          color: Colors.green.shade700,
                        ),
                        title: Text(
                          option['title'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: option['onTap'],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

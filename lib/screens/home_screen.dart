import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkers/screens/add_trek_screen.dart';
import 'package:trekkers/screens/login_screen.dart';
import '../providers/treks_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/trek_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _treksFuture;
  String? _userRole;

  @override
  void initState() {
    super.initState();

    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Fetch treks once
    _treksFuture = Provider.of<TreksProvider>(
      context,
      listen: false,
    ).fetchTreks();

    // Fetch current user's role
    if (auth.user != null) {
      auth.fetchUserById(auth.user!.uid).then((data) {
        if (data != null && mounted) {
          setState(() {
            _userRole = data['role'];
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final treksProvider = Provider.of<TreksProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Treks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await auth.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _treksFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final treks = treksProvider.treks;
            if (treks.isEmpty) {
              return const Center(child: Text('No treks available.'));
            }
            return ListView.builder(
              itemCount: treks.length,
              itemBuilder: (ctx, i) => TrekItem(trek: treks[i]),
            );
          }
        },
      ),
      floatingActionButton: _userRole == 'admin'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AddTrekPage()));
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

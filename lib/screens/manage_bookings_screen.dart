import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkers/screens/treks_bookings_screen.dart';
import '../providers/treks_provider.dart';
import '../models/trek.dart';

class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({super.key});

  @override
  State<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen> {
  late Future<void> _treksFuture;

  @override
  void initState() {
    super.initState();
    _treksFuture = Provider.of<TreksProvider>(
      context,
      listen: false,
    ).fetchTreks();
  }

  Future<void> _refreshTreks(BuildContext context) async {
    await Provider.of<TreksProvider>(context, listen: false).fetchTreks();
  }

  @override
  Widget build(BuildContext context) {
    final treksProvider = Provider.of<TreksProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Bookings"),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 4,
      ),
      body: FutureBuilder(
        future: _treksFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (treksProvider.treks.isEmpty) {
            return const Center(
              child: Text(
                "No treks found.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _refreshTreks(context),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: treksProvider.treks.length,
              itemBuilder: (ctx, i) {
                final Trek trek = treksProvider.treks[i];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    title: Text(
                      trek.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      trek.description,
                      style: const TextStyle(color: Colors.black54),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("View Bookings"),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TrekBookingsScreen(trek: trek),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

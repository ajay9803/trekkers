import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookings_provider.dart';
import '../models/trek.dart';

class TrekBookingsScreen extends StatefulWidget {
  final Trek trek;
  const TrekBookingsScreen({super.key, required this.trek});

  @override
  State<TrekBookingsScreen> createState() => _TrekBookingsScreenState();
}

class _TrekBookingsScreenState extends State<TrekBookingsScreen> {
  late Future<List<Map<String, dynamic>>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = Provider.of<BookingsProvider>(
      context,
      listen: false,
    ).fetchTrekBookers(widget.trek.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bookings - ${widget.trek.name}"),
        backgroundColor: Colors.green.shade700,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _bookingsFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return const Center(
              child: Text(
                "No bookings for this trek.",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            itemBuilder: (ctx, i) {
              final booking = bookings[i];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(booking['username'] ?? "Unknown User"),
                  subtitle: Text(booking['email'] ?? "No email"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

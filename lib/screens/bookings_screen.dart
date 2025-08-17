import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookings_provider.dart';
import '../widgets/booking_item.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late Future<void> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = Provider.of<BookingsProvider>(context, listen: false)
        .fetchUserBookings();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsProvider = Provider.of<BookingsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: FutureBuilder(
        future: _bookingsFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final bookings = bookingsProvider.userBookings;
            if (bookings.isEmpty) {
              return const Center(child: Text('No bookings yet.'));
            }
            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (ctx, i) => BookingItem(booking: bookings[i]),
            );
          }
        },
      ),
    );
  }
}

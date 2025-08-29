import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/bookings_provider.dart';
import '../widgets/booking_item.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      Provider.of<BookingsProvider>(context, listen: false).fetchUserBookings();
      _isInit = false;
    }
  }

  Widget _buildGlassShimmerPlaceholder() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Shimmer.fromColors(
        baseColor: Colors.green.shade100.withOpacity(0.5),
        highlightColor: Colors.green.shade50.withOpacity(0.3),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(height: 120, color: Colors.white.withOpacity(0.1)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: Consumer<BookingsProvider>(
        builder: (ctx, bookingsProvider, _) {
          if (bookingsProvider.isLoading) {
            return ListView.builder(
              itemCount: 4,
              itemBuilder: (ctx, i) => _buildGlassShimmerPlaceholder(),
            );
          }

          final bookings = bookingsProvider.userBookings;
          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings yet.'));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (ctx, i) => BookingItem(booking: bookings[i]),
          );
        },
      ),
    );
  }
}

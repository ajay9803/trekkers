import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trekkers/screens/booking_details_screen.dart';
import '../models/booking.dart';
import '../models/trek.dart';
import '../providers/treks_provider.dart';
import '../providers/bookings_provider.dart'; // Assuming you have a provider for bookings

class BookingItem extends StatelessWidget {
  final Booking booking;

  const BookingItem({super.key, required this.booking});

  String _formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldCancel == true) {
      await Provider.of<BookingsProvider>(
        context,
        listen: false,
      ).cancelBooking(booking.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final treksProvider = Provider.of<TreksProvider>(context, listen: false);

    return FutureBuilder<Trek?>(
      future: treksProvider.fetchTrekById(booking.trekId),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(title: Text('Loading trek...'));
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const ListTile(title: Text('Trek not found'));
        } else {
          final trek = snapshot.data!;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BookingDetailsPage(booking: booking),
                  ),
                );
              },
              child: Row(
                children: [
                  // Trek image preview
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    child: trek.images.isNotEmpty
                        ? Image.network(
                            trek.images[0],
                            width: 60,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.landscape, size: 60),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trek.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Booked on: ${_formatDate(booking.bookedAt)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: booking.paid
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          booking.paid ? 'Paid' : 'Unpaid',
                          style: TextStyle(
                            color: booking.paid ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!booking.paid)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          tooltip: 'Cancel booking',
                          onPressed: () => _confirmCancel(context),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

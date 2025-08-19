import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trekkers/screens/booking_details_screen.dart';
import '../models/booking.dart';
import '../models/trek.dart';
import '../providers/treks_provider.dart';
import '../providers/bookings_provider.dart';

class BookingItem extends StatefulWidget {
  final Booking booking;

  const BookingItem({super.key, required this.booking});

  @override
  State<BookingItem> createState() => _BookingItemState();
}

class _BookingItemState extends State<BookingItem> {
  bool _expanded = false;
  FetchedTrek? _trek; // cached trek
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrek();
  }

  Future<void> _loadTrek() async {
    final treksProvider = Provider.of<TreksProvider>(context, listen: false);
    try {
      final fetchedTrek = await treksProvider.fetchTrekById(
        widget.booking.trekId,
      );
      setState(() {
        _trek = fetchedTrek;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _trek = null;
        _isLoading = false;
      });
    }
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
      ).cancelBooking(widget.booking.id);
    }
  }

  Widget _buildGlassShimmerPlaceholder(BuildContext context) {
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
            child: Container(height: 100, color: Colors.white.withOpacity(0.1)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildGlassShimmerPlaceholder(context);
    if (_trek == null) return const ListTile(title: Text('Trek not found'));

    final trek = _trek!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Column(
        children: [
          // Header (click to expand/collapse)
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
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
                          'Booked on: ${DateFormat.yMMMd().format(widget.booking.bookedAt)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.green.shade700,
                  ),
                ],
              ),
            ),
          ),

          // Expanded details section
          if (_expanded)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.green.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment Status: ${widget.booking.paid ? "Paid" : "Unpaid"}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: widget.booking.paid
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _confirmCancel(context),
                        tooltip: 'Cancel Booking',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Trek Difficulty: ${trek.difficulty}',
                    style: TextStyle(color: Colors.green.shade900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Distance: ${trek.distanceKm} km',
                    style: TextStyle(color: Colors.green.shade900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Duration: ${trek.durationDays} days',
                    style: TextStyle(color: Colors.green.shade900),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              BookingDetailsPage(booking: widget.booking),
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('View Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

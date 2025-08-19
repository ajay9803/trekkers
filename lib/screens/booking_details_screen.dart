import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trekkers/screens/group_chat_screen.dart';
import 'package:trekkers/widgets/trek_user_item.dart';
import '../models/booking.dart';
import '../models/trek.dart';
import '../providers/bookings_provider.dart';
import '../providers/treks_provider.dart';

class BookingDetailsPage extends StatefulWidget {
  final Booking booking;

  const BookingDetailsPage({super.key, required this.booking});

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  FetchedTrek? _trek;
  bool _loading = true;
  bool _error = false;
  List<Map<String, dynamic>> _bookers = [];

  @override
  void initState() {
    super.initState();
    _loadTrekAndBookers();
  }

  Future<void> _loadTrekAndBookers() async {
    try {
      final trek = await Provider.of<TreksProvider>(
        context,
        listen: false,
      ).fetchTrekById(widget.booking.trekId);

      final bookers = await Provider.of<BookingsProvider>(
        context,
        listen: false,
      ).fetchTrekBookers(widget.booking.trekId);

      setState(() {
        _trek = trek;
        _bookers = bookers;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error || _trek == null) {
      return const Scaffold(body: Center(child: Text('Failed to load trek')));
    }

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(_trek!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      GroupChatPage(groupId: _trek!.id, groupName: _trek!.name),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trek Images Placeholder
            _trek!.images.isNotEmpty
                ? SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _trek!.images.length,
                      itemBuilder: (ctx, i) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _trek!.images[i],
                            width: 300,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(
                    height: 200,
                    child: Center(
                      child: Icon(
                        Icons.landscape,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  ),
            const SizedBox(height: 16),

            // Description
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_trek!.description),
                  ],
                ),
              ),
            ),

            // Trek Info
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trek Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.terrain,
                      'Difficulty',
                      _trek!.difficulty,
                    ),
                    _buildInfoRow(
                      Icons.place,
                      'Start Location',
                      _trek!.startLocation,
                    ),
                    _buildInfoRow(
                      Icons.directions_walk,
                      'Distance',
                      '${_trek!.distanceKm} km',
                    ),
                    _buildInfoRow(
                      Icons.timer,
                      'Duration',
                      '${_trek!.durationDays} days',
                    ),
                    _buildInfoRow(
                      Icons.person,
                      'Available Slots',
                      '${_trek!.slotsAvailable}',
                    ),
                    _buildInfoRow(
                      Icons.monetization_on,
                      'Price',
                      '\$${_trek!.price.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
            ),

            // Payment Button
            if (!widget.booking.paid)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to payment page
                  },
                  child: const Text('Pay Now'),
                ),
              )
            else
              const Center(
                child: Text(
                  'Paid ✅',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Bookers
            Text('Booked By:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _bookers.isEmpty
                ? const Text('No users booked this trek yet.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _bookers.length,
                    itemBuilder: (ctx, i) {
                      final user = _bookers[i];
                      return TrekUserTile(
                        userId: user['id'],
                        username: user['username'] ?? 'Unknown',
                        email: user['email'] ?? '',
                        profileImageUrl: user['profileImageUrl'] ?? '',
                        isCurrentUser: user['id'] == currentUserId,
                        onChatPressed: () {
                          debugPrint('Chat pressed for user: ${user['id']}');
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

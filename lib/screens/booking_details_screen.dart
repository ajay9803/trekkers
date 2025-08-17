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
  Trek? _trek;
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

      debugPrint('Bookers fetched: $_bookers');
    } catch (e) {
      debugPrint('Error loading trek/bookers: $e');
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
            if (_trek!.images.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _trek!.images.length,
                  itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.network(_trek!.images[i]),
                  ),
                ),
              )
            else
              const SizedBox(
                height: 200,
                child: Center(child: Icon(Icons.landscape, size: 100)),
              ),
            const SizedBox(height: 16),
            Text(
              'Description:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(_trek!.description),
            const SizedBox(height: 16),
            Text('Difficulty: ${_trek!.difficulty}'),
            Text('Distance: ${_trek!.distanceKm} km'),
            Text('Duration: ${_trek!.durationDays} days'),
            Text('Start Location: ${_trek!.startLocation}'),
            Text('Available Slots: ${_trek!.slotsAvailable}'),
            Text('Price: \$${_trek!.price.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            if (widget.booking.paid == false)
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
                child: Text('Paid ✅', style: TextStyle(color: Colors.green)),
              ),
            const SizedBox(height: 24),
            Text('Booked By:', style: Theme.of(context).textTheme.titleMedium),
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
                          // TODO: Navigate to chat with this user
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
}

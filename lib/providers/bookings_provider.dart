import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking.dart';

class BookingsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Booking> _userBookings = [];
  List<Booking> get userBookings => [..._userBookings];

  /// Fetch bookings for the current user
  Future<void> fetchUserBookings() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .orderBy('bookedAt', descending: true)
          .get();

      _userBookings =
          snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();

      notifyListeners();
    } catch (e) {
      return Future.error('Failed to fetch bookings: $e');
    }
  }

  /// Book a trek
  Future<void> bookTrek(String trekId) async {
    final user = _auth.currentUser;
    if (user == null) return Future.error('User must be logged in');

    final trekDoc = _firestore.collection('treks').doc(trekId);

    try {
      final trekSnapshot = await trekDoc.get();
      if (!trekSnapshot.exists) {
        return Future.error('Trek not found');
      }

      final slots = trekSnapshot['slotsAvailable'] as int;
      if (slots <= 0) return Future.error('No slots available');

      // Check if already booked
      final existingBooking = await _firestore
          .collection('bookings')
          .where('trekId', isEqualTo: trekId)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (existingBooking.docs.isNotEmpty) {
        return Future.error('You have already booked this trek');
      }

      // Create booking with paid = false
      final booking = Booking(
        id: '',
        trekId: trekId,
        userId: user.uid,
        bookedAt: DateTime.now(),
        paid: false,
      );

      final bookingRef =
          await _firestore.collection('bookings').add(booking.toMap());

      final newBooking = Booking(
        id: bookingRef.id,
        trekId: booking.trekId,
        userId: booking.userId,
        bookedAt: booking.bookedAt,
        paid: booking.paid,
      );

      // Decrement trek slots
      await trekDoc.update({'slotsAvailable': slots - 1});

      _userBookings.insert(0, newBooking);
      notifyListeners();
    } catch (e) {
      return Future.error('Booking failed: $e');
    }
  }

  /// Delete a booking (cancel)
  Future<void> cancelBooking(String bookingId) async {
    try {
      // Find booking in memory
      final bookingIndex = _userBookings.indexWhere((b) => b.id == bookingId);
      if (bookingIndex == -1) return Future.error('Booking not found');

      final booking = _userBookings[bookingIndex];

      // Delete booking from Firestore
      await _firestore.collection('bookings').doc(bookingId).delete();

      // Increment trek slots back
      final trekDoc = _firestore.collection('treks').doc(booking.trekId);
      await _firestore.runTransaction((transaction) async {
        final trekSnapshot = await transaction.get(trekDoc);
        if (!trekSnapshot.exists) return;
        final currentSlots = trekSnapshot['slotsAvailable'] as int;
        transaction.update(trekDoc, {'slotsAvailable': currentSlots + 1});
      });

      // Remove from local list
      _userBookings.removeAt(bookingIndex);
      notifyListeners();
    } catch (e) {
      return Future.error('Failed to cancel booking: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchTrekBookers(String trekId) async {
    try {
      debugPrint('Fetching bookings for trekId: $trekId');

      // Step 1: Get all bookings for the trek
      final bookingsSnapshot = await _firestore
          .collection('bookings')
          .where('trekId', isEqualTo: trekId)
          .get();

      debugPrint('Total bookings fetched: ${bookingsSnapshot.docs.length}');

      if (bookingsSnapshot.docs.isEmpty) {
        debugPrint('No bookings found for this trek.');
        return [];
      }

      // Step 2: Extract unique userIds
      final userIds = bookingsSnapshot.docs
          .map((doc) => doc['userId'] as String?)
          .where((uid) => uid != null)
          .cast<String>()
          .toSet()
          .toList();

      debugPrint('Unique user IDs: $userIds');

      if (userIds.isEmpty) {
        debugPrint('No valid user IDs found in bookings.');
        return [];
      }

      // Step 3: Fetch user documents
      final userDocs = await Future.wait(
        userIds.map(
          (uid) async {
            final doc = await _firestore.collection('users').doc(uid).get();
            debugPrint('Fetched user doc: ${doc.id}, exists: ${doc.exists}');
            return doc;
          },
        ),
      );

      // Step 4: Return user data list
      final users = userDocs.where((doc) => doc.exists).map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // add the document ID
        debugPrint('User data: $data');
        return data;
      }).toList();

      debugPrint('Total users returned: ${users.length}');
      return users;
    } catch (e) {
      debugPrint('Error in fetchTrekBookers: $e');
      return Future.error('Failed to fetch trek bookers: $e');
    }
  }
}

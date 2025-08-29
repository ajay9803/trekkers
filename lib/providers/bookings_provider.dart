import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trekkers/apis/email_service.dart';
import '../models/booking.dart';

class BookingsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Booking> _userBookings = [];
  List<Booking> get userBookings => [..._userBookings];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Fetch bookings for the current user
  Future<void> fetchUserBookings() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .orderBy('bookedAt', descending: true)
          .get();

      _userBookings = snapshot.docs
          .map((doc) => Booking.fromFirestore(doc))
          .toList();
    } catch (e) {
      return Future.error('Failed to fetch bookings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Book a trek
  Future<void> bookTrek(String trekId) async {
    final user = _auth.currentUser;
    if (user == null) return Future.error('User must be logged in');

    final trekDoc = _firestore.collection('treks').doc(trekId);

    try {
      final trekSnapshot = await trekDoc.get();
      if (!trekSnapshot.exists) return Future.error('Trek not found');

      final slots = trekSnapshot['slotsAvailable'].toInt();
      if (slots <= 0) return Future.error('No slots available');

      final existingBooking = await _firestore
          .collection('bookings')
          .where('trekId', isEqualTo: trekId)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (existingBooking.docs.isNotEmpty) {
        return Future.error('You have already booked this trek');
      }

      final booking = Booking(
        id: '',
        trekId: trekId,
        userId: user.uid,
        bookedAt: DateTime.now(),
        paid: false,
      );

      final bookingRef = await _firestore
          .collection('bookings')
          .add(booking.toMap());

      final newBooking = Booking(
        id: bookingRef.id,
        trekId: booking.trekId,
        userId: booking.userId,
        bookedAt: booking.bookedAt,
        paid: booking.paid,
      );

      _userBookings.insert(0, newBooking);
      notifyListeners();

      // Send email confirmation
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>;
      final trekName = trekSnapshot['name'] ?? 'Trek';

      await EmailService.sendBookingEmail(
        userEmail: userData['email'],
        userName: userData['username'] ?? 'Guest',
        trekName: trekName,
      );
    } catch (e) {
      return Future.error('Booking failed: $e');
    }
  }

  /// Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    try {
      final bookingIndex = _userBookings.indexWhere((b) => b.id == bookingId);
      if (bookingIndex == -1) return Future.error('Booking not found');

      final booking = _userBookings[bookingIndex];

      // Delete booking
      await _firestore.collection('bookings').doc(bookingId).delete();

      print('dada');
      // Increment trek slots back
      final trekDoc = _firestore.collection('treks').doc(booking.trekId);
      await _firestore.runTransaction((transaction) async {
        final trekSnapshot = await transaction.get(trekDoc);
        if (!trekSnapshot.exists) return;
        final currentSlots = trekSnapshot['slotsAvailable'];
        transaction.update(trekDoc, {
          'slotsAvailable': double.parse(currentSlots.toString()) + 1,
        });
      });

      _userBookings.removeAt(bookingIndex);
      notifyListeners();
    } catch (e) {
      return Future.error('Failed to cancel booking: $e');
    }
  }

  /// Fetch all users who booked a specific trek
  Future<List<Map<String, dynamic>>> fetchTrekBookers(String trekId) async {
    try {
      debugPrint('Fetching bookings for trekId: $trekId');

      final bookingsSnapshot = await _firestore
          .collection('bookings')
          .where('trekId', isEqualTo: trekId)
          .get();

      debugPrint('Total bookings fetched: ${bookingsSnapshot.docs.length}');

      if (bookingsSnapshot.docs.isEmpty) {
        debugPrint('No bookings found for this trek.');
        return [];
      }

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

      final userDocs = await Future.wait(
        userIds.map((uid) async {
          final doc = await _firestore.collection('users').doc(uid).get();
          debugPrint('Fetched user doc: ${doc.id}, exists: ${doc.exists}');
          return doc;
        }),
      );

      final users = userDocs.where((doc) => doc.exists).map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
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

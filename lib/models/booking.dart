import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String trekId;
  final String userId;
  final DateTime bookedAt;
  final bool paid;

  Booking({
    required this.id,
    required this.trekId,
    required this.userId,
    required this.bookedAt,
    required this.paid,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      trekId: data['trekId'] ?? '',
      userId: data['userId'] ?? '',
      bookedAt: (data['bookedAt'] as Timestamp).toDate(),
      paid: data['paid'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trekId': trekId,
      'userId': userId,
      'bookedAt': Timestamp.fromDate(bookedAt),
      'paid': paid,
    };
  }
}

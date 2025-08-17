// import 'package:flutter/material.dart';
// import 'package:khalti_flutter/khalti_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class KhaltiPaymentPage extends StatelessWidget {
//   final String trekId;
//   final double amount; // amount in NPR

//   const KhaltiPaymentPage(
//       {super.key, required this.trekId, required this.amount});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Khalti Payment')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             KhaltiScope.of(context).pay(
//               config: PaymentConfig(
//                 amount: (amount * 100).toInt(), // Khalti uses paisa
//                 productIdentity: trekId,
//                 productName: "Trek Booking",
//                 additionalData: {"trekId": trekId},
//               ),
//               preferences: [
//                 PaymentPreference.khalti,
//                 PaymentPreference.eBanking,
//                 PaymentPreference.connectIPS,
//                 PaymentPreference.sct,
//               ],
//               onSuccess: (PaymentSuccessModel success) async {
//                 // Update booking paid field
//                 try {
//                   final snapshot = await FirebaseFirestore.instance
//                       .collection('bookings')
//                       .where('trekId', isEqualTo: trekId)
//                       .where('paid', isEqualTo: false)
//                       .limit(1)
//                       .get();

//                   if (snapshot.docs.isNotEmpty) {
//                     final docId = snapshot.docs.first.id;
//                     await FirebaseFirestore.instance
//                         .collection('bookings')
//                         .doc(docId)
//                         .update({'paid': true});
//                   }

//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Payment Successful!')),
//                   );

//                   Navigator.of(context).popUntil((route) => route.isFirst);
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                         content:
//                             Text('Payment succeeded but update failed: $e')),
//                   );
//                 }
//               },
//               onFailure: (PaymentFailureModel failure) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Payment Failed: ${failure.message}')),
//                 );
//               },
//               onCancel: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Payment Cancelled')),
//                 );
//               },
//             );
//           },
//           child: const Text('Pay with Khalti'),
//         ),
//       ),
//     );
//   }
// }

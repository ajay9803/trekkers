import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkers/screens/khalti_payment_screen.dart';
import '../models/trek.dart';
import '../providers/bookings_provider.dart';

class TrekDetailsPage extends StatelessWidget {
  final Trek trek;

  const TrekDetailsPage({super.key, required this.trek});

  @override
  Widget build(BuildContext context) {
    final bookingsProvider = Provider.of<BookingsProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(title: Text(trek.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (trek.images.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: trek.images.length,
                  itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.network(trek.images[i]),
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
            Text(trek.description),
            const SizedBox(height: 16),
            Text('Difficulty: ${trek.difficulty}'),
            Text('Distance: ${trek.distanceKm} km'),
            Text('Duration: ${trek.durationDays} days'),
            Text('Start Location: ${trek.startLocation}'),
            Text('Available Slots: ${trek.slotsAvailable}'),
            Text('Price: \$${trek.price.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            if (trek.poi.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Points of Interest:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...trek.poi.map((p) => Text('• $p')).toList(),
                ],
              ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await bookingsProvider.bookTrek(trek.id);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Trek booked successfully!'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: const Text('Book & Pay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

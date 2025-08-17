import 'package:flutter/material.dart';
import 'package:trekkers/screens/trek_details_screen.dart';
import '../models/trek.dart';

class TrekItem extends StatelessWidget {
  final Trek trek;

  const TrekItem({super.key, required this.trek});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => TrekDetailsPage(trek: trek)));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 4,
        child: ListTile(
          leading: trek.images.isNotEmpty
              ? Image.network(trek.images[0], width: 60, fit: BoxFit.cover)
              : const Icon(Icons.landscape, size: 60),
          title: Text(
            trek.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${trek.slotsAvailable} slots • ${trek.difficulty}'),
          trailing: Text('\$${trek.price.toStringAsFixed(2)}'),
        ),
      ),
    );
  }
}

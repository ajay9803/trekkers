import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trek.dart';
import '../widgets/trek_item.dart';
import '../providers/treks_provider.dart'; // your provider that has _fetchedTreks

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to treks provider
    final treksProvider = Provider.of<TreksProvider>(context);

    // Filter only bookmarked treks
    final bookmarkedTreks = treksProvider.fetchedTreks
        .where((trek) => trek.isBookmarked)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        backgroundColor: Colors.green,
      ),
      body: bookmarkedTreks.isEmpty
          ? const Center(
              child: Text('No bookmarks yet!', style: TextStyle(fontSize: 16)),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: bookmarkedTreks.length,
              itemBuilder: (ctx, i) {
                return ChangeNotifierProvider<FetchedTrek>.value(
                  value: bookmarkedTreks[i], // each trek is a ChangeNotifier
                  child: const TrekItem(), // TrekItem listens to trek instance
                );
              },
            ),
    );
  }
}

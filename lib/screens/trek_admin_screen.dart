import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/treks_provider.dart';
import '../models/trek.dart';

class TreksAdminScreen extends StatefulWidget {
  const TreksAdminScreen({super.key});

  @override
  State<TreksAdminScreen> createState() => _TreksAdminScreenState();
}

class _TreksAdminScreenState extends State<TreksAdminScreen> {
  late Future<void> _treksFuture;

  @override
  void initState() {
    super.initState();
    _treksFuture = Provider.of<TreksProvider>(
      context,
      listen: false,
    ).fetchTreks();
  }

  Future<void> _refreshTreks(BuildContext context) async {
    await Provider.of<TreksProvider>(context, listen: false).fetchTreks();
  }

  @override
  Widget build(BuildContext context) {
    final treksProvider = Provider.of<TreksProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Manage Treks",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 4,
      ),
      body: FutureBuilder(
        future: _treksFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (treksProvider.treks.isEmpty) {
            return const Center(
              child: Text(
                "No treks found.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _refreshTreks(context),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: treksProvider.treks.length,
              itemBuilder: (ctx, i) {
                final Trek trek = treksProvider.treks[i];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    title: Text(
                      trek.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      trek.description ?? "No description available",
                      style: const TextStyle(color: Colors.black54),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _confirmDelete(context, treksProvider, trek.id),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    TreksProvider provider,
    String trekId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Delete Trek",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to delete this trek? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.delete, size: 18),
            label: const Text("Delete"),
            onPressed: () async {
              await provider.deleteTrek(trekId);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Trek deleted successfully")),
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../models/trek.dart';
import '../providers/treks_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/trek_item.dart';
import '../screens/add_trek_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late Future<void> _treksFuture;
  String? _userRole;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Fetch treks
    _treksFuture = Provider.of<TreksProvider>(
      context,
      listen: false,
    ).fetchTheTreks();

    // Fetch user role
    if (auth.user != null) {
      auth.fetchUserById(auth.user!.uid).then((data) {
        if (data != null && mounted) {
          setState(() {
            _userRole = data['role'];
          });
        }
      });
    }
  }

  @override
  bool get wantKeepAlive => true; // Keep state alive

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Explore Treks'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Find cities',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.green.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
            ),
          ),

          // Filter chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Active'),
                _buildFilterChip('Featured'),
              ],
            ),
          ),

          // Trek list
          Expanded(
            child: FutureBuilder(
              future: _treksFuture,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show shimmer placeholders
                  return ListView.builder(
                    itemCount: 4,
                    itemBuilder: (ctx, i) => _buildGlassShimmerPlaceholder(),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return Consumer<TreksProvider>(
                    builder: (ctx, treksProvider, _) {
                      final treks = treksProvider.fetchedTreks.where((t) {
                        final matchesSearch = t.name.toLowerCase().contains(
                          _searchQuery,
                        );
                        switch (_selectedFilter) {
                          case 'Active':
                            return matchesSearch && t.isActive;
                          case 'Featured':
                            return matchesSearch && t.featured;
                          case 'All':
                          default:
                            return matchesSearch;
                        }
                      }).toList();

                      if (treks.isEmpty) {
                        return const Center(child: Text('No treks available.'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: treks.length,
                        itemBuilder: (ctx, i) {
                          return ChangeNotifierProvider<FetchedTrek>.value(
                            value: treks[i],
                            child: const TrekItem(),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _userRole == 'admin'
          ? FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AddTrekPage()));
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.green,
        backgroundColor: Colors.green.shade50,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.green),
        onSelected: (_) {
          setState(() {
            _selectedFilter = label;
          });
        },
      ),
    );
  }

  Widget _buildGlassShimmerPlaceholder() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Shimmer.fromColors(
        baseColor: Colors.green.shade100.withOpacity(0.5),
        highlightColor: Colors.green.shade50.withOpacity(0.3),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(height: 200, color: Colors.white.withOpacity(0.1)),
          ),
        ),
      ),
    );
  }
}

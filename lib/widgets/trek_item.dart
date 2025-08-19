import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trekkers/models/trek.dart';
import 'package:trekkers/screens/trek_details_screen.dart';
import 'package:trekkers/screens/trek_map_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrekItem extends StatelessWidget {
  const TrekItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FetchedTrek>(
      builder: (ctx, trek, _) {
        Set<Marker> markers = trek.midPoints.map((mp) {
          return Marker(
            markerId: MarkerId(DateTime.now().toString()),
            position: LatLng(mp.lat, mp.lng),
          );
        }).toSet();

        Set<Polyline> polylines = {
          Polyline(
            polylineId: const PolylineId('trek_path'),
            color: Colors.blue,
            width: 3,
            points: trek.midPoints.map((mp) => LatLng(mp.lat, mp.lng)).toList(),
          ),
        };

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => TrekDetailsPage(trek: trek)),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.green.shade200,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background image if exists
                if (trek.images.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      trek.images[0],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.2),
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),

                // Bookmark button on top right
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton(
                    icon: Icon(
                      trek.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: Colors.yellowAccent,
                    ),
                    onPressed: () async {
                      final userId = FirebaseAuth.instance.currentUser!.uid;
                      await trek.toggleBookmark(userId);
                    },
                  ),
                ),

                // Trek info at bottom left
                Positioned(
                  left: 16,
                  bottom: 16,
                  right: 16 + 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trek.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.yellowAccent,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'None',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            trek.difficulty,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${trek.distanceKm} km',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Mini map on top right
                Positioned(
                  bottom: 12,
                  right: 12, // leave space for bookmark button
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TrekMapScreen(trek: trek),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: trek.midPoints.isNotEmpty
                                ? LatLng(
                                    trek.midPoints.first.lat,
                                    trek.midPoints.first.lng,
                                  )
                                : const LatLng(0, 0),
                            zoom: 10,
                          ),
                          markers: markers,
                          polylines: polylines,
                          zoomControlsEnabled: false,
                          scrollGesturesEnabled: false,
                          tiltGesturesEnabled: false,
                          rotateGesturesEnabled: false,
                          myLocationButtonEnabled: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

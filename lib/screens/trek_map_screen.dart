import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/trek.dart';

class TrekMapScreen extends StatefulWidget {
  final FetchedTrek trek;

  const TrekMapScreen({super.key, required this.trek});

  @override
  State<TrekMapScreen> createState() => _TrekMapScreenState();
}

class _TrekMapScreenState extends State<TrekMapScreen> {
  late GoogleMapController _mapController;
  FetchedMidPoint? _selectedMidPoint;

  @override
  Widget build(BuildContext context) {
    final midPoints = widget.trek.midPoints;

    // Markers with colors based on position (start/mid/end)
    Set<Marker> markers = midPoints.asMap().entries.map((entry) {
      final index = entry.key;
      final mp = entry.value;

      BitmapDescriptor markerColor;
      if (index == 0) {
        markerColor = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ); // Start
      } else if (index == midPoints.length - 1) {
        markerColor = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ); // End
      } else {
        markerColor = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure,
        ); // Middle
      }

      return Marker(
        markerId: MarkerId(mp.name),
        position: LatLng(mp.lat, mp.lng),
        icon: markerColor,
        infoWindow: InfoWindow(title: mp.name),
        onTap: () {
          setState(() {
            _selectedMidPoint = mp;
          });
        },
      );
    }).toSet();

    // Polyline connecting mid-points
    Set<Polyline> polylines = {
      Polyline(
        polylineId: const PolylineId('trek_path'),
        color: Colors.blue,
        width: 4,
        points: midPoints.map((mp) => LatLng(mp.lat, mp.lng)).toList(),
      ),
    };

    return Scaffold(
      appBar: AppBar(title: Text('${widget.trek.name} Map')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(midPoints.first.lat, midPoints.first.lng),
              zoom: 12,
            ),
            markers: markers,
            polylines: polylines,
            onMapCreated: (controller) => _mapController = controller,
          ),

          // Bottom sheet for selected mid-point
          if (_selectedMidPoint != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: DraggableScrollableSheet(
                initialChildSize: 0.25,
                minChildSize: 0.1,
                maxChildSize: 0.4,
                builder: (context, scrollController) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 10),
                      ],
                    ),
                    child: ListView(
                      controller: scrollController,
                      children: [
                        Text(
                          _selectedMidPoint!.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(_selectedMidPoint!.description),
                        const SizedBox(height: 12),
                        if (_selectedMidPoint!.images.isNotEmpty)
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedMidPoint!.images.length,
                              itemBuilder: (ctx, i) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _selectedMidPoint!.images[i],
                                    width: 160,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

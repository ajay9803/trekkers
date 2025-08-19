import 'dart:io';

class MidPoint {
  final String name;
  final String description;
  final double lat;
  final double lng;
  final List<File> images;

  MidPoint({
    required this.name,
    required this.description,
    required this.lat,
    required this.lng,
    required this.images,
  });

  /// For saving to Firestore (after upload, you pass URLs)
  Map<String, dynamic> toMap(List<String> imageUrls) {
    return {
      'name': name,
      'description': description,
      'lat': lat,
      'lng': lng,
      'images': imageUrls,
    };
  }

  /// For fetching from Firestore (URLs only, no files here)
  factory MidPoint.fromMap(Map<String, dynamic> map) {
    return MidPoint(
      name: map['name'],
      description: map['description'],
      lat: double.tryParse(map['lat'].toString()) ?? 0,
      lng: double.tryParse(map['lng'].toString()) ?? 0,
      images: [],
    );
  }
}

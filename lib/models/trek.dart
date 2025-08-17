class Trek {
  final String id; // Unique ID
  final String name; // Trek name
  final String description; // Detailed description
  final double price; // Price per participant
  final int slotsAvailable; // Number of available slots
  final String difficulty; // Easy / Medium / Hard
  final double distanceKm; // Distance in km
  final int durationDays; // Duration in days
  final String startLocation; // City or trailhead
  final List<String> images; // URLs of trek photos
  final List<String> poi; // Points of interest (POIs)
  final DateTime createdAt; // Date trek was added
  final bool featured; // Featured trek flag
  final bool isActive; // Whether trek is available for booking

  Trek({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.slotsAvailable,
    required this.difficulty,
    required this.distanceKm,
    required this.durationDays,
    required this.startLocation,
    required this.images,
    required this.poi,
    required this.createdAt,
    this.featured = false,
    this.isActive = true,
  });

  // Optional: Convert to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'slotsAvailable': slotsAvailable,
      'difficulty': difficulty,
      'distanceKm': distanceKm,
      'durationDays': durationDays,
      'startLocation': startLocation,
      'images': images,
      'poi': poi,
      'createdAt': createdAt.toIso8601String(),
      'featured': featured,
      'isActive': isActive,
    };
  }

  // Optional: Create Trek from Firestore Map
  factory Trek.fromMap(Map<String, dynamic> map) {
    return Trek(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      slotsAvailable: map['slotsAvailable'],
      difficulty: map['difficulty'],
      distanceKm: map['distanceKm'],
      durationDays: map['durationDays'],
      startLocation: map['startLocation'],
      images: List<String>.from(map['images'] ?? []),
      poi: List<String>.from(map['poi'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      featured: map['featured'] ?? false,
      isActive: map['isActive'] ?? true,
    );
  }
}

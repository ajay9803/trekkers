import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'mid_point.dart';

class Trek {
  final String id;
  final String name;
  final String description;
  final double price;
  final double slotsAvailable;
  final String difficulty;
  final double distanceKm;
  final double durationDays;
  final String startLocation;

  final List<String> poi;
  final DateTime createdAt;
  final bool featured;
  final bool isActive;

  final List<MidPoint> midPoints;

  // Add local images for upload
  final List<File> localImages;

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
    this.poi = const [],
    required this.createdAt,
    this.featured = false,
    this.isActive = true,
    this.midPoints = const [],
    this.localImages = const [],
  });

  // Convert to map for Firestore (pass uploaded image URLs)
  Map<String, dynamic> toMap({required List<String> imageUrls}) {
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
      'poi': poi,
      'createdAt': createdAt.toIso8601String(),
      'featured': featured,
      'isActive': isActive,
      'images': imageUrls, // Trek image URLs
      'midPoints': midPoints
          .map((m) => m.toMap([])) // midPoint URLs handled in provider
          .toList(),
    };
  }

  /// Deserialize from Firestore
  factory Trek.fromMap(Map<String, dynamic> map) {
    return Trek(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: double.tryParse(map['price'].toString()) ?? 0,
      slotsAvailable: double.tryParse(map['slotsAvailable'].toString()) ?? 0,
      difficulty: map['difficulty'] ?? 'Easy',
      distanceKm: double.tryParse(map['distanceKm'].toString()) ?? 0,
      durationDays: double.tryParse(map['durationDays'].toString()) ?? 0,
      startLocation: map['startLocation'],
      createdAt: DateTime.parse(map['createdAt']),
      featured: map['featured'] ?? false,
      isActive: map['isActive'] ?? true,
      midPoints:
          (map['midPoints'] as List<dynamic>?)
              ?.map((e) => MidPoint.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      localImages: [], // Firestore data only has URLs, so local files empty
    );
  }
}

class FetchedMidPoint {
  final String name;
  final String description;
  final double lat;
  final double lng;
  final List<String> images; // URLs from Firestore

  FetchedMidPoint({
    required this.name,
    required this.description,
    required this.lat,
    required this.lng,
    this.images = const [],
  });

  factory FetchedMidPoint.fromMap(Map<String, dynamic> map) {
    return FetchedMidPoint(
      name: map['name'],
      description: map['description'],
      lat: double.tryParse(map['lat'].toString()) ?? 0,
      lng: double.tryParse(map['lng'].toString()) ?? 0,
      images: List<String>.from(map['images'] ?? []),
    );
  }
}

class FetchedTrek with ChangeNotifier {
  final String id;
  final String name;
  final String description;
  final double price;
  final double slotsAvailable;
  final String difficulty;
  final double distanceKm;
  final double durationDays;
  final String startLocation;
  final List<String> poi;
  final DateTime createdAt;
  final bool featured;
  final bool isActive;
  final List<String> images;
  final List<FetchedMidPoint> midPoints;
  bool isBookmarked;

  FetchedTrek({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.slotsAvailable,
    required this.difficulty,
    required this.distanceKm,
    required this.durationDays,
    required this.startLocation,
    this.poi = const [],
    required this.createdAt,
    this.featured = false,
    this.isActive = true,
    this.images = const [],
    this.midPoints = const [],
    this.isBookmarked = false,
  });

  factory FetchedTrek.fromMap(
    Map<String, dynamic> map, {
    List<String>? bookmarkedTrekIds,
  }) {
    final bookmarks = bookmarkedTrekIds ?? [];
    return FetchedTrek(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: double.tryParse(map['price'].toString()) ?? 0,
      slotsAvailable: double.tryParse(map['slotsAvailable'].toString()) ?? 0,
      difficulty: map['difficulty'] ?? 'Easy',
      distanceKm: double.tryParse(map['distanceKm'].toString()) ?? 0,
      durationDays: double.tryParse(map['durationDays'].toString()) ?? 0,
      startLocation: map['startLocation'],
      createdAt: DateTime.parse(map['createdAt']),
      featured: map['featured'] ?? false,
      isActive: map['isActive'] ?? true,
      images: List<String>.from(map['images'] ?? []),
      midPoints: (map['midPoints'] as List<dynamic>? ?? [])
          .map((e) => FetchedMidPoint.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      poi: List<String>.from(map['poi'] ?? []),
      isBookmarked: bookmarks.contains(map['id']),
    );
  }

  /// Add trek to bookmarks
  Future<void> addToBookmarks(String userId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('bookmarks').doc();
      await docRef.set({'trekId': id, 'userId': userId});
      isBookmarked = true;
      notifyListeners();
    } on FirebaseException catch (e) {
      return Future.error(e.toString());
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  /// Remove trek from bookmarks
  Future<void> removeFromBookmarks(String userId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('bookmarks')
          .where('trekId', isEqualTo: id)
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in query.docs) {
        await doc.reference.delete();
      }

      isBookmarked = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      return Future.error(e.toString());
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  /// Toggle bookmark
  Future<void> toggleBookmark(String userId) async {
    if (isBookmarked) {
      await removeFromBookmarks(userId);
    } else {
      await addToBookmarks(userId);
    }
  }

  /// Check Firestore to see if this trek is bookmarked by the user
  Future<void> initBookmarkStatus(String userId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('bookmarks')
          .where('trekId', isEqualTo: id)
          .where('userId', isEqualTo: userId)
          .get();

      isBookmarked = query.docs.isNotEmpty;
      notifyListeners(); // update UI
    } catch (e) {
      isBookmarked = false;
      notifyListeners();
    }
  }
}

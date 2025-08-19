import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../models/trek.dart';

class TreksProvider with ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Trek> _treks = [];
  List<Trek> get treks => [..._treks];

  List<FetchedTrek> _fetchedTreks = [];
  List<FetchedTrek> get fetchedTreks => [..._fetchedTreks];

  // Fetch all treks
  Future<void> fetchTreks() async {
    try {
      List<Trek> loadedTreks = [];
      await firestore
          .collection('treks')
          .orderBy('createdAt', descending: true)
          .get()
          .then((data) {
            for (var doc in data.docs) {
              loadedTreks.add(Trek.fromMap(doc.data()));
            }
          });
      _treks = loadedTreks;
      notifyListeners();
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<void> fetchTheTreks() async {
    try {
      List<FetchedTrek> loadedTreks = [];
      final userId = FirebaseAuth.instance.currentUser?.uid;

      final data = await firestore
          .collection('treks')
          .orderBy('createdAt', descending: true)
          .get();

      for (var doc in data.docs) {
        final trek = FetchedTrek.fromMap(doc.data());

        // If user is logged in, fetch bookmark status
        if (userId != null) {
          await trek.initBookmarkStatus(userId);
        }

        loadedTreks.add(trek);
      }

      _fetchedTreks = loadedTreks;
      notifyListeners();
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  // Upload files to Firebase Storage and get URLs
  Future<List<String>> _uploadFiles(List<File> files, String folder) async {
    final List<String> urls = [];
    for (var file in files) {
      final ref = FirebaseStorage.instance.ref().child(
        '$folder/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}',
      );
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> addTrek(Trek trek) async {
    try {
      // 1️⃣ Upload trek images
      final trekImageUrls = await _uploadFiles(trek.localImages, 'treks');

      // 2️⃣ Upload mid-point images
      final List<Map<String, dynamic>> midPointsMap = [];
      for (var mp in trek.midPoints) {
        final mpUrls = await _uploadFiles(mp.images, 'midpoints');
        midPointsMap.add({
          'name': mp.name,
          'description': mp.description,
          'lat': mp.lat,
          'lng': mp.lng,
          'images': mpUrls,
        });
      }

      // 3️⃣ Prepare trek map for Firestore
      final trekMap = trek.toMap(imageUrls: trekImageUrls);
      trekMap['midPoints'] = midPointsMap;

      // 4️⃣ Save to Firestore
      await firestore.collection('treks').doc(trek.id).set(trekMap);

      // 5️⃣ Update local list
      _treks.add(trek);
      notifyListeners();
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  // Update trek
  Future<void> updateTrek(String id, Trek updatedTrek) async {
    try {
      // await firestore.collection('treks').doc(id).update(updatedTrek.toMap());
      final index = _treks.indexWhere((t) => t.id == id);
      if (index >= 0) {
        _treks[index] = updatedTrek;
        notifyListeners();
      }
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  // Delete trek
  Future<void> deleteTrek(String id) async {
    try {
      await firestore.collection('treks').doc(id).delete();
      _treks.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  // Fetch a single trek by its id
  Future<FetchedTrek?> fetchTrekById(String id) async {
    try {
      final doc = await firestore.collection('treks').doc(id).get();
      if (doc.exists) {
        return FetchedTrek.fromMap(doc.data()!);
      }
      return null; // Trek not found
    } catch (e) {
      return Future.error('Failed to fetch trek: $e');
    }
  }
}

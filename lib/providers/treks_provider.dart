import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/trek.dart';

class TreksProvider with ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Trek> _treks = [];
  List<Trek> get treks => [..._treks];

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

  // Add new trek
  Future<void> addTrek(Trek trek) async {
    print('tada');
    try {
      await firestore.collection('treks').doc(trek.id).set(trek.toMap());
      _treks.add(trek);
      notifyListeners();
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  // Update trek
  Future<void> updateTrek(String id, Trek updatedTrek) async {
    try {
      await firestore.collection('treks').doc(id).update(updatedTrek.toMap());
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
  Future<Trek?> fetchTrekById(String id) async {
    try {
      final doc = await firestore.collection('treks').doc(id).get();
      if (doc.exists) {
        return Trek.fromMap(doc.data()!);
      }
      return null; // Trek not found
    } catch (e) {
      return Future.error('Failed to fetch trek: $e');
    }
  }
}

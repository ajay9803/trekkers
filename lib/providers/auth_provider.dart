import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? user;

  AuthProvider() {
    user = _auth.currentUser;
    _auth.authStateChanges().listen((u) {
      user = u;
      notifyListeners();
    });
  }

  bool get isLoggedIn => user != null;

  // --------------------------
  // Signup with email/password + optional profile image
  // --------------------------
  Future<void> signUpWithDetails({
    required String username,
    required String email,
    required String password,
    required String address,
    required DateTime dob,
    File? profileImage,
  }) async {
    try {
      // 1️⃣ Create Firebase Auth user
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? profileImageUrl;

      // 2️⃣ Upload image if provided
      if (profileImage != null) {
        final ref = _storage
            .ref()
            .child('profile_images')
            .child('${cred.user!.uid}.jpg');
        await ref.putFile(profileImage);
        profileImageUrl = await ref.getDownloadURL();
      }

      // 3️⃣ Save user details in Firestore
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'username': username,
        'email': email,
        'address': address,
        'dob': dob.toIso8601String(),
        'role': 'user',
        'profileImageUrl': profileImageUrl ?? '',
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  // --------------------------
  // Login with email/password
  // --------------------------
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  // --------------------------
  // Google login
  // --------------------------
  Future<void> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  // --------------------------
  // Facebook login
  // --------------------------
  Future<void> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential facebookCredential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        await _auth.signInWithCredential(facebookCredential);
      } else {
        return Future.error('Facebook login failed');
      }
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  // --------------------------
  // Sign out
  // --------------------------
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<Map<String, dynamic>?> fetchUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      } else {
        return null; // User not found
      }
    } catch (e) {
      return Future.error(e.toString());
    }
  }
}

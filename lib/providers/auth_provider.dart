import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? user;
  Map<String, dynamic>? userData; // 🔑 Store Firestore user document here

  AuthProvider() {
    user = _auth.currentUser;
    _auth.authStateChanges().listen((u) async {
      user = u;
      if (user != null) {
        await loadUserData(user!.uid); // fetch Firestore data on auth change
      } else {
        userData = null;
      }
      notifyListeners();
    });
  }

  bool get isLoggedIn => user != null;
  String get role => userData?['role'] ?? 'user'; // quick role getter

  // --------------------------
  // Load user data from Firestore
  // --------------------------
  Future<void> loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        userData = doc.data();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }
  }

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
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? profileImageUrl;

      if (profileImage != null) {
        final ref = _storage
            .ref()
            .child('profile_images')
            .child('${cred.user!.uid}.jpg');
        await ref.putFile(profileImage);
        profileImageUrl = await ref.getDownloadURL();
      }

      final data = {
        'username': username,
        'email': email,
        'address': address,
        'dob': dob.toIso8601String(),
        'role': 'user',
        'profileImageUrl': profileImageUrl ?? '',
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('users').doc(cred.user!.uid).set(data);
      userData = data;
      notifyListeners();
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  // --------------------------
  // Login with email/password
  // --------------------------
  Future<void> signInWithEmail(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await loadUserData(cred.user!.uid);
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
        final cred = await _auth.signInWithPopup(googleProvider);
        await loadUserData(cred.user!.uid);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final cred = await _auth.signInWithCredential(credential);
        await loadUserData(cred.user!.uid);
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
        final cred = await _auth.signInWithCredential(facebookCredential);
        await loadUserData(cred.user!.uid);
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
    userData = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> fetchUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      } else {
        return null;
      }
    } catch (e) {
      return Future.error(e.toString());
    }
  }
}

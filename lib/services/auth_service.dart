import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  AuthService();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInAsTestUser(UserRole role) async {
    final UserCredential credential = await _auth.signInAnonymously();
    final User? user = credential.user;

    if (user == null) {
      throw Exception('Test login failed. Please try again.');
    }

    final docRef = _db.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'name': _getTestName(role),
        'email': '',
        'photoUrl': null,
        'role': roleToString(role),
        'isVerifiedSeller': role == UserRole.seller,
        'isBanned': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.update({
        'role': roleToString(role),
        'isVerifiedSeller': role == UserRole.seller,
        'isBanned': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  String _getTestName(UserRole role) {
    switch (role) {
      case UserRole.seller:
        return 'Test Seller';
      case UserRole.admin:
        return 'Test Admin';
      case UserRole.buyer:
        return 'Test Buyer';
    }
  }

  Future<void> setUserRole(UserRole role) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('No logged-in user found.');
    }

    await _db.collection('users').doc(user.uid).update({
      'role': roleToString(role),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<UserModel?> fetchUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists || doc.data() == null) return null;

    return UserModel.fromMap(uid, doc.data()!);
  }

  Stream<UserModel?> watchUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      final data = doc.data();

      if (!doc.exists || data == null) return null;

      return UserModel.fromMap(uid, data);
    });
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
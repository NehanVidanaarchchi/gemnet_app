import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

class AuthService {
  AuthService();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _googleInitialized = false;

  // IMPORTANT:
  // Paste your WEB CLIENT ID here.
  // Example: 1234567890-abcxyz.apps.googleusercontent.com
  static const String _serverClientId =
      'PASTE_YOUR_WEB_CLIENT_ID_HERE.apps.googleusercontent.com';

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> _initGoogleSignIn() async {
    if (_googleInitialized) return;

    await _googleSignIn.initialize(
      serverClientId: _serverClientId,
    );

    _googleInitialized = true;
  }

  Future<void> signInWithGoogle() async {
    await _initGoogleSignIn();

    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    final User? user = userCredential.user;

    if (user == null) {
      throw Exception('Google login failed. Please try again.');
    }

    await _createUserProfileIfMissing(
      uid: user.uid,
      name: user.displayName ?? 'GemNet User',
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
  }

  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final User? user = userCredential.user;

    if (user == null) {
      throw Exception('Registration failed. Please try again.');
    }

    await user.updateDisplayName(name.trim());

    await user.sendEmailVerification();

    await _createUserProfileIfMissing(
      uid: user.uid,
      name: name.trim(),
      email: email.trim(),
      photoUrl: null,
    );
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<void> sendVerificationEmail() async {
    final User? user = currentUser;

    if (user == null) {
      throw Exception('No logged-in user found.');
    }

    await user.sendEmailVerification();
  }

  Future<bool> reloadAndCheckEmailVerified() async {
    final User? user = currentUser;

    if (user == null) {
      return false;
    }

    await user.reload();

    final User? refreshedUser = _auth.currentUser;

    return refreshedUser?.emailVerified ?? false;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  Future<void> _createUserProfileIfMissing({
    required String uid,
    required String name,
    required String email,
    required String? photoUrl,
  }) async {
    final docRef = _db.collection('users').doc(uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'role': 'buyer',
        'isVerifiedSeller': false,
        'isBanned': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.update({
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> setUserRole(UserRole role) async {
    final User? user = currentUser;

    if (user == null) {
      throw Exception('No logged-in user found.');
    }

    await _db.collection('users').doc(user.uid).update({
      'role': roleToString(role),
      'isVerifiedSeller': role == UserRole.seller,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<UserModel?> fetchUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserModel.fromMap(uid, doc.data()!);
  }

  Stream<UserModel?> watchUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      final data = doc.data();

      if (!doc.exists || data == null) {
        return null;
      }

      return UserModel.fromMap(uid, data);
    });
  }

  Future<void> signOut() async {
    await _auth.signOut();

    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore Google sign-out errors.
    }
  }
}
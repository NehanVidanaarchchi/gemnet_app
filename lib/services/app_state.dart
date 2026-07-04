import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

/// Holds the current signed-in Firebase user's Firestore profile
/// (role, ban status, etc.) and keeps it live-updated.
class AppState extends ChangeNotifier {
  final AuthService authService;

  UserModel? currentUserProfile;
  bool isLoading = true;

  AppState(this.authService) {
    _init();
  }

  void _init() {
    authService.authStateChanges.listen((user) {
      if (user == null) {
        currentUserProfile = null;
        isLoading = false;
        notifyListeners();
      } else {
        authService.watchUserProfile(user.uid).listen((profile) {
          currentUserProfile = profile;
          isLoading = false;
          notifyListeners();
        });
      }
    });
  }

  Future<void> refresh() async {
    final uid = authService.currentUser?.uid;
    if (uid != null) {
      currentUserProfile = await authService.fetchUserProfile(uid);
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await authService.signOut();
    currentUserProfile = null;
    notifyListeners();
  }
}

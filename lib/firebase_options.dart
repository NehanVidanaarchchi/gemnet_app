import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform. '
          'Run `flutterfire configure` to generate real options.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC_s8Oal5-Hi0aQ-B61qhcKSwegxUfpEns',
    appId: '1:497687246854:web:16198494d5672c1792ab87',
    messagingSenderId: '497687246854',
    projectId: 'gemstore-3b74f',
    authDomain: 'gemstore-3b74f.firebaseapp.com',
    storageBucket: 'gemstore-3b74f.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC_s8Oal5-Hi0aQ-B61qhcKSwegxUfpEns',
    appId: '1:497687246854:android:16198494d5672c1792ab87',
    messagingSenderId: '497687246854',
    projectId: 'gemstore-3b74f',
    storageBucket: 'gemstore-3b74f.firebasestorage.app',
  );
}

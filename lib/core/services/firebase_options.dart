// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ✅ Android configuration
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyAJog1qnN81h3tPa688mB-z7Fz5YyQ7oPQ", // 👈 Copy from google-services.json
    appId: "1:379544768156:android:981651effea4cade452759",
    messagingSenderId: "379544768156",
    projectId: "manubhaimlt", // 👈 You can confirm from Firebase Console → Project Settings
    storageBucket: "manubhaimlt.appspot.com", // 👈 Or from your project storage tab
  );

  // ✅ iOS configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyCvNHSIzDXfNRQTuYB_Z1mgp1-GwBByQZM", // 👈 Copy from GoogleService-Info.plist
    appId: "1:379544768156:ios:fa78065a83dc042d452759",
    messagingSenderId: "379544768156",
    projectId: "manubhaimlt",
    storageBucket: "manubhaimlt.appspot.com",
    iosBundleId: "com.manubhai.manubhaimlt",
  );
}

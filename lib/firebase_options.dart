// File generated manually for Firebase configuration.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web platform is not configured.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios; // Reuse iOS config for macOS
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCwa2ToGXYFh9xI413Mt3O6k1NiIQKDSlI',
    appId: '1:764923695439:ios:19652afc9ecd9fbe35753a',
    messagingSenderId: '764923695439',
    projectId: 'famille-io',
    storageBucket: 'famille-io.firebasestorage.app',
    iosBundleId: 'com.example.familleIo',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCwa2ToGXYFh9xI413Mt3O6k1NiIQKDSlI',
    appId: '1:764923695439:android:9e2c37fa118cf2d635753a',
    messagingSenderId: '764923695439',
    projectId: 'famille-io',
    storageBucket: 'famille-io.firebasestorage.app',
  );
}

// File generated for ERISH Firebase scaffolding.
// Run `flutterfire configure` to generate project-specific production credentials.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAINXmXZr5XC3QAXE5B9dMY9QiGjqN-0Do',
    appId: '1:983945559161:web:1a0a274cee0883492928a8',
    messagingSenderId: '983945559161',
    projectId: 'erish-fashion',
    authDomain: 'erish-fashion.firebaseapp.com',
    storageBucket: 'erish-fashion.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCPZQrcTmqubVIjJ8HJI2SqZQ24lqfNk2U',
    appId: '1:983945559161:android:e6d2cbe098f40aca2928a8',
    messagingSenderId: '983945559161',
    projectId: 'erish-fashion',
    storageBucket: 'erish-fashion.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCYvEF_nHvclxcu55fOSmytpT3ckY51xgs',
    appId: '1:983945559161:ios:87af1eb158602a7b2928a8',
    messagingSenderId: '983945559161',
    projectId: 'erish-fashion',
    storageBucket: 'erish-fashion.firebasestorage.app',
    iosBundleId: 'com.erish.label',
  );
}

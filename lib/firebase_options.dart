
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAPYZc-Z2d__i_4-HhYbwW4VNyKSYY7ZEM',
    appId: '1:747320285370:web:74e36db4ad9fc13a22ca83',
    messagingSenderId: '747320285370',
    projectId: 'smart-attendance-system-bfde2',
    authDomain: 'smart-attendance-system-bfde2.firebaseapp.com',
    storageBucket: 'smart-attendance-system-bfde2.firebasestorage.app',
    measurementId: 'G-69X3ZSRKTB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBGr0Fx-q3cVkO6qYFlMvAA1Pfn_IJ8kI4',
    appId: '1:747320285370:android:33f2e7b5be65fe0422ca83',
    messagingSenderId: '747320285370',
    projectId: 'smart-attendance-system-bfde2',
    storageBucket: 'smart-attendance-system-bfde2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD1O_zr1mOyxLGzkwBTapak_WVocEpyx10',
    appId: '1:747320285370:ios:ead4c5875ef002f322ca83',
    messagingSenderId: '747320285370',
    projectId: 'smart-attendance-system-bfde2',
    storageBucket: 'smart-attendance-system-bfde2.firebasestorage.app',
    iosBundleId: 'com.example.attendanceApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD1O_zr1mOyxLGzkwBTapak_WVocEpyx10',
    appId: '1:747320285370:ios:ead4c5875ef002f322ca83',
    messagingSenderId: '747320285370',
    projectId: 'smart-attendance-system-bfde2',
    storageBucket: 'smart-attendance-system-bfde2.firebasestorage.app',
    iosBundleId: 'com.example.attendanceApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAPYZc-Z2d__i_4-HhYbwW4VNyKSYY7ZEM',
    appId: '1:747320285370:web:f4bc80913747379a22ca83',
    messagingSenderId: '747320285370',
    projectId: 'smart-attendance-system-bfde2',
    authDomain: 'smart-attendance-system-bfde2.firebaseapp.com',
    storageBucket: 'smart-attendance-system-bfde2.firebasestorage.app',
    measurementId: 'G-7Q56LWHQW1',
  );
}

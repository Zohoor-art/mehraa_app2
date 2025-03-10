
// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyDFrGRcqrFhuBZmlK4Zcdg7W4-Jihqjd6g',
    appId: '1:108382778388:web:4a254f97f0bdcfc4352301',
    messagingSenderId: '108382778388',
    projectId: 'mehra-app1',
    authDomain: 'mehra-app1.firebaseapp.com',
    storageBucket: 'mehra-app1.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCC0og0PrOAZMP7pdEeTOIpmEnxGQeyVL0',
    appId: '1:108382778388:android:182a9def24c55477352301',
    messagingSenderId: '108382778388',
    projectId: 'mehra-app1',
    storageBucket: 'mehra-app1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDZ86S4OAfzY89NAE2r8t-kMaMByh7TQZw',
    appId: '1:108382778388:ios:1e5aec2df4f83a1f352301',
    messagingSenderId: '108382778388',
    projectId: 'mehra-app1',
    storageBucket: 'mehra-app1.firebasestorage.app',
    iosBundleId: 'com.example.mehraApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDZ86S4OAfzY89NAE2r8t-kMaMByh7TQZw',
    appId: '1:108382778388:ios:1e5aec2df4f83a1f352301',
    messagingSenderId: '108382778388',
    projectId: 'mehra-app1',
    storageBucket: 'mehra-app1.firebasestorage.app',
    iosBundleId: 'com.example.mehraApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDFrGRcqrFhuBZmlK4Zcdg7W4-Jihqjd6g',
    appId: '1:108382778388:web:f799cace930e9489352301',
    messagingSenderId: '108382778388',
    projectId: 'mehra-app1',
    authDomain: 'mehra-app1.firebaseapp.com',
    storageBucket: 'mehra-app1.firebasestorage.app',
  );
}

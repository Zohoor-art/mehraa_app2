// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

// / Default [FirebaseOptions] for use with your Firebase apps.
// /
// / Example:
// / ```dart
// / import 'firebase_options.dart';
// / // ...
// / await Firebase.initializeApp(
// /   options: DefaultFirebaseOptions.currentPlatform,
// / );
// / ```
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
    apiKey: 'AIzaSyBQNoYhpXD-Xdvjr39lahYBZo5iABgC-U0',
    appId: '1:617347888301:web:e28a1b1bfb259b3950c224',
    messagingSenderId: '617347888301',
    projectId: 'greentaxi-44f9b',
    authDomain: 'greentaxi-44f9b.firebaseapp.com',
    databaseURL: 'https://greentaxi-44f9b-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'greentaxi-44f9b.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA6w-8lYiWXcksdEETpYBtSgwO_SboNhDM',
    appId: '1:617347888301:android:f9ffac81b7064f3e50c224',
    messagingSenderId: '617347888301',
    projectId: 'greentaxi-44f9b',
    databaseURL: 'https://greentaxi-44f9b-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'greentaxi-44f9b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCzrlMi9sB2kN85CjmIxcnLLFzYZuju4sM',
    appId: '1:617347888301:ios:ef413816f7ca86f450c224',
    messagingSenderId: '617347888301',
    projectId: 'greentaxi-44f9b',
    databaseURL: 'https://greentaxi-44f9b-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'greentaxi-44f9b.appspot.com',
    iosBundleId: 'com.example.mehraApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCzrlMi9sB2kN85CjmIxcnLLFzYZuju4sM',
    appId: '1:617347888301:ios:ef413816f7ca86f450c224',
    messagingSenderId: '617347888301',
    projectId: 'greentaxi-44f9b',
    databaseURL: 'https://greentaxi-44f9b-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'greentaxi-44f9b.appspot.com',
    iosBundleId: 'com.example.mehraApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBI7Qd1ldg0B0fuI_ddEO-VEhqeOakqyWs',
    appId: '1:617347888301:web:fa9f7c7f2e61d24b50c224',
    messagingSenderId: '617347888301',
    projectId: 'greentaxi-44f9b',
    authDomain: 'greentaxi-44f9b.firebaseapp.com',
    databaseURL: 'https://greentaxi-44f9b-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'greentaxi-44f9b.appspot.com',
  );
}

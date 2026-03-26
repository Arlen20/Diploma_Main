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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCiAtDvslF81mDWgkhYeMGwjyhbGaj6AsI',
    appId: '1:206676098403:web:4118f158d806bd241ba756',
    messagingSenderId: '206676098403',
    projectId: 'diploma-fitness-app',
    authDomain: 'diploma-fitness-app.firebaseapp.com',
    storageBucket: 'diploma-fitness-app.firebasestorage.app',
    measurementId: 'G-VZTLSPCEPY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBS9oG3sjosk6lL0NbXCW-U_yN1AHGPdPQ',
    appId: '1:206676098403:android:5565103ee58f91991ba756',
    messagingSenderId: '206676098403',
    projectId: 'diploma-fitness-app',
    storageBucket: 'diploma-fitness-app.firebasestorage.app',
  );
}

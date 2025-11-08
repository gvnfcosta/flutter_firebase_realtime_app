import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    } else if (Platform.isAndroid) {
      return android;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are only supported for Web in this project.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDyTE_nQuQYDx4j7NBYH-xJDyUytnxLB6s",
    authDomain: "user-6fcc5.firebaseapp.com",
    projectId: "user-6fcc5",
    storageBucket: "user-6fcc5.firebasestorage.app",
    messagingSenderId: "867267302263",
    appId: "1:867267302263:web:cfa20b00db23d048a84772",
    // Se usar Realtime Database:
    databaseURL:
        "https://user-6fcc5-default-rtdb.europe-west1.firebasedatabase.app/",
    // databaseURL: "https://user-6fcc5-default-rtdb.firebaseio.com",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDyTE_nQuQYDx4j7NBYH-xJDyUytnxLB6s",
    appId: "1:867267302263:android:3e4b2a00db23d048a84772",
    messagingSenderId: "867267302263",
    projectId: "user-6fcc5",
    storageBucket: "user-6fcc5.firebasestorage.app",
    databaseURL:
        "https://user-6fcc5-default-rtdb.europe-west1.firebasedatabase.app/",
  );
}

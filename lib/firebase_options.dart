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
    apiKey: 'AIzaSyClz3dB5ww3KrqXTm2ssr85eKIjxNwpEfk',
    appId: '1:964139724412:web:34d55ab563e898f594a3f9',
    messagingSenderId: '964139724412',
    projectId: 'pokeeserver',
    authDomain: 'pokeeserver.firebaseapp.com',
    databaseURL: 'https://pokeeserver-default-rtdb.firebaseio.com',
    storageBucket: 'pokeeserver.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKs_QvEcDtgxdtMbNoW4VNNRW7-nTUfnQ',
    appId: '1:964139724412:android:b7755af680d5b7f794a3f9',
    messagingSenderId: '964139724412',
    projectId: 'pokeeserver',
    databaseURL: 'https://pokeeserver-default-rtdb.firebaseio.com',
    storageBucket: 'pokeeserver.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD5c1mIV12vZjIRFSFnAnAUnZpKSkyrL2k',
    appId: '1:964139724412:ios:6a2309bcfccb5cbb94a3f9',
    messagingSenderId: '964139724412',
    projectId: 'pokeeserver',
    databaseURL: 'https://pokeeserver-default-rtdb.firebaseio.com',
    storageBucket: 'pokeeserver.appspot.com',
    androidClientId:
        '964139724412-dts0nqbl9t1cvlrgrjd1jbl2dqhqhdq4.apps.googleusercontent.com',
    iosClientId:
        '964139724412-0ne5ikmk6o3s32jejsuhedohs128nek0.apps.googleusercontent.com',
    iosBundleId: 'com.example.titoApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD5c1mIV12vZjIRFSFnAnAUnZpKSkyrL2k',
    appId: '1:964139724412:ios:6a2309bcfccb5cbb94a3f9',
    messagingSenderId: '964139724412',
    projectId: 'pokeeserver',
    databaseURL: 'https://pokeeserver-default-rtdb.firebaseio.com',
    storageBucket: 'pokeeserver.appspot.com',
    androidClientId:
        '964139724412-dts0nqbl9t1cvlrgrjd1jbl2dqhqhdq4.apps.googleusercontent.com',
    iosClientId:
        '964139724412-0ne5ikmk6o3s32jejsuhedohs128nek0.apps.googleusercontent.com',
    iosBundleId: 'com.example.titoApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyClz3dB5ww3KrqXTm2ssr85eKIjxNwpEfk',
    appId: '1:964139724412:web:95ef66652e4cd33494a3f9',
    messagingSenderId: '964139724412',
    projectId: 'pokeeserver',
    authDomain: 'pokeeserver.firebaseapp.com',
    databaseURL: 'https://pokeeserver-default-rtdb.firebaseio.com',
    storageBucket: 'pokeeserver.appspot.com',
  );
}

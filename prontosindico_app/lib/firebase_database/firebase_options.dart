// Firebase Options - Centralizado
// Mesmo projeto Firebase para todos os ambientes (dev, hml, prod)
// As diferenças entre ambientes (API_URL, APP_TITLE, etc) estão em config_*.json
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:prontosindico/config/app_config.dart';


/// Default [FirebaseOptions] - Mesmo para todos os ambientes
/// Default [FirebaseOptions] - Agora dinâmico baseado no ambiente
class DefaultFirebaseOptions {
  static FirebaseOptions options(AppConfig config) {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android(config);
      case TargetPlatform.iOS:
        return ios(config);
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions android(AppConfig config) => FirebaseOptions(
        apiKey: config.firebaseApiKey.isNotEmpty 
            ? config.firebaseApiKey 
            : 'AIzaSyCR50YsFWGyiR7dKcI7gZ6QE2UNJJ6hF98',
        appId: config.firebaseAppId.isNotEmpty 
            ? config.firebaseAppId 
            : '1:253104354974:android:555a47e166273d93916d8f',
        messagingSenderId: config.firebaseMessagingSenderId,
        projectId: config.firebaseProjectId,
        databaseURL: 'https://${config.firebaseProjectId}-default-rtdb.firebaseio.com',
        storageBucket: '${config.firebaseProjectId}.firebasestorage.app',
      );

  static FirebaseOptions ios(AppConfig config) => FirebaseOptions(
        apiKey: config.firebaseApiKey.isNotEmpty 
            ? config.firebaseApiKey 
            : 'AIzaSyBkGMkpZXgNqTtrbdtgBm78h0jwEwG10XI',
        appId: config.firebaseAppId.isNotEmpty 
            ? config.firebaseAppId 
            : '1:253104354974:ios:a06d41ea3e5a146f916d8f',
        messagingSenderId: config.firebaseMessagingSenderId,
        projectId: config.firebaseProjectId,
        databaseURL: 'https://${config.firebaseProjectId}-default-rtdb.firebaseio.com',
        storageBucket: '${config.firebaseProjectId}.firebasestorage.app',
        iosClientId: '253104354974-8i3flvgeqqvia5jj7vnshm2gsvcvp8fj.apps.googleusercontent.com',
        iosBundleId: config.flavor == Environment.prod 
            ? 'com.prontosindico.prontosindico' 
            : 'com.prontosindico.prontosindico.${config.flavor.name}',
      );
}


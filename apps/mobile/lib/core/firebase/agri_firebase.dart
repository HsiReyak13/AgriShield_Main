import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class AgriFirebase {
  const AgriFirebase._();

  static Future<FirebaseApp> initialize({FirebaseOptions? options}) {
    if (options != null) {
      return Firebase.initializeApp(options: options);
    }

    return Firebase.initializeApp();
  }

  static FirebaseDatabase database({FirebaseApp? app, String? databaseUrl}) {
    final firebaseApp = app ?? Firebase.app();
    if (databaseUrl == null || databaseUrl.isEmpty) {
      return FirebaseDatabase.instanceFor(app: firebaseApp);
    }

    return FirebaseDatabase.instanceFor(
      app: firebaseApp,
      databaseURL: databaseUrl,
    );
  }
}

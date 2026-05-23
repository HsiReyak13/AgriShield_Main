import 'package:firebase_core/firebase_core.dart';

class AgriFirebase {
  const AgriFirebase._();

  static Future<FirebaseApp> initialize({FirebaseOptions? options}) {
    if (options != null) {
      return Firebase.initializeApp(options: options);
    }

    return Firebase.initializeApp();
  }
}

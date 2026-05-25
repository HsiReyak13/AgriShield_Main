import 'package:agrishield/bootstrap.dart';
import 'package:agrishield/core/firebase/agri_firebase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// To use Firebase, run `flutterfire configure` to generate firebase_options.dart
// Then uncomment the import and the options parameter below.
// import 'firebase_options.dart';

Future<void> main() {
  return bootstrapAgriShield(
    initializeFirebase: () async {
      try {
        await AgriFirebase.initialize(
          // options: DefaultFirebaseOptions.currentPlatform,
        );
      } on FirebaseException catch (e, st) {
        if (kDebugMode) {
          print('Firebase initialization failed: ${e.message}');
          print(
            'Please run `flutterfire configure` or add google-services.json.',
          );
        } else {
          Error.throwWithStackTrace(e, st);
        }
      } catch (e, st) {
        if (kDebugMode) {
          print('Firebase initialization error: $e');
        } else {
          Error.throwWithStackTrace(e, st);
        }
      }
    },
  );
}

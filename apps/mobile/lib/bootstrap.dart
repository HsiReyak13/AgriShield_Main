import 'package:agrishield/app/app.dart';
import 'package:flutter/material.dart';

typedef FirebaseInitializer = Future<void> Function();

Future<void> bootstrapAgriShield({
  FirebaseInitializer? initializeFirebase,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase?.call();
  runApp(const AgriShieldApp());
}

import 'package:agrishield/app/app.dart';
import 'package:agrishield/core/firebase/firebase_database_provider.dart';
import 'package:agrishield/core/repositories/device_connection_repository.dart';
import 'package:flutter/material.dart';

typedef FirebaseInitializer = Future<void> Function();

Future<void> bootstrapAgriShield({
  FirebaseInitializer? initializeFirebase,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase?.call();
  final repository = FirebaseDeviceConnectionRepository(
    lookupDataSource: initializeFirebase == null
        ? const UnavailableDeviceCodeLookupDataSource()
        : FirebaseDatabaseProvider.instance(),
  );
  runApp(AgriShieldApp(deviceConnectionRepository: repository));
}

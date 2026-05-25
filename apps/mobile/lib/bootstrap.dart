import 'package:agrishield/app/app.dart';
import 'package:agrishield/core/firebase/firebase_database_provider.dart';
<<<<<<< HEAD
import 'package:agrishield/core/repositories/device_connection_repository.dart';
=======
import 'package:agrishield/core/repositories/alert_repository.dart';
import 'package:agrishield/core/repositories/device_connection_repository.dart';
import 'package:agrishield/core/repositories/live_telemetry_repository.dart';
import 'package:firebase_core/firebase_core.dart';
>>>>>>> origin/main
import 'package:flutter/material.dart';

typedef FirebaseInitializer = Future<void> Function();

Future<void> bootstrapAgriShield({
  FirebaseInitializer? initializeFirebase,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase?.call();
<<<<<<< HEAD
  final repository = FirebaseDeviceConnectionRepository(
    lookupDataSource: initializeFirebase == null
        ? const UnavailableDeviceCodeLookupDataSource()
        : FirebaseDatabaseProvider.instance(),
  );
  runApp(AgriShieldApp(deviceConnectionRepository: repository));
=======
  final firebaseReady = initializeFirebase != null && Firebase.apps.isNotEmpty;
  final repository = FirebaseDeviceConnectionRepository(
    lookupDataSource: firebaseReady
        ? FirebaseDatabaseProvider.instance()
        : const UnavailableDeviceCodeLookupDataSource(),
  );
  final liveTelemetryRepository = FirebaseLiveTelemetryRepository(
    dataSource: firebaseReady
        ? FirebaseDatabaseProvider.instance()
        : const UnavailableLiveTelemetryDataSource(),
  );
  final alertRepository = FirebaseAlertRepository(
    dataSource: firebaseReady
        ? FirebaseDatabaseProvider.instance()
        : const UnavailableAlertDataSource(),
  );
  runApp(
    AgriShieldApp(
      deviceConnectionRepository: repository,
      liveTelemetryRepository: liveTelemetryRepository,
      alertRepository: alertRepository,
    ),
  );
>>>>>>> origin/main
}

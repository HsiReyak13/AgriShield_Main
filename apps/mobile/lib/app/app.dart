import 'package:agrishield/app/router.dart';
import 'package:agrishield/app/theme/agri_theme.dart';
<<<<<<< HEAD
import 'package:agrishield/core/repositories/device_connection_repository.dart';
=======
import 'package:agrishield/core/repositories/alert_repository.dart';
import 'package:agrishield/core/repositories/device_connection_repository.dart';
import 'package:agrishield/core/repositories/live_telemetry_repository.dart';
>>>>>>> origin/main
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AgriShieldApp extends StatelessWidget {
<<<<<<< HEAD
  const AgriShieldApp({
    GoRouter? router,
    DeviceConnectionRepository? deviceConnectionRepository,
    super.key,
  }) : _router = router,
       _deviceConnectionRepository = deviceConnectionRepository;

  final GoRouter? _router;
  final DeviceConnectionRepository? _deviceConnectionRepository;
=======
  AgriShieldApp({
    GoRouter? router,
    DeviceConnectionRepository? deviceConnectionRepository,
    LiveTelemetryRepository? liveTelemetryRepository,
    AlertRepository? alertRepository,
    super.key,
  }) : _router =
           router ??
           createAppRouter(
             deviceConnectionRepository:
                 deviceConnectionRepository ??
                 FirebaseDeviceConnectionRepository(
                   lookupDataSource:
                       const UnavailableDeviceCodeLookupDataSource(),
                 ),
             liveTelemetryRepository:
                 liveTelemetryRepository ??
                 const FirebaseLiveTelemetryRepository(
                   dataSource: UnavailableLiveTelemetryDataSource(),
                 ),
             alertRepository:
                 alertRepository ??
                 const FirebaseAlertRepository(
                   dataSource: UnavailableAlertDataSource(),
                 ),
           );

  final GoRouter _router;
>>>>>>> origin/main

  @override
  Widget build(BuildContext context) {
    final router =
        _router ??
        createAppRouter(
          deviceConnectionRepository:
              _deviceConnectionRepository ??
              FirebaseDeviceConnectionRepository(
                lookupDataSource: const UnavailableDeviceCodeLookupDataSource(),
              ),
        );

    return MaterialApp.router(
      title: 'AgriShield PH',
      debugShowCheckedModeBanner: false,
      theme: AgriTheme.light(),
<<<<<<< HEAD
      routerConfig: router,
=======
      routerConfig: _router,
>>>>>>> origin/main
    );
  }
}

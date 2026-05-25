import 'package:agrishield/app/router.dart';
import 'package:agrishield/app/theme/agri_theme.dart';
import 'package:agrishield/core/repositories/alert_repository.dart';
import 'package:agrishield/core/repositories/device_connection_repository.dart';
import 'package:agrishield/core/repositories/live_telemetry_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AgriShieldApp extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AgriShield PH',
      debugShowCheckedModeBanner: false,
      theme: AgriTheme.light(),
      routerConfig: _router,
    );
  }
}

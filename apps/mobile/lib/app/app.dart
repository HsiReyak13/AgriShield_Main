import 'package:agrishield/app/router.dart';
import 'package:agrishield/app/theme/agri_theme.dart';
import 'package:agrishield/core/repositories/device_connection_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AgriShieldApp extends StatelessWidget {
  const AgriShieldApp({
    GoRouter? router,
    DeviceConnectionRepository? deviceConnectionRepository,
    super.key,
  }) : _router = router,
       _deviceConnectionRepository = deviceConnectionRepository;

  final GoRouter? _router;
  final DeviceConnectionRepository? _deviceConnectionRepository;

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
      routerConfig: router,
    );
  }
}

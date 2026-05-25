import 'package:agrishield/core/repositories/alert_repository.dart';
import 'package:agrishield/core/repositories/device_connection_repository.dart';
import 'package:agrishield/core/repositories/live_telemetry_repository.dart';
import 'package:agrishield/features/alerts/presentation/screens/alert_detail_screen.dart';
import 'package:agrishield/features/dashboard/view/prototype_screens.dart';
import 'package:agrishield/features/demo_mode/view/demo_mode_screen.dart';
import 'package:agrishield/features/device_pairing/cubit/device_pairing_cubit.dart';
import 'package:agrishield/features/device_pairing/view/device_pairing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

const _savedConnectionLookupTimeout = Duration(seconds: 5);

GoRouter createAppRouter({
  required DeviceConnectionRepository deviceConnectionRepository,
  LiveTelemetryRepository liveTelemetryRepository =
      const FirebaseLiveTelemetryRepository(
        dataSource: UnavailableLiveTelemetryDataSource(),
      ),
  AlertRepository alertRepository = const FirebaseAlertRepository(
    dataSource: UnavailableAlertDataSource(),
  ),
  String initialLocation = '/',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    redirect: (context, state) async {
      final path = state.uri.path;
      if (path == '/demo') return null;

      Object? connection;
      try {
        connection = await deviceConnectionRepository
            .readSavedConnection()
            .timeout(_savedConnectionLookupTimeout);
      } catch (_) {
        connection = null;
      }
      final isPaired = connection != null;

      if (path == '/') return isPaired ? '/field' : '/pair';
      if (isPaired && path == '/pair') return '/field';
      if (!isPaired && (path == '/field' || path.startsWith('/field/'))) {
        return '/pair';
      }
      if (!isPaired && (path == '/settings' || path.startsWith('/settings/'))) {
        return '/pair';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/field'),
      GoRoute(
        path: '/pair',
        name: 'pair',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              DevicePairingCubit(repository: deviceConnectionRepository)
                ..load(),
          child: const DevicePairingScreen(),
        ),
      ),
      GoRoute(
        path: '/field',
        name: 'field',
        builder: (context, state) => AgriShell(
          deviceConnectionRepository: deviceConnectionRepository,
          liveTelemetryRepository: liveTelemetryRepository,
          alertRepository: alertRepository,
          initialTab: appTabFromRoute(state.uri.queryParameters['tab']),
        ),
        routes: [
          GoRoute(
            path: 'alerts/:alertId',
            name: 'alert-detail',
            builder: (context, state) => AlertDetailScreen(
              alertId: state.pathParameters['alertId'] ?? 'latest',
              alertRepository: alertRepository,
              deviceConnectionRepository: deviceConnectionRepository,
            ),
          ),
          GoRoute(
            path: ':id',
            name: 'field-detail',
            builder: (context, state) => AgriShell(
              deviceConnectionRepository: deviceConnectionRepository,
              liveTelemetryRepository: liveTelemetryRepository,
              alertRepository: alertRepository,
              initialTab: appTabFromRoute(state.uri.queryParameters['tab']),
              fieldId: state.pathParameters['id'],
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/demo',
        name: 'demo',
        builder: (context, state) => const DemoModeScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => AgriShell(
          deviceConnectionRepository: deviceConnectionRepository,
          liveTelemetryRepository: liveTelemetryRepository,
          alertRepository: alertRepository,
          initialTab: AppTab.settings,
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri.path}')),
    ),
  );
}

final appRouter = createAppRouter(
  deviceConnectionRepository: FirebaseDeviceConnectionRepository(
    lookupDataSource: const UnavailableDeviceCodeLookupDataSource(),
  ),
  liveTelemetryRepository: const FirebaseLiveTelemetryRepository(
    dataSource: UnavailableLiveTelemetryDataSource(),
  ),
  alertRepository: const FirebaseAlertRepository(
    dataSource: UnavailableAlertDataSource(),
  ),
);

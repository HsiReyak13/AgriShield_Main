<<<<<<< HEAD
import 'package:agrishield/core/repositories/device_connection_repository.dart';
=======
import 'package:agrishield/core/repositories/alert_repository.dart';
import 'package:agrishield/core/repositories/device_connection_repository.dart';
import 'package:agrishield/core/repositories/live_telemetry_repository.dart';
>>>>>>> origin/main
import 'package:agrishield/features/dashboard/view/prototype_screens.dart';
import 'package:agrishield/features/demo_mode/view/demo_mode_screen.dart';
import 'package:agrishield/features/device_pairing/cubit/device_pairing_cubit.dart';
import 'package:agrishield/features/device_pairing/view/device_pairing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter({
  required DeviceConnectionRepository deviceConnectionRepository,
<<<<<<< HEAD
=======
  LiveTelemetryRepository liveTelemetryRepository =
      const FirebaseLiveTelemetryRepository(
        dataSource: UnavailableLiveTelemetryDataSource(),
      ),
  AlertRepository alertRepository = const FirebaseAlertRepository(
    dataSource: UnavailableAlertDataSource(),
  ),
>>>>>>> origin/main
  String initialLocation = '/',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    redirect: (context, state) async {
      final path = state.uri.path;
      if (path == '/demo') return null;

<<<<<<< HEAD
      final connection = await deviceConnectionRepository.readSavedConnection();
      final isPaired = connection != null;

      if (path == '/') return isPaired ? '/field' : '/pair';
      if (!isPaired && (path == '/field' || path.startsWith('/field/'))) {
        return '/pair';
      }
      if (!isPaired && path == '/settings') return '/pair';
=======
      Object? connection;
      try {
        connection = await deviceConnectionRepository.readSavedConnection();
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
>>>>>>> origin/main

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
<<<<<<< HEAD
          initialTab: appTabFromRoute(state.uri.queryParameters['tab']),
          initialTrustState: trustStateFromRoute(
            state.uri.queryParameters['mode'],
          ),
=======
          liveTelemetryRepository: liveTelemetryRepository,
          alertRepository: alertRepository,
          initialTab: appTabFromRoute(state.uri.queryParameters['tab']),
>>>>>>> origin/main
        ),
        routes: [
          GoRoute(
            path: 'alerts/:alertId',
            name: 'alert-detail',
            builder: (context, state) => AlertDetailPlaceholderScreen(
              alertId: state.pathParameters['alertId'] ?? 'latest',
            ),
          ),
          GoRoute(
            path: ':id',
            name: 'field-detail',
            builder: (context, state) => AgriShell(
              deviceConnectionRepository: deviceConnectionRepository,
<<<<<<< HEAD
              initialTrustState: trustStateFromRoute(
                state.uri.queryParameters['mode'],
              ),
=======
              liveTelemetryRepository: liveTelemetryRepository,
              alertRepository: alertRepository,
              initialTab: appTabFromRoute(state.uri.queryParameters['tab']),
>>>>>>> origin/main
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
<<<<<<< HEAD
          initialTab: AppTab.more,
          initialTrustState: trustStateFromRoute(
            state.uri.queryParameters['mode'],
          ),
=======
          liveTelemetryRepository: liveTelemetryRepository,
          alertRepository: alertRepository,
          initialTab: AppTab.settings,
>>>>>>> origin/main
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
<<<<<<< HEAD
=======
  liveTelemetryRepository: const FirebaseLiveTelemetryRepository(
    dataSource: UnavailableLiveTelemetryDataSource(),
  ),
  alertRepository: const FirebaseAlertRepository(
    dataSource: UnavailableAlertDataSource(),
  ),
>>>>>>> origin/main
);

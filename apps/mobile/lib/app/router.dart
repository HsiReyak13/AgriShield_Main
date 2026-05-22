import 'package:agrishield/features/dashboard/view/prototype_screens.dart';
import 'package:agrishield/features/demo_mode/view/demo_mode_screen.dart';
import 'package:agrishield/features/device_pairing/view/device_pairing_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter({String initialLocation = '/field'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/field',
      ),
      GoRoute(
        path: '/pair',
        name: 'pair',
        builder: (context, state) => const DevicePairingScreen(),
      ),
      GoRoute(
        path: '/field',
        name: 'field',
        builder: (context, state) => const AgriShell(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'field-detail',
            builder: (context, state) => AgriShell(
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
        builder: (context, state) =>
            const AgriShell(initialTab: AppTab.settings),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri.path}')),
    ),
  );
}

final appRouter = createAppRouter();

import 'package:agrishield/app/router.dart';
import 'package:agrishield/app/theme/agri_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AgriShieldApp extends StatelessWidget {
  const AgriShieldApp({GoRouter? router, super.key}) : _router = router;

  final GoRouter? _router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AgriShield PH',
      debugShowCheckedModeBanner: false,
      theme: AgriTheme.light(),
      routerConfig: _router ?? appRouter,
    );
  }
}

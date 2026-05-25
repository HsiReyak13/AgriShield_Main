import 'package:agrishield/app/app.dart';
import 'package:agrishield/app/router.dart';
import 'package:agrishield/app/theme/agri_tokens.dart';
import 'package:agrishield/core/repositories/device_connection_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  late GoRouter router;

  Future<void> pumpAgriShield(WidgetTester tester) async {
    router = createAppRouter(
      deviceConnectionRepository: FirebaseDeviceConnectionRepository(
        lookupDataSource: const UnavailableDeviceCodeLookupDataSource(),
        connectionStore: MemoryDeviceConnectionStore(),
      ),
    );
    await tester.pumpWidget(AgriShieldApp(router: router));
    await tester.pumpAndSettle();
  }

  testWidgets('shows Apple Field Health dashboard and navigation', (tester) async {
    await pumpAgriShield(tester);

    expect(find.text('Good Morning, Juan'), findsOneWidget);
    expect(find.text('Field Health'), findsOneWidget);
    expect(find.text('Soil Moisture'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('Alerts'));
    await tester.pumpAndSettle();

    expect(find.text('High Temperature Alert'), findsOneWidget);
    expect(find.text('Low Water Level Warning'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Juan dela Cruz'), findsOneWidget);
    expect(find.text('Device offline'), findsNothing);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('demo mode can be enabled and returned to live data', (tester) async {
    await pumpAgriShield(tester);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Demo Mode'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Demo Mode'));
    await tester.pumpAndSettle();

    expect(find.textContaining('simulated readings'), findsOneWidget);

    await tester.ensureVisible(find.text('Live'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Live'));
    await tester.pumpAndSettle();

    expect(find.textContaining('simulated readings'), findsNothing);
  });

  testWidgets('trust state cycle exposes recovery states', (tester) async {
    await pumpAgriShield(tester);

    await tester.ensureVisible(find.text('Cycle state'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cycle state'));
    await tester.pumpAndSettle();
    expect(find.text('Needs attention'), findsOneWidget);

    await tester.tap(find.text('View advice'));
    await tester.pumpAndSettle();
    expect(find.text('Normal Condition'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.home_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Refresh'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Refresh'));
    await tester.pumpAndSettle();
    expect(find.text('Critical field condition'), findsOneWidget);
  });

  testWidgets('router can render field and settings routes', (tester) async {
    await pumpAgriShield(tester);

    expect(find.text('Field Health'), findsOneWidget);

    router.go('/settings');
    await tester.pumpAndSettle();

    expect(find.text('Juan dela Cruz'), findsOneWidget);
  });

  testWidgets('semantic AgriShield theme tokens are available', (tester) async {
    await pumpAgriShield(tester);

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    final tokens = materialApp.theme?.extension<AgriFieldTokens>();

    expect(tokens, isNotNull);
    expect(tokens!.statusOkay, const Color(0xFF34C759));
    expect(find.text('Healthy'), findsOneWidget);
  });

  testWidgets('navigation tabs update app state and return to dashboard', (tester) async {
    await pumpAgriShield(tester);

    await tester.tap(find.text('Alerts'));
    await tester.pumpAndSettle();
    expect(find.text('High Temperature Alert'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Good Morning, Juan'), findsOneWidget);
    expect(find.text('Field Health'), findsOneWidget);
  });
}

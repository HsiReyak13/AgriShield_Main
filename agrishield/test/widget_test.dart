import 'package:agrishield/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows Apple Field Health dashboard and navigation', (tester) async {
    await tester.pumpWidget(const AgriShieldApp());

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
    expect(find.text('Device Status'), findsOneWidget);
  });

  testWidgets('demo mode can be enabled and returned to live data', (tester) async {
    await tester.pumpWidget(const AgriShieldApp());

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Demo Mode').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('simulated readings'), findsOneWidget);

    await tester.tap(find.text('Live'));
    await tester.pumpAndSettle();

    expect(find.textContaining('simulated readings'), findsNothing);
  });

  testWidgets('trust state cycle exposes recovery states', (tester) async {
    await tester.pumpWidget(const AgriShieldApp());

    await tester.tap(find.text('Cycle state'));
    await tester.pumpAndSettle();
    expect(find.text('Needs attention'), findsOneWidget);

    await tester.tap(find.text('View advice'));
    await tester.pumpAndSettle();
    expect(find.text('Normal Condition'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.home_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cycle state'));
    await tester.pumpAndSettle();
    expect(find.text('Critical field condition'), findsOneWidget);
  });
}

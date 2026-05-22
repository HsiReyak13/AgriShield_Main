import 'package:agrishield/features/dashboard/view/prototype_screens.dart'
    as prototype;
import 'package:flutter/material.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return prototype.PageFrame(
      title: 'Alerts',
      subtitle: 'Recent warnings and field conditions',
      children: prototype.MockAgriData.alerts
          .map(
            (alert) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: prototype.AlertCard(alert: alert),
            ),
          )
          .toList(),
    );
  }
}

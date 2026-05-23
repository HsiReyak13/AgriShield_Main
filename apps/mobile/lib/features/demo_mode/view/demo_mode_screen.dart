import 'package:agrishield/core/widgets/app_placeholder_screen.dart';
import 'package:flutter/widgets.dart';

class DemoModeScreen extends StatelessWidget {
  const DemoModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPlaceholderScreen(
      title: 'Demo Mode',
      message:
          'Use simulated field readings when live hardware is unavailable.',
    );
  }
}

import 'package:agrishield/core/widgets/app_placeholder_screen.dart';
import 'package:flutter/widgets.dart';

class DevicePairingScreen extends StatelessWidget {
  const DevicePairingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPlaceholderScreen(
      title: 'Pair Device',
      message: 'Device-code pairing will be added in the pairing story.',
    );
  }
}

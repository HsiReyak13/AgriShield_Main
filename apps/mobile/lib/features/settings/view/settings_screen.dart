import 'package:agrishield/app/theme/agri_theme.dart';
import 'package:agrishield/core/models/trust_state.dart';
import 'package:agrishield/features/dashboard/view/prototype_screens.dart'
    as prototype;
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.trustState,
    required this.onCycleState,
    required this.onEnableDemoMode,
    required this.onReturnToLiveData,
    super.key,
  });

  final TrustState trustState;
  final VoidCallback onCycleState;
  final VoidCallback onEnableDemoMode;
  final VoidCallback onReturnToLiveData;

  @override
  Widget build(BuildContext context) {
    return prototype.PageFrame(
      title: 'Settings',
      children: [
        const prototype.ProfileCard(),
        const SizedBox(height: 24),
        const prototype.SectionLabel('Device Status'),
        const SizedBox(height: 10),
        prototype.DeviceRecoveryCard(
          trustState: trustState,
          onRefresh: onCycleState,
          onEnableDemoMode: onEnableDemoMode,
          onReturnToLiveData: onReturnToLiveData,
        ),
        const SizedBox(height: 24),
        const prototype.SectionLabel('Language'),
        const SizedBox(height: 10),
        const prototype.LanguageSelector(),
        const SizedBox(height: 24),
        const prototype.SectionLabel('Notifications'),
        const SizedBox(height: 10),
        const prototype.SettingsToggle(
          label: 'In-app alerts',
          icon: Icons.notifications_none,
        ),
        const prototype.SettingsToggle(
          label: 'Warning alerts',
          icon: Icons.circle,
          iconColor: AgriTheme.warning,
        ),
        const prototype.SettingsToggle(
          label: 'Critical alerts',
          icon: Icons.circle,
          iconColor: AgriTheme.critical,
        ),
        const SizedBox(height: 24),
        const prototype.SectionLabel('Farm Information'),
        const SizedBox(height: 10),
        const prototype.FarmInfoCard(),
      ],
    );
  }
}

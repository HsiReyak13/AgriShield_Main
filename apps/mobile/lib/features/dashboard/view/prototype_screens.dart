import 'dart:math' as math;

import 'package:agrishield/app/theme/agri_theme.dart';
import 'package:agrishield/app/theme/agri_tokens.dart';
import 'package:agrishield/core/logic/field_status_classifier.dart';
import 'package:agrishield/core/models/device_connection.dart';
import 'package:agrishield/core/models/field_status.dart';
import 'package:agrishield/core/models/trust_state.dart';
import 'package:agrishield/core/repositories/alert_repository.dart';
import 'package:agrishield/core/repositories/device_connection_repository.dart';
import 'package:agrishield/core/repositories/live_telemetry_repository.dart';
import 'package:agrishield/features/alerts/logic/alert_generator.dart';
import 'package:agrishield/features/alerts/presentation/screens/alerts_screen.dart'
    as alerts_ui;
import 'package:agrishield/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

enum AppTab { home, alerts, advice, history, settings }

enum AlertSeverity { critical, warning, attention, normal }

AppTab appTabFromRoute(String? tab) {
  return switch (tab) {
    'alerts' => AppTab.alerts,
    'advice' => AppTab.advice,
    'history' => AppTab.history,
    'settings' => AppTab.settings,
    _ => AppTab.home,
  };
}

class SensorMetric {
  const SensorMetric({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.points,
    required this.severityLabel,
    required this.freshnessLabel,
    this.isWarning = false,
    this.isUnavailable = false,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final List<double> points;
  final String severityLabel;
  final String freshnessLabel;
  final bool isWarning;
  final bool isUnavailable;
}

class FieldAlert {
  const FieldAlert({
    required this.title,
    required this.body,
    required this.time,
    required this.severity,
  });

  final String title;
  final String body;
  final String time;
  final AlertSeverity severity;
}

class AdviceItem {
  const AdviceItem({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    this.hasWarningDot = false,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final bool hasWarningDot;
}

class HistoryReading {
  const HistoryReading({
    required this.date,
    required this.time,
    required this.status,
    required this.values,
  });

  final String date;
  final String time;
  final AlertSeverity status;
  final Map<String, String> values;
}

class MockAgriData {
  static const metrics = [
    SensorMetric(
      label: 'Soil Moisture',
      value: '68',
      unit: '%',
      icon: Icons.water_drop_outlined,
      color: AgriTheme.fieldGreen,
      points: [0.2, 0.28, 0.42, 0.38, 0.57, 0.54, 0.62],
      severityLabel: 'Normal',
      freshnessLabel: 'Demo data',
    ),
    SensorMetric(
      label: 'Water Level',
      value: '12',
      unit: 'cm',
      icon: Icons.water_outlined,
      color: AgriTheme.fieldGreen,
      points: [0.3, 0.3, 0.3, 0.5, 0.5, 0.7, 0.7],
      severityLabel: 'Normal',
      freshnessLabel: 'Demo data',
    ),
    SensorMetric(
      label: 'Temperature',
      value: '31',
      unit: 'C',
      icon: Icons.thermostat_outlined,
      color: AgriTheme.warning,
      points: [0.15, 0.24, 0.39, 0.45, 0.6, 0.56, 0.56],
      severityLabel: 'Warning',
      freshnessLabel: 'Demo data',
      isWarning: true,
    ),
    SensorMetric(
      label: 'Humidity',
      value: '74',
      unit: '%',
      icon: Icons.grain_outlined,
      color: AgriTheme.fieldGreen,
      points: [0.7, 0.58, 0.48, 0.4, 0.36, 0.34, 0.34],
      severityLabel: 'Normal',
      freshnessLabel: 'Demo data',
    ),
  ];

  static const alerts = [
    FieldAlert(
      title: 'High Temperature Alert',
      body: 'Temperature exceeded 30 C. Monitor water levels closely.',
      time: '10:30 AM',
      severity: AlertSeverity.attention,
    ),
    FieldAlert(
      title: 'Optimal Soil Moisture',
      body: 'Soil moisture is at ideal levels for the tillering stage.',
      time: '08:15 AM',
      severity: AlertSeverity.normal,
    ),
    FieldAlert(
      title: 'Low Water Level Warning',
      body: 'Water level dropped below 5cm in Sector B.',
      time: 'Yesterday',
      severity: AlertSeverity.warning,
    ),
  ];

  static const advice = [
    AdviceItem(
      title: 'Irrigation',
      body: 'Water levels are sufficient. No irrigation needed today.',
      icon: Icons.water,
      color: AgriTheme.muted,
    ),
    AdviceItem(
      title: 'Pest Risk',
      body: 'Weather conditions favor pests. Conduct visual inspection.',
      icon: Icons.bug_report_outlined,
      color: AgriTheme.warning,
      hasWarningDot: true,
    ),
    AdviceItem(
      title: 'Fertilizer',
      body: 'Next topdressing scheduled in 4 days.',
      icon: Icons.eco_outlined,
      color: AgriTheme.muted,
    ),
  ];

  static const readings = [
    HistoryReading(
      date: 'May 21, 2026',
      time: '8:30 AM',
      status: AlertSeverity.critical,
      values: {'Soil': '35%', 'Water': '2cm', 'Temp': '36C', 'Humid': '42%'},
    ),
    HistoryReading(
      date: 'May 21, 2026',
      time: '6:00 AM',
      status: AlertSeverity.warning,
      values: {'Soil': '44%', 'Water': '5cm', 'Temp': '33C', 'Humid': '55%'},
    ),
  ];
}

class AgriShell extends StatefulWidget {
  const AgriShell({
    required this.deviceConnectionRepository,
    required this.liveTelemetryRepository,
    required this.alertRepository,
    this.initialTab = AppTab.home,
    this.fieldId,
    super.key,
  });

  final DeviceConnectionRepository deviceConnectionRepository;
  final LiveTelemetryRepository liveTelemetryRepository;
  final AlertRepository alertRepository;
  final AppTab initialTab;
  final String? fieldId;

  @override
  State<AgriShell> createState() => _AgriShellState();
}

class _AgriShellState extends State<AgriShell> {
  late AppTab _tab = widget.initialTab;
  late DashboardCubit _dashboardCubit = DashboardCubit(
    liveTelemetryRepository: widget.liveTelemetryRepository,
  );
  late AlertGenerator _alertGenerator = AlertGenerator(
    alertRepository: widget.alertRepository,
    classifier: const FieldStatusClassifier(),
    cooldownPeriod: const Duration(hours: 1),
  );
  int _watchSequence = 0;

  @override
  void initState() {
    super.initState();
    _watchSavedDevice();
  }

  Future<void> _watchSavedDevice() async {
    final currentSequence = ++_watchSequence;
    DeviceConnection? connection;
    try {
      connection = await widget.deviceConnectionRepository
          .readSavedConnection()
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Ignore
    }
    if (!mounted || currentSequence != _watchSequence) return;
    if (connection == null) {
      return;
    }
    _dashboardCubit.watchDevice(connection.deviceCode);
    await _alertGenerator.startListening(
      connection,
      widget.liveTelemetryRepository,
    );
  }

  @override
  void didUpdateWidget(covariant AgriShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != _tab) {
      _tab = widget.initialTab;
    }
    if (oldWidget.liveTelemetryRepository != widget.liveTelemetryRepository) {
      final oldDeviceCode = _dashboardCubit.state.deviceCode;
      _dashboardCubit.close();
      if (oldDeviceCode != null) _alertGenerator.stopListening(oldDeviceCode);
      _dashboardCubit = DashboardCubit(
        liveTelemetryRepository: widget.liveTelemetryRepository,
      );
      _watchSavedDevice();
    }
    if (oldWidget.alertRepository != widget.alertRepository) {
      _alertGenerator.dispose();
      _alertGenerator = AlertGenerator(
        alertRepository: widget.alertRepository,
        classifier: const FieldStatusClassifier(),
        cooldownPeriod: const Duration(hours: 1),
      );
      _watchSavedDevice();
    }
    if (oldWidget.deviceConnectionRepository !=
        widget.deviceConnectionRepository) {
      _watchSavedDevice();
    }
  }

  void _setTab(AppTab tab) {
    setState(() => _tab = tab);
  }

  void _selectTab(AppTab tab) {
    _setTab(tab);

    switch (tab) {
      case AppTab.home:
        context.go('/field');
        return;
      case AppTab.alerts:
        context.go('/field?tab=alerts');
        return;
      case AppTab.advice:
        context.go('/field?tab=advice');
        return;
      case AppTab.history:
        context.go('/field?tab=history');
        return;
      case AppTab.settings:
        context.go('/settings');
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _dashboardCubit,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(
                index: _tab.index,
                children: [
                  HomeScreen(
                    onOpenAlerts: () => _selectTab(AppTab.alerts),
                    onOpenAdvice: () => _selectTab(AppTab.advice),
                  ),
                  alerts_ui.AlertsScreenWrapper(
                    alertRepository: widget.alertRepository,
                  ),
                  const AdviceScreen(),
                  const HistoryScreen(),
                  SettingsScreen(
                    deviceConnectionRepository:
                        widget.deviceConnectionRepository,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FloatingTabBar(currentTab: _tab, onChanged: _selectTab),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dashboardCubit.close();
    _alertGenerator.dispose();
    super.dispose();
  }
}

class PageFrame extends StatelessWidget {
  const PageFrame({
    required this.children,
    this.title,
    this.subtitle,
    this.paddingTop = 26,
    super.key,
  });

  final List<Widget> children;
  final String? title;
  final String? subtitle;
  final double paddingTop;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, paddingTop, 20, 112),
        children: [
          if (title != null) ...[
            Text(title!, style: Theme.of(context).textTheme.headlineLarge),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: Theme.of(context).textTheme.bodyLarge),
            ],
            const SizedBox(height: 22),
          ],
          ...children,
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.onOpenAlerts,
    required this.onOpenAdvice,
    super.key,
  });

  final VoidCallback onOpenAlerts;
  final VoidCallback onOpenAdvice;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final freshnessLabel = freshnessLabelForState(state);
        final metrics = sensorMetricsForState(state, freshnessLabel);

        void forceRefresh() {
          final deviceCode = context.read<DashboardCubit>().state.deviceCode;
          if (deviceCode != null) {
            context.read<DashboardCubit>().watchDevice(deviceCode);
          }
        }

        return PageFrame(
          paddingTop: 12,
          children: [
            GreetingHeader(trustState: state.trustState),
            const SizedBox(height: 18),
            FieldHeroCard(trustState: state.trustState),
            const SizedBox(height: 18),
            FieldStatusCard(
              state: state,
              onPrimaryAction: () {
                if (state.trustState == TrustState.warning ||
                    state.trustState == TrustState.critical) {
                  final alertId =
                      state.classification?.leadingCondition.sensorKey ??
                      'latest';
                  context.go('/field/alerts/$alertId');
                  return;
                }
                forceRefresh();
              },
            ),
            const SizedBox(height: 18),
            SensorDetailsHeader(freshnessLabel: freshnessLabel),
            const SizedBox(height: 10),
            MetricGrid(metrics: metrics),
            const SizedBox(height: 18),
            AdvicePreviewCard(onOpenAdvice: onOpenAdvice),
          ],
        );
      },
    );
  }
}

class AlertDetailPlaceholderScreen extends StatelessWidget {
  const AlertDetailPlaceholderScreen({required this.alertId, super.key});

  final String alertId;

  @override
  Widget build(BuildContext context) {
    final title = alertId == 'latest'
        ? 'Alert Detail'
        : 'Alert Detail: ${_sensorLabelForKey(alertId)}';

    return PageFrame(
      title: title,
      subtitle: 'Review the field condition before taking action',
      children: [
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alert detail is being prepared',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Use the Alerts tab for the current list while the full detail view is built.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/field?tab=alerts'),
                child: const Text('Back to alerts'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _sensorLabelForKey(String key) {
  return switch (key) {
    'soilMoisture' => 'Soil Moisture',
    'waterLevel' => 'Water Level',
    'temperature' => 'Temperature',
    'humidity' => 'Humidity',
    _ => key,
  };
}

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({required this.trustState, super.key});

  final TrustState trustState;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const FarmerAvatar(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning, Juan',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'Sitio Maligaya Rice Farm',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        TrustPill(state: trustState),
      ],
    );
  }
}

class FarmerAvatar extends StatelessWidget {
  const FarmerAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: softShadow(),
        gradient: const LinearGradient(
          colors: [Color(0xFF2E6F3E), Color(0xFFE1A46D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.person, color: Colors.white),
    );
  }
}

class TrustPill extends StatelessWidget {
  const TrustPill({required this.state, super.key});

  final TrustState state;

  @override
  Widget build(BuildContext context) {
    final info = trustInfo(state);
    return Semantics(
      label: info.semanticLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: info.background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(info.icon, color: info.color, size: 15),
            const SizedBox(width: 5),
            Text(
              info.shortLabel,
              style: TextStyle(
                color: info.color,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FieldHeroCard extends StatelessWidget {
  const FieldHeroCard({required this.trustState, super.key});

  final TrustState trustState;

  @override
  Widget build(BuildContext context) {
    final overlayText = switch (trustState) {
      TrustState.noData => 'WAITING FOR DATA',
      TrustState.offline => 'DEVICE OFFLINE',
      TrustState.stale => 'LAST KNOWN VIEW',
      TrustState.demo => 'DEMO VIEW',
      TrustState.error => 'CHECK DEVICE',
      _ => 'LIVE VIEW',
    };

    return Container(
      height: 126,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: softShadow(),
        gradient: const LinearGradient(
          colors: [Color(0xFF77B255), Color(0xFF1D6D38)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: FieldPatternPainter())),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.42),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  overlayText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tillering Stage',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FrostedPill(
              label: '2.5 Hectares',
              foreground: Colors.white,
              background: Colors.white.withValues(alpha: 0.22),
            ),
          ),
        ],
      ),
    );
  }
}

class FieldStatusCard extends StatelessWidget {
  const FieldStatusCard({
    required this.state,
    required this.onPrimaryAction,
    super.key,
  });

  final DashboardState state;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final info = fieldStatusInfo(state);
    final nextCheck = nextCheckLabelForState(state);
    final actionLabel = switch (state.trustState) {
      TrustState.critical => 'Check alert',
      TrustState.warning => 'Check alert',
      TrustState.noData => 'Refresh',
      TrustState.offline || TrustState.stale => 'Retry sync',
      TrustState.error => 'Retry sync',
      _ => 'Refresh',
    };

    return SoftCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Field Status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  info.recommendation,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                TrustStatusChip(state: state.trustState),
                if (info.limitation != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    info.limitation!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: info.color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Next check: $nextCheck',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AgriTheme.muted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onPrimaryAction,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    backgroundColor: info.color,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(actionLabel),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          HealthScoreRing(state: state),
        ],
      ),
    );
  }
}

class HealthScoreRing extends StatelessWidget {
  const HealthScoreRing({required this.state, super.key});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final info = fieldStatusInfo(state);
    final score = info.score;
    final label = score == null ? 'Cannot verify' : '$score';

    return Semantics(
      label: score == null
          ? 'Field health cannot be verified. ${info.recommendation}'
          : 'Field health score $score. ${info.semanticLabel}.',
      child: SizedBox(
        width: 98,
        height: 98,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(98, 98),
              painter: RingPainter(
                progress: score == null ? 0.0 : score / 100,
                color: info.color,
                muted: info.background,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: score == null ? 13 : 28,
                    height: 1,
                    color: AgriTheme.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (score != null)
                  const Text(
                    'HEALTH',
                    style: TextStyle(
                      color: AgriTheme.muted,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FieldStatusInfo {
  const FieldStatusInfo({
    required this.recommendation,
    required this.semanticLabel,
    required this.color,
    required this.background,
    this.score,
    this.limitation,
  });

  final String recommendation;
  final String semanticLabel;
  final Color color;
  final Color background;
  final int? score;
  final String? limitation;
}

FieldStatusInfo fieldStatusInfo(DashboardState state) {
  final tokens = AgriFieldTokens.light;

  return switch (state.trustState) {
    TrustState.loading => FieldStatusInfo(
      recommendation: state.message ?? 'Checking for the latest field reading.',
      semanticLabel: 'Syncing field data',
      color: AgriTheme.muted,
      background: const Color(0xFFEDEFF2),
      limitation: 'No recent reading',
    ),
    TrustState.noData => FieldStatusInfo(
      recommendation: state.message ?? 'Waiting for the first field reading.',
      semanticLabel: 'No readings yet',
      color: AgriTheme.muted,
      background: const Color(0xFFEDEFF2),
      limitation: 'No recent reading',
    ),
    TrustState.offline => FieldStatusInfo(
      recommendation:
          state.message ?? 'Latest field readings are unavailable right now.',
      semanticLabel: 'Device offline',
      color: tokens.stateDisabled,
      background: const Color(0xFFEDEFF2),
      limitation: 'No recent reading',
    ),
    TrustState.stale => FieldStatusInfo(
      recommendation:
          state.lastKnownClassification?.recommendation.message ??
          state.message ??
          'The latest reading is stale.',
      semanticLabel: 'Data may be outdated',
      color: tokens.confidenceStale,
      background: AgriTheme.softAmber,
      limitation: 'Data may be outdated',
    ),
    TrustState.error => FieldStatusInfo(
      recommendation:
          state.message ?? 'The latest reading could not be verified.',
      semanticLabel: 'Reading error',
      color: AgriTheme.muted,
      background: const Color(0xFFEDEFF2),
      limitation: 'No recent reading',
    ),
    TrustState.demo => FieldStatusInfo(
      recommendation:
          state.recommendation?.message ?? 'Showing simulated readings.',
      semanticLabel: 'Demo readings are active',
      color: tokens.statusOkay,
      background: AgriTheme.softGreen,
      score: _scoreForStatus(state.fieldStatus ?? FieldStatus.normal),
    ),
    TrustState.healthy || TrustState.warning || TrustState.critical =>
      state.fieldStatus == null
          ? FieldStatusInfo(
              recommendation:
                  state.message ??
                  'Latest field reading could not be classified.',
              semanticLabel: 'Field condition unknown',
              color: AgriTheme.muted,
              background: const Color(0xFFEDEFF2),
              limitation: 'Cannot verify status',
            )
          : FieldStatusInfo(
              recommendation:
                  state.recommendation?.message ??
                  state.message ??
                  'Latest field reading is available.',
              semanticLabel: _semanticLabelForStatus(state.fieldStatus!),
              color: _colorForFieldStatus(state.fieldStatus!),
              background: _backgroundForFieldStatus(state.fieldStatus!),
              score: _scoreForStatus(state.fieldStatus!),
            ),
  };
}

String nextCheckLabelForState(DashboardState state) {
  return switch (state.trustState) {
    TrustState.critical => 'now',
    TrustState.warning => 'today',
    TrustState.stale || TrustState.offline || TrustState.error => 'after sync',
    TrustState.loading => 'after sync',
    TrustState.noData => 'when data arrives',
    TrustState.demo => 'demo only',
    TrustState.healthy => 'within 24 hours',
  };
}

Color _colorForFieldStatus(FieldStatus status) {
  return switch (status) {
    FieldStatus.normal => AgriFieldTokens.light.statusOkay,
    FieldStatus.warning => AgriFieldTokens.light.statusNeedsAttention,
    FieldStatus.critical => AgriFieldTokens.light.statusCritical,
  };
}

Color _backgroundForFieldStatus(FieldStatus status) {
  return switch (status) {
    FieldStatus.normal => AgriTheme.softGreen,
    FieldStatus.warning => AgriTheme.softAmber,
    FieldStatus.critical => AgriTheme.softRed,
  };
}

int _scoreForStatus(FieldStatus status) {
  return switch (status) {
    FieldStatus.normal => 87,
    FieldStatus.warning => 64,
    FieldStatus.critical => 38,
  };
}

String _semanticLabelForStatus(FieldStatus status) {
  return switch (status) {
    FieldStatus.normal => 'Healthy field condition',
    FieldStatus.warning => 'Field condition needs attention',
    FieldStatus.critical => 'Critical field condition',
  };
}

String freshnessLabelForState(DashboardState state) {
  return switch (state.trustState) {
    TrustState.loading => 'Checking latest reading',
    TrustState.noData => 'No recent reading',
    TrustState.offline => 'Device offline',
    TrustState.error => 'No recent reading',
    TrustState.stale => 'Stale reading',
    TrustState.demo => 'Demo data',
    TrustState.healthy ||
    TrustState.warning ||
    TrustState.critical => _updatedAgoLabel(
      state.reading?.createdAt,
      state.updatedAt ?? DateTime.now(),
    ),
  };
}

String _updatedAgoLabel(DateTime? readingAt, DateTime now) {
  if (readingAt == null) return 'No recent reading';
  final age = now.difference(readingAt);
  if (age.inMinutes < 1) return 'Updated just now';
  if (age.inHours < 1) return 'Updated ${age.inMinutes} min ago';
  if (age.inDays < 1) return 'Updated ${age.inHours} hr ago';
  return 'Updated ${age.inDays} day${age.inDays == 1 ? '' : 's'} ago';
}

List<SensorMetric> sensorMetricsForState(
  DashboardState state,
  String freshnessLabel,
) {
  final reading = state.reading;
  final unavailable =
      reading == null ||
      switch (state.trustState) {
        TrustState.loading ||
        TrustState.noData ||
        TrustState.offline ||
        TrustState.error => true,
        TrustState.stale ||
        TrustState.demo ||
        TrustState.healthy ||
        TrustState.warning ||
        TrustState.critical => false,
      };

  SensorMetric metric({
    required String key,
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required List<double> points,
  }) {
    final status = state.classification?.conditionFor(key)?.status;
    final hasUnknownStatus = !unavailable && status == null;
    final isStale = state.trustState == TrustState.stale;
    final severityLabel = unavailable
        ? 'Unavailable'
        : isStale
        ? 'Stale'
        : hasUnknownStatus
        ? 'Unknown'
        : _severityLabelForStatus(status!);
    final color = unavailable || hasUnknownStatus
        ? AgriTheme.muted
        : isStale
        ? AgriFieldTokens.light.confidenceStale
        : _colorForFieldStatus(status!);

    return SensorMetric(
      label: label,
      value: unavailable ? '--' : value,
      unit: unavailable ? '' : unit,
      icon: icon,
      color: color,
      points: points,
      severityLabel: severityLabel,
      freshnessLabel: freshnessLabel,
      isWarning:
          !isStale &&
          (status == FieldStatus.warning || status == FieldStatus.critical),
      isUnavailable: unavailable || hasUnknownStatus,
    );
  }

  return [
    metric(
      key: 'soilMoisture',
      label: 'Soil Moisture',
      value: reading?.soilMoisture.toString() ?? '--',
      unit: '%',
      icon: Icons.water_drop_outlined,
      points: MockAgriData.metrics[0].points,
    ),
    metric(
      key: 'waterLevel',
      label: 'Water Level',
      value: reading?.waterLevel.toStringAsFixed(1) ?? '--',
      unit: 'cm',
      icon: Icons.water_outlined,
      points: MockAgriData.metrics[1].points,
    ),
    metric(
      key: 'temperature',
      label: 'Temperature',
      value: reading?.temperature.toStringAsFixed(1) ?? '--',
      unit: 'C',
      icon: Icons.thermostat_outlined,
      points: MockAgriData.metrics[2].points,
    ),
    metric(
      key: 'humidity',
      label: 'Humidity',
      value: reading?.humidity.toStringAsFixed(1) ?? '--',
      unit: '%',
      icon: Icons.grain_outlined,
      points: MockAgriData.metrics[3].points,
    ),
  ];
}

String _severityLabelForStatus(FieldStatus status) {
  return switch (status) {
    FieldStatus.normal => 'Normal',
    FieldStatus.warning => 'Warning',
    FieldStatus.critical => 'Critical',
  };
}

class MetricGrid extends StatelessWidget {
  const MetricGrid({required this.metrics, super.key});

  final List<SensorMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 340;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: twoColumns ? 2 : 1,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: twoColumns ? 1.08 : 2.3,
          ),
          itemBuilder: (context, index) =>
              SensorMetricCard(metric: metrics[index]),
        );
      },
    );
  }
}

class SensorDetailsHeader extends StatelessWidget {
  const SensorDetailsHeader({required this.freshnessLabel, super.key});

  final String freshnessLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Sensor Details',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ReadingFreshnessLabel(label: freshnessLabel),
      ],
    );
  }
}

class ReadingFreshnessLabel extends StatelessWidget {
  const ReadingFreshnessLabel({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Reading freshness: $label',
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AgriTheme.muted,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class SensorMetricCard extends StatelessWidget {
  const SensorMetricCard({required this.metric, super.key});

  final SensorMetric metric;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${metric.label}: ${metric.value}${metric.unit}. '
          '${metric.severityLabel}. ${metric.freshnessLabel}.',
      child: SoftCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MetricIcon(icon: metric.icon, color: metric.color),
                const Spacer(),
                SizedBox(
                  width: 64,
                  height: 32,
                  child: CustomPaint(
                    painter: SparklinePainter(
                      points: metric.points,
                      color: metric.color,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  metric.value,
                  style: TextStyle(
                    color: metric.isUnavailable
                        ? AgriTheme.muted
                        : AgriTheme.text,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    metric.unit,
                    style: const TextStyle(
                      color: AgriTheme.muted,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(metric.label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              metric.severityLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: metric.color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdvicePreviewCard extends StatelessWidget {
  const AdvicePreviewCard({required this.onOpenAdvice, super.key});

  final VoidCallback onOpenAdvice;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Row(
        children: [
          const MetricIcon(
            icon: Icons.eco_outlined,
            color: AgriTheme.fieldGreen,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Action for today',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  'Maintain current water levels and monitor temperature.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onOpenAdvice,
            tooltip: 'Open advice',
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class FilterPills extends StatefulWidget {
  const FilterPills({required this.labels, super.key});

  final List<String> labels;

  @override
  State<FilterPills> createState() => _FilterPillsState();
}

class _FilterPillsState extends State<FilterPills> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          for (var i = 0; i < widget.labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selected = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected == i ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: selected == i ? softShadow(alpha: 0.05) : null,
                  ),
                  child: Text(
                    widget.labels[i],
                    style: TextStyle(
                      color: selected == i ? AgriTheme.text : AgriTheme.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  const AlertCard({required this.alert, super.key});

  final FieldAlert alert;

  @override
  Widget build(BuildContext context) {
    final color = severityColor(alert.severity);
    return SoftCard(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SeverityChip(severity: alert.severity),
                        const Spacer(),
                        Text(
                          alert.time,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      alert.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      alert.body,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdviceScreen extends StatelessWidget {
  const AdviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageFrame(title: 'Advice', children: const [AdvicePanel()]);
  }
}

class AdvicePanel extends StatelessWidget {
  const AdvicePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AgriTheme.fieldGreen,
            borderRadius: BorderRadius.circular(22),
            boxShadow: softShadow(alpha: 0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco, color: Colors.white),
              ),
              const SizedBox(height: 26),
              const Text(
                'Normal Condition',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your field is currently in the Tillering Stage and conditions are optimal. Maintain current water levels.',
                style: TextStyle(
                  color: Colors.white,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Action Items', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),
        ...MockAgriData.advice.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: AdviceCard(item: item),
          ),
        ),
      ],
    );
  }
}

class AdviceCard extends StatelessWidget {
  const AdviceCard({required this.item, super.key});

  final AdviceItem item;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Row(
        children: [
          MetricIcon(icon: item.icon, color: item.color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (item.hasWarningDot)
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AgriTheme.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item.body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AgriTheme.muted),
        ],
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'History',
      subtitle: 'Past readings and alerts',
      children: [
        Container(
          height: 128,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF2F8740), Color(0xFF165C2D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: FieldGridPainter())),
              const Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LAST 7 DAYS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Mostly Stable',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: SoftCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: AgriTheme.muted,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Last 7 days',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            const CircleButton(icon: Icons.tune),
          ],
        ),
        const SizedBox(height: 22),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Trend',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Soil Moisture',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 116,
                child: CustomPaint(
                  painter: AreaChartPainter(
                    points: const [
                      0.42,
                      0.5,
                      0.64,
                      0.58,
                      0.75,
                      0.82,
                      0.68,
                      0.58,
                      0.48,
                      0.42,
                    ],
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Soil moisture is mostly stable with a small decline today.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Sensor Reading History',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 14),
        ...MockAgriData.readings.map(
          (reading) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: HistoryReadingCard(reading: reading),
          ),
        ),
      ],
    );
  }
}

class HistoryReadingCard extends StatelessWidget {
  const HistoryReadingCard({required this.reading, super.key});

  final HistoryReading reading;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reading.date,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      reading.time,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              SeverityChip(severity: reading.status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: reading.values.entries
                .map(
                  (entry) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 7),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AgriTheme.background,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          Text(
                            entry.key.toUpperCase(),
                            style: const TextStyle(
                              color: AgriTheme.muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            entry.value,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AgriTheme.text,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.deviceConnectionRepository, super.key});

  final DeviceConnectionRepository deviceConnectionRepository;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        void forceRefresh() {
          final deviceCode = state.deviceCode;
          if (deviceCode != null) {
            context.read<DashboardCubit>().watchDevice(deviceCode);
          }
        }

        return PageFrame(
          title: 'Settings',
          children: [
            const ProfileCard(),
            const SizedBox(height: 24),
            SectionLabel('Device Status'),
            const SizedBox(height: 10),
            DeviceRecoveryCard(
              trustState: state.trustState,
              onRefresh: forceRefresh,
              onEnableDemoMode: () {}, // No-op, live data only
              onReturnToLiveData: forceRefresh,
            ),
            const SizedBox(height: 12),
            LiveDeviceConnectionCard(
              deviceConnectionRepository: deviceConnectionRepository,
            ),
            const SizedBox(height: 24),
            SectionLabel('Field Advice'),
            const SizedBox(height: 10),
            const AdvicePanel(),
            const SizedBox(height: 24),
            SectionLabel('Language'),
            const SizedBox(height: 10),
            const LanguageSelector(),
            const SizedBox(height: 24),
            SectionLabel('Notifications'),
            const SizedBox(height: 10),
            const SettingsToggle(
              label: 'In-app alerts',
              icon: Icons.notifications_none,
            ),
            const SettingsToggle(
              label: 'Warning alerts',
              icon: Icons.circle,
              iconColor: AgriTheme.warning,
            ),
            const SettingsToggle(
              label: 'Critical alerts',
              icon: Icons.circle,
              iconColor: AgriTheme.critical,
            ),
            const SizedBox(height: 24),
            SectionLabel('Farm Information'),
            const SizedBox(height: 10),
            const FarmInfoCard(),
          ],
        );
      },
    );
  }
}

class LiveDeviceConnectionCard extends StatefulWidget {
  const LiveDeviceConnectionCard({
    required this.deviceConnectionRepository,
    super.key,
  });

  final DeviceConnectionRepository deviceConnectionRepository;

  @override
  State<LiveDeviceConnectionCard> createState() =>
      _LiveDeviceConnectionCardState();
}

class _LiveDeviceConnectionCardState extends State<LiveDeviceConnectionCard> {
  bool _isClearing = false;
  String? _clearError;
  late Future<DeviceConnection?> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.deviceConnectionRepository.readSavedConnection();
  }

  @override
  void didUpdateWidget(covariant LiveDeviceConnectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deviceConnectionRepository !=
        widget.deviceConnectionRepository) {
      _future = widget.deviceConnectionRepository.readSavedConnection();
    }
  }

  Future<void> _clearConnection() async {
    setState(() {
      _isClearing = true;
      _clearError = null;
    });
    try {
      await widget.deviceConnectionRepository.clearConnection();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isClearing = false;
        _clearError = 'Could not change device right now. Please try again.';
      });
      return;
    }
    if (!mounted) return;
    context.go('/pair');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final connection = snapshot.data;
        if (snapshot.hasError || connection == null) {
          return SoftCard(
            child: Row(
              children: [
                const MetricIcon(
                  icon: Icons.sensors_off_outlined,
                  color: AgriTheme.muted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No live device connected',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/pair'),
                  child: const Text('Connect Device'),
                ),
              ],
            ),
          );
        }

        return SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MetricIcon(
                    icon: Icons.sensors_rounded,
                    color: AgriTheme.fieldGreen,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Device Connected',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${connection.deviceCode} - ${connection.deviceId}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Farm ${connection.farmId}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _isClearing ? null : _clearConnection,
                icon: _isClearing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : const Icon(Icons.link_off_rounded),
                label: Text(_isClearing ? 'Clearing...' : 'Change device'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              if (_clearError != null) ...[
                const SizedBox(height: 10),
                Text(
                  _clearError!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AgriTheme.critical),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: AgriTheme.card,
        boxShadow: softShadow(),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Container(
            height: 88,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD8A15A), Color(0xFF266D37)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            left: 22,
            top: 48,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AgriTheme.deepGreen,
                border: Border.all(color: Colors.white, width: 4),
              ),
              alignment: Alignment.center,
              child: const Text(
                'MJ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          Positioned(
            left: 116,
            right: 18,
            bottom: 26,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Juan dela Cruz',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Farmer - Lupang Pula Field',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AgriTheme.muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Nueva Ecija, PH',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DeviceRecoveryCard extends StatelessWidget {
  const DeviceRecoveryCard({
    required this.trustState,
    required this.onRefresh,
    required this.onEnableDemoMode,
    required this.onReturnToLiveData,
    super.key,
  });

  final TrustState trustState;
  final VoidCallback onRefresh;
  final VoidCallback onEnableDemoMode;
  final VoidCallback onReturnToLiveData;

  @override
  Widget build(BuildContext context) {
    final info = trustInfo(trustState);
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MetricIcon(icon: info.icon, color: info.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.longLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      info.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRefresh,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(48, 48),
                  ),
                  child: const Text('Refresh'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: trustState == TrustState.demo
                      ? onReturnToLiveData
                      : onEnableDemoMode,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    backgroundColor: AgriTheme.deepGreen,
                  ),
                  child: Text(
                    trustState == TrustState.demo ? 'Live' : 'Demo Mode',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  bool english = true;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _LanguageButton(
              active: english,
              label: 'English',
              onTap: () => setState(() => english = true),
            ),
          ),
          Expanded(
            child: _LanguageButton(
              active: !english,
              label: 'Filipino',
              onTap: () => setState(() => english = false),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.active,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: active ? softShadow(alpha: 0.05) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.language,
              color: active ? AgriTheme.deepGreen : AgriTheme.muted,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: active ? AgriTheme.deepGreen : AgriTheme.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsToggle extends StatefulWidget {
  const SettingsToggle({
    required this.label,
    required this.icon,
    this.iconColor = AgriTheme.muted,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color iconColor;

  @override
  State<SettingsToggle> createState() => _SettingsToggleState();
}

class _SettingsToggleState extends State<SettingsToggle> {
  bool enabled = true;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      margin: const EdgeInsets.only(bottom: 1),
      borderRadius: BorderRadius.zero,
      boxShadow: const [],
      child: Row(
        children: [
          MetricIcon(icon: widget.icon, color: widget.iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Switch(
            value: enabled,
            activeThumbColor: Colors.white,
            activeTrackColor: AgriTheme.deepGreen,
            onChanged: (value) => setState(() => enabled = value),
          ),
        ],
      ),
    );
  }
}

class FarmInfoCard extends StatelessWidget {
  const FarmInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        children: const [
          InfoRow(label: 'Farm name', value: 'Lupang Pula Field'),
          Divider(height: 28),
          InfoRow(label: 'Field location', value: 'Nueva Ecija'),
          Divider(height: 28),
          InfoRow(label: 'Device ID', value: 'ESP32-RICE-01'),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const MetricIcon(
          icon: Icons.location_on_outlined,
          color: AgriTheme.muted,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AgriTheme.muted),
          ),
        ),
      ],
    );
  }
}

class FloatingTabBar extends StatelessWidget {
  const FloatingTabBar({
    required this.currentTab,
    required this.onChanged,
    super.key,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AgriTheme.line),
          boxShadow: softShadow(alpha: 0.13),
        ),
        child: Row(
          children: [
            NavItem(
              tab: AppTab.home,
              currentTab: currentTab,
              label: 'Home',
              icon: Icons.home_rounded,
              onChanged: onChanged,
            ),
            NavItem(
              tab: AppTab.alerts,
              currentTab: currentTab,
              label: 'Alerts',
              icon: Icons.notifications_none_rounded,
              onChanged: onChanged,
            ),
            NavItem(
              tab: AppTab.advice,
              currentTab: currentTab,
              label: 'Advice',
              icon: Icons.eco_outlined,
              onChanged: onChanged,
            ),
            NavItem(
              tab: AppTab.history,
              currentTab: currentTab,
              label: 'History',
              icon: Icons.history_rounded,
              onChanged: onChanged,
            ),
            NavItem(
              tab: AppTab.settings,
              currentTab: currentTab,
              label: 'Settings',
              icon: Icons.settings_outlined,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  const NavItem({
    required this.tab,
    required this.currentTab,
    required this.label,
    required this.icon,
    required this.onChanged,
    super.key,
  });

  final AppTab tab;
  final AppTab currentTab;
  final String label;
  final IconData icon;
  final ValueChanged<AppTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final active = tab == currentTab;
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onChanged(tab),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AgriTheme.softGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: active ? AgriTheme.fieldGreen : AgriTheme.muted,
                  size: 22,
                ),
                const SizedBox(height: 3),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: TextStyle(
                        color: active ? AgriTheme.deepGreen : AgriTheme.muted,
                        fontSize: 10,
                        fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius,
    this.boxShadow,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AgriTheme.card,
        borderRadius: borderRadius ?? BorderRadius.circular(22),
        boxShadow: boxShadow ?? softShadow(),
      ),
      child: child,
    );
  }
}

class MetricIcon extends StatelessWidget {
  const MetricIcon({required this.icon, required this.color, super.key});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        color: AgriTheme.background,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class SeverityChip extends StatelessWidget {
  const SeverityChip({required this.severity, super.key});

  final AlertSeverity severity;

  @override
  Widget build(BuildContext context) {
    final label = severityLabel(severity);
    final color = severityColor(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(severityIcon(severity), size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class TrustStatusChip extends StatelessWidget {
  const TrustStatusChip({required this.state, super.key});

  final TrustState state;

  @override
  Widget build(BuildContext context) {
    final info = trustInfo(state);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: info.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, color: info.color, size: 15),
          const SizedBox(width: 6),
          Text(
            info.longLabel,
            style: TextStyle(
              color: info.color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class FrostedPill extends StatelessWidget {
  const FrostedPill({
    required this.label,
    required this.foreground,
    required this.background,
    super.key,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class CircleButton extends StatelessWidget {
  const CircleButton({required this.icon, super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: 54,
        height: 54,
        child: Icon(icon, color: AgriTheme.muted),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: AgriTheme.muted,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
      ),
    );
  }
}

class TrustInfo {
  const TrustInfo({
    required this.shortLabel,
    required this.longLabel,
    required this.description,
    required this.semanticLabel,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String shortLabel;
  final String longLabel;
  final String description;
  final String semanticLabel;
  final IconData icon;
  final Color color;
  final Color background;
}

TrustInfo trustInfo(TrustState state) {
  return switch (state) {
    TrustState.loading => const TrustInfo(
      shortLabel: 'Syncing',
      longLabel: 'Syncing field data',
      description: 'Checking for the latest reading.',
      semanticLabel: 'Syncing field data',
      icon: Icons.sync,
      color: AgriTheme.muted,
      background: Color(0xFFEDEFF2),
    ),
    TrustState.noData => const TrustInfo(
      shortLabel: 'No Data',
      longLabel: 'No readings yet',
      description: 'Field readings have not arrived yet.',
      semanticLabel: 'No readings yet',
      icon: Icons.info_outline,
      color: AgriTheme.muted,
      background: Color(0xFFEDEFF2),
    ),
    TrustState.offline => TrustInfo(
      shortLabel: 'Offline',
      longLabel: 'Device offline',
      description: 'Cannot receive new field data right now.',
      semanticLabel: 'Device offline',
      icon: Icons.wifi_off_rounded,
      color: AgriFieldTokens.light.confidenceNoConnection,
      background: AgriTheme.softRed,
    ),
    TrustState.stale => TrustInfo(
      shortLabel: 'Stale',
      longLabel: 'Stale reading',
      description:
          'Last known status: Needs attention. Retry sync before relying on this reading.',
      semanticLabel: 'Stale reading. Last known status needs attention.',
      icon: Icons.schedule_rounded,
      color: AgriFieldTokens.light.confidenceStale,
      background: AgriTheme.softAmber,
    ),
    TrustState.critical => TrustInfo(
      shortLabel: 'Critical',
      longLabel: 'Critical field condition',
      description: 'Water level is very low. Check the field now.',
      semanticLabel: 'Critical field condition',
      icon: Icons.error_outline,
      color: AgriFieldTokens.light.statusCritical,
      background: AgriTheme.softRed,
    ),
    TrustState.warning => TrustInfo(
      shortLabel: 'Watch',
      longLabel: 'Needs attention',
      description: 'Temperature is high. Monitor water level today.',
      semanticLabel: 'Field condition needs attention',
      icon: Icons.warning_amber_rounded,
      color: AgriFieldTokens.light.statusNeedsAttention,
      background: AgriTheme.softAmber,
    ),
    TrustState.healthy => TrustInfo(
      shortLabel: '28 C',
      longLabel: 'Healthy',
      description:
          'Updated 2 min ago. Fresh readings show no immediate concern.',
      semanticLabel: 'Healthy field condition',
      icon: Icons.cloud_outlined,
      color: AgriFieldTokens.light.confidenceRecent,
      background: AgriTheme.softGreen,
    ),
    TrustState.demo => TrustInfo(
      shortLabel: 'Demo',
      longLabel: 'Demo readings',
      description: 'Showing simulated readings for demonstration.',
      semanticLabel: 'Demo readings are active',
      icon: Icons.science_outlined,
      color: AgriFieldTokens.light.statusOkay,
      background: AgriTheme.softGreen,
    ),
    TrustState.error => TrustInfo(
      shortLabel: 'Error',
      longLabel: 'Reading error',
      description: 'The latest reading could not be verified.',
      semanticLabel: 'Reading error',
      icon: Icons.error_outline,
      color: AgriTheme.muted,
      background: const Color(0xFFEDEFF2),
    ),
  };
}

String severityLabel(AlertSeverity severity) {
  return switch (severity) {
    AlertSeverity.critical => 'CRITICAL',
    AlertSeverity.warning => 'WARNING',
    AlertSeverity.attention => 'ATTENTION',
    AlertSeverity.normal => 'NORMAL',
  };
}

Color severityColor(AlertSeverity severity) {
  return switch (severity) {
    AlertSeverity.critical => AgriFieldTokens.light.statusCritical,
    AlertSeverity.warning => AgriFieldTokens.light.statusNeedsAttention,
    AlertSeverity.attention => AgriFieldTokens.light.confidenceDelayed,
    AlertSeverity.normal => AgriFieldTokens.light.statusOkay,
  };
}

IconData severityIcon(AlertSeverity severity) {
  return switch (severity) {
    AlertSeverity.critical => Icons.error_outline,
    AlertSeverity.warning => Icons.warning_amber_rounded,
    AlertSeverity.attention => Icons.info_outline,
    AlertSeverity.normal => Icons.check_circle_outline,
  };
}

List<BoxShadow> softShadow({double alpha = 0.08}) {
  return [
    BoxShadow(
      color: Colors.black.withValues(alpha: alpha),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}

class RingPainter extends CustomPainter {
  RingPainter({
    required this.progress,
    required this.color,
    required this.muted,
  });

  final double progress;
  final Color color;
  final Color muted;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2 - 8;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8
      ..color = muted;
    final active = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8
      ..color = color;

    canvas.drawCircle(center, radius, base);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress * math.pi * 2,
      false,
      active,
    );
  }

  @override
  bool shouldRepaint(covariant RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class SparklinePainter extends CustomPainter {
  SparklinePainter({required this.points, required this.color});

  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = i / (points.length - 1) * size.width;
      final y = size.height - (points[i].clamp(0.0, 1.0) * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}

class AreaChartPainter extends CustomPainter {
  AreaChartPainter({required this.points});

  final List<double> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final line = Path();
    final fill = Path();
    if (points.length == 1) {
      final y =
          size.height - (points.first.clamp(0.0, 1.0) * size.height * 0.86) - 8;
      line.moveTo(0, y);
      line.lineTo(size.width, y);
      fill
        ..moveTo(0, size.height)
        ..lineTo(0, y)
        ..lineTo(size.width, y);
    } else {
      for (var i = 0; i < points.length; i++) {
        final x = i / (points.length - 1) * size.width;
        final y =
            size.height - (points[i].clamp(0.0, 1.0) * size.height * 0.86) - 8;
        if (i == 0) {
          line.moveTo(x, y);
          fill.moveTo(x, size.height);
          fill.lineTo(x, y);
        } else {
          line.lineTo(x, y);
          fill.lineTo(x, y);
        }
      }
    }
    fill.lineTo(size.width, size.height);
    fill.close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x6634C759), Color(0x0034C759)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);
    final linePaint = Paint()
      ..color = AgriTheme.deepGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(fill, fillPaint);
    canvas.drawPath(line, linePaint);
    canvas.drawCircle(
      Offset(size.width, line.getBounds().bottom),
      4,
      Paint()..color = AgriTheme.deepGreen,
    );
  }

  @override
  bool shouldRepaint(covariant AreaChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

class FieldPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = -1; i < 8; i++) {
      final path = Path()
        ..moveTo(i * 52.0, size.height)
        ..quadraticBezierTo(
          i * 50.0 + 28,
          size.height * 0.45,
          i * 55.0 + 18,
          0,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FieldGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var i = 0; i < 5; i++) {
      final y = size.height * (i + 1) / 6;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + (i.isEven ? 12 : -8)),
        paint,
      );
    }
    for (var i = 0; i < 6; i++) {
      final x = size.width * (i + 1) / 7;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + (i.isEven ? 14 : -10), size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

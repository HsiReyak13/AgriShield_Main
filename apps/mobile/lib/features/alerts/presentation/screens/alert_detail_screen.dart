import 'package:agrishield/app/theme/agri_theme.dart';
import 'package:agrishield/app/theme/agri_tokens.dart';
import 'package:agrishield/core/models/alert.dart';
import 'package:agrishield/core/models/data_source.dart';
import 'package:agrishield/core/models/device_connection.dart';
import 'package:agrishield/core/models/field_status.dart';
import 'package:agrishield/core/repositories/alert_repository.dart';
import 'package:agrishield/core/repositories/device_connection_repository.dart';
import 'package:agrishield/features/alerts/application/alert_detail_cubit.dart';
import 'package:agrishield/features/alerts/application/alert_detail_state.dart';
import 'package:agrishield/features/dashboard/view/prototype_screens.dart'
    as prototype;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AlertDetailScreen extends StatefulWidget {
  const AlertDetailScreen({
    required this.alertId,
    required this.alertRepository,
    required this.deviceConnectionRepository,
    super.key,
  });

  final String alertId;
  final AlertRepository alertRepository;
  final DeviceConnectionRepository deviceConnectionRepository;

  @override
  State<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends State<AlertDetailScreen> {
  late Future<DeviceConnection?> _connectionFuture;

  @override
  void initState() {
    super.initState();
    _connectionFuture = widget.deviceConnectionRepository.readSavedConnection();
  }

  @override
  void didUpdateWidget(covariant AlertDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deviceConnectionRepository !=
        widget.deviceConnectionRepository) {
      _connectionFuture = widget.deviceConnectionRepository
          .readSavedConnection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DeviceConnection?>(
      future: _connectionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AlertDetailView(stateOverride: AlertDetailLoading());
        }

        final connection = snapshot.data;
        if (snapshot.hasError) {
          return const AlertDetailView(
            stateOverride: AlertDetailError(
              message: 'Device connection could not be loaded right now.',
            ),
          );
        }

        if (connection == null) {
          return AlertDetailView(
            stateOverride: AlertDetailNotFound(alertId: widget.alertId),
          );
        }

        return BlocProvider(
          create: (_) => AlertDetailCubit(
            alertRepository: widget.alertRepository,
            deviceCode: connection.deviceCode,
            alertId: widget.alertId,
          )..startListening(),
          child: const AlertDetailView(),
        );
      },
    );
  }
}

class AlertDetailView extends StatelessWidget {
  const AlertDetailView({this.stateOverride, super.key});

  final AlertDetailState? stateOverride;

  @override
  Widget build(BuildContext context) {
    final state = stateOverride;
    if (state != null) {
      return _AlertDetailContent(state: state);
    }

    return BlocBuilder<AlertDetailCubit, AlertDetailState>(
      builder: (context, state) => _AlertDetailContent(state: state),
    );
  }
}

class _AlertDetailContent extends StatelessWidget {
  const _AlertDetailContent({required this.state});

  final AlertDetailState state;

  @override
  Widget build(BuildContext context) {
    return prototype.PageFrame(
      title: 'Alert Detail',
      subtitle: 'Review the field condition before taking action',
      children: [
        switch (state) {
          AlertDetailLoading() => const _LoadingCard(),
          AlertDetailLoaded(alert: final alert) => _LoadedAlertDetail(
            alert: alert,
          ),
          AlertDetailNotFound(alertId: final alertId) => _FallbackCard(
            title: 'Alert not found',
            body:
                'We could not find alert "$alertId". It may have been cleared, or this dashboard entry may refer to a sensor instead of a saved alert.',
          ),
          AlertDetailError(message: final message) => _FallbackCard(
            title: 'Alert details unavailable',
            body:
                '$message Check the Alerts tab again before relying on this field reading.',
          ),
        },
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const prototype.SoftCard(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _LoadedAlertDetail extends StatelessWidget {
  const _LoadedAlertDetail({required this.alert});

  final Alert alert;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AgriFieldTokens>() ?? AgriFieldTokens.light;
    final severity = _severityInfo(alert.severity, tokens);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        prototype.SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                container: true,
                label: severity.semanticLabel,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: severity.background,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(severity.icon, color: severity.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            severity.label,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: severity.color),
                          ),
                          Text(
                            alert.sensor,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                alert.recommendation,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Use this as field-check guidance. Confirm the condition in the field before changing irrigation or making crop decisions.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        prototype.SoftCard(
          child: Column(
            children: [
              _DetailRow(label: 'Affected sensor', value: alert.sensor),
              const Divider(height: 24),
              _DetailRow(
                label: 'Timestamp',
                value: _formatTimestamp(alert.createdAt),
              ),
              const Divider(height: 24),
              _DetailRow(
                label: 'Reading value',
                value: _formatReadingValue(alert.readingValue),
              ),
              const Divider(height: 24),
              _DetailRow(
                label: 'Threshold context',
                value: alert.thresholdMessage,
              ),
              const Divider(height: 24),
              _DetailRow(label: 'Source', value: _sourceLabel(alert.source)),
              const Divider(height: 24),
              _DetailRow(
                label: 'Read state',
                value: alert.isRead ? 'Read' : 'Active unread alert',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () => context.go('/field?tab=alerts'),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Back to alerts'),
        ),
      ],
    );
  }
}

class _FallbackCard extends StatelessWidget {
  const _FallbackCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return prototype.SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AgriTheme.muted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.go('/field?tab=alerts'),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back to alerts'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final displayValue = value.isEmpty ? '--' : value;
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldStack = constraints.maxWidth < 360 || textScale > 1.25;
        if (shouldStack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              SelectableText(
                displayValue,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SelectableText(
                displayValue,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SeverityInfo {
  const _SeverityInfo({
    required this.label,
    required this.semanticLabel,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String label;
  final String semanticLabel;
  final IconData icon;
  final Color color;
  final Color background;
}

_SeverityInfo _severityInfo(FieldStatus status, AgriFieldTokens tokens) {
  return switch (status) {
    FieldStatus.critical => _SeverityInfo(
      label: 'Critical',
      semanticLabel: 'Critical alert',
      icon: Icons.error_outline,
      color: tokens.statusCritical,
      background: AgriTheme.softRed,
    ),
    FieldStatus.warning => _SeverityInfo(
      label: 'Warning',
      semanticLabel: 'Warning alert',
      icon: Icons.warning_amber_rounded,
      color: tokens.statusNeedsAttention,
      background: AgriTheme.softAmber,
    ),
    FieldStatus.normal => _SeverityInfo(
      label: 'Normal',
      semanticLabel: 'Normal alert',
      icon: Icons.check_circle_outline,
      color: tokens.statusOkay,
      background: AgriTheme.softGreen,
    ),
  };
}

String _sourceLabel(DataSource source) {
  return switch (source) {
    DataSource.live => 'Live device',
    DataSource.demo => 'Demo data',
    DataSource.unknown => 'Unknown source',
  };
}

String _formatReadingValue(double value) {
  final rounded = value.roundToDouble();
  if (value == rounded) return rounded.toInt().toString();
  return value.toStringAsFixed(1);
}

String _formatTimestamp(DateTime timestamp) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = months[timestamp.month - 1];
  final hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
  final minute = timestamp.minute.toString().padLeft(2, '0');
  final period = timestamp.hour >= 12 ? 'PM' : 'AM';
  return '$month ${timestamp.day}, ${timestamp.year}, $hour:$minute $period';
}

import 'dart:async';
import 'dart:developer' as developer;

import 'package:agrishield/core/logic/field_status_classifier.dart';
import 'package:agrishield/core/models/alert.dart';
import 'package:agrishield/core/models/device_connection.dart';
import 'package:agrishield/core/models/field_status.dart';
import 'package:agrishield/core/models/sensor_reading.dart';
import 'package:agrishield/core/repositories/alert_repository.dart';
import 'package:agrishield/core/repositories/live_telemetry_repository.dart';

class AlertGenerator {
  AlertGenerator({
    required AlertRepository alertRepository,
    required FieldStatusClassifier classifier,
    required Duration cooldownPeriod,
    DateTime Function()? now,
  }) : _alertRepository = alertRepository,
       _classifier = classifier,
       _cooldownPeriod = cooldownPeriod,
       _now = now ?? DateTime.now;

  final AlertRepository _alertRepository;
  final FieldStatusClassifier _classifier;
  final Duration _cooldownPeriod;
  final DateTime Function() _now;

  final Map<String, Alert> _lastAlerts = {};
  final Map<String, FieldStatus> _lastStatuses = {};
  final Map<String, StreamSubscription> _subscriptions = {};
  int _alertSequence = 0;

  Future<void> startListening(
    DeviceConnection connection,
    LiveTelemetryRepository telemetryRepository,
  ) async {
    if (_subscriptions.containsKey(connection.deviceCode)) return;

    await _seedLastAlerts(connection.deviceCode);

    _subscriptions[connection.deviceCode] = telemetryRepository
        .watchLatest(connection.deviceCode)
        .listen((result) {
          if (result.isSuccess && result.reading != null) {
            unawaited(
              processReading(result.reading!, connection).catchError((
                Object error,
                StackTrace stackTrace,
              ) {
                developer.log(
                  'Failed to process alert reading',
                  error: error,
                  stackTrace: stackTrace,
                );
              }),
            );
          }
        });
  }

  void stopListening(String deviceCode) {
    _subscriptions[deviceCode]?.cancel();
    _subscriptions.remove(deviceCode);
  }

  void dispose() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  Future<void> _seedLastAlerts(String deviceCode) async {
    try {
      final alerts = await _alertRepository.watchAlerts(deviceCode).first;
      for (final alert in alerts) {
        final cacheKey = _cacheKey(alert.deviceCode, alert.sensor);
        final lastAlert = _lastAlerts[cacheKey];
        if (lastAlert == null || alert.createdAt.isAfter(lastAlert.createdAt)) {
          _lastAlerts[cacheKey] = alert;
          _lastStatuses[cacheKey] = alert.severity;
        }
      }
    } catch (e, st) {
      developer.log(
        'Failed to seed alert cooldown state',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> processReading(
    SensorReading reading,
    DeviceConnection connection,
  ) async {
    final classification = _classifier.classify(reading);

    for (final condition in classification.conditions) {
      final cacheKey = _cacheKey(reading.deviceCode, condition.sensorKey);
      final previousStatus = _lastStatuses[cacheKey];

      if (condition.status == FieldStatus.normal) {
        _lastStatuses[cacheKey] = FieldStatus.normal;
        continue;
      }

      final lastAlert = _lastAlerts[cacheKey];

      bool shouldAlert = false;

      if (previousStatus != null && previousStatus != condition.status) {
        shouldAlert = true;
      } else if (lastAlert == null) {
        shouldAlert = true;
      } else if (lastAlert.severity != condition.status) {
        shouldAlert = true;
      } else {
        final timeSinceLastAlert = _now().difference(lastAlert.createdAt);
        if (timeSinceLastAlert >= _cooldownPeriod) {
          shouldAlert = true;
        }
      }

      if (shouldAlert) {
        final generatedAt = _now();
        final alertId = _nextAlertId(generatedAt);

        final alert = Alert(
          id: alertId,
          farmId: connection.farmId,
          deviceId: connection.deviceId,
          deviceCode: reading.deviceCode,
          sensor: condition.sensorKey,
          severity: condition.status,
          readingValue: condition.value,
          thresholdMessage: condition.thresholdContext,
          recommendation: condition.actionRecommendation.message,
          isRead: false,
          source: reading.source,
          createdAt: generatedAt,
        );

        try {
          await _alertRepository.createAlert(reading.deviceCode, alert);
          _lastAlerts[cacheKey] = alert;
          _lastStatuses[cacheKey] = condition.status;
        } catch (e, st) {
          developer.log('Failed to create alert', error: e, stackTrace: st);
        }
      }
    }
  }

  String _cacheKey(String deviceCode, String sensorKey) {
    return '$deviceCode:$sensorKey';
  }

  String _nextAlertId(DateTime generatedAt) {
    return '${generatedAt.microsecondsSinceEpoch}_${_alertSequence++}';
  }
}

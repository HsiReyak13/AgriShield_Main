import 'dart:developer' as developer;

import 'package:agrishield/core/models/alert.dart';
import 'package:agrishield/core/models/data_source.dart';
import 'package:agrishield/core/models/field_status.dart';

abstract interface class AlertRepository {
  Future<void> createAlert(String deviceCode, Alert alert);
  Stream<List<Alert>> watchAlerts(String deviceCode);
}

abstract interface class AlertDataSource {
  Future<void> writeAlert(String deviceCode, Map<String, dynamic> alertJson);
  Stream<List<Object?>> watchAlertsPayload(String deviceCode);
}

class AlertDataSourceException implements Exception {
  const AlertDataSourceException(this.message);
  final String message;

  @override
  String toString() => 'AlertDataSourceException: $message';
}

class FirebaseAlertRepository implements AlertRepository {
  const FirebaseAlertRepository({required AlertDataSource dataSource})
    : _dataSource = dataSource;

  final AlertDataSource _dataSource;

  @override
  Future<void> createAlert(String deviceCode, Alert alert) async {
    try {
      if (alert.deviceCode != deviceCode) {
        throw AlertDataSourceException(
          'Alert deviceCode ${alert.deviceCode} does not match path $deviceCode',
        );
      }

      final json = <String, dynamic>{
        'id': alert.id,
        'farmId': alert.farmId,
        'deviceId': alert.deviceId,
        'deviceCode': alert.deviceCode,
        'sensor': alert.sensor,
        'severity': alert.severity.name,
        'readingValue': alert.readingValue,
        'thresholdMessage': alert.thresholdMessage,
        'recommendation': alert.recommendation,
        'isRead': alert.isRead,
        'source': alert.source.name,
        'createdAt': alert.createdAt.millisecondsSinceEpoch,
      };

      await _dataSource.writeAlert(deviceCode, json);
    } catch (e, st) {
      developer.log('Failed to create alert', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<List<Alert>> watchAlerts(String deviceCode) {
    return _dataSource.watchAlertsPayload(deviceCode).map((payloads) {
      return payloads.whereType<Map>().map(_alertFromPayload).nonNulls.toList();
    });
  }

  Alert? _alertFromPayload(Map<dynamic, dynamic> payload) {
    try {
      final json = Map<String, dynamic>.from(payload);
      return Alert(
        id: json['id'] as String,
        farmId: json['farmId'] as String,
        deviceId: json['deviceId'] as String,
        deviceCode: json['deviceCode'] as String,
        sensor: json['sensor'] as String,
        severity: FieldStatus.values.byName(json['severity'] as String),
        readingValue: (json['readingValue'] as num).toDouble(),
        thresholdMessage: json['thresholdMessage'] as String,
        recommendation: json['recommendation'] as String,
        isRead: json['isRead'] as bool,
        source: DataSource.values.byName(json['source'] as String),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          json['createdAt'] as int,
        ),
      );
    } catch (e, st) {
      developer.log(
        'Skipping malformed alert payload',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}

class UnavailableAlertDataSource implements AlertDataSource {
  const UnavailableAlertDataSource();

  @override
  Future<void> writeAlert(String deviceCode, Map<String, dynamic> alertJson) =>
      throw const AlertDataSourceException('alert-write-unavailable');

  @override
  Stream<List<Object?>> watchAlertsPayload(String deviceCode) =>
      Stream.value([]);
}

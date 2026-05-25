import 'package:agrishield/core/models/data_source.dart';
import 'package:agrishield/core/models/field_status.dart';

class Alert {
  const Alert({
    required this.id,
    required this.farmId,
    required this.deviceId,
    required this.deviceCode,
    required this.sensor,
    required this.severity,
    required this.readingValue,
    required this.thresholdMessage,
    required this.recommendation,
    required this.isRead,
    required this.source,
    required this.createdAt,
  });

  final String id;
  final String farmId;
  final String deviceId;
  final String deviceCode;
  final String sensor;
  final FieldStatus severity;
  final double readingValue;
  final String thresholdMessage;
  final String recommendation;
  final bool isRead;
  final DataSource source;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) {
    return other is Alert &&
        other.id == id &&
        other.farmId == farmId &&
        other.deviceId == deviceId &&
        other.deviceCode == deviceCode &&
        other.sensor == sensor &&
        other.severity == severity &&
        other.readingValue == readingValue &&
        other.thresholdMessage == thresholdMessage &&
        other.recommendation == recommendation &&
        other.isRead == isRead &&
        other.source == source &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    deviceId,
    deviceCode,
    sensor,
    severity,
    readingValue,
    thresholdMessage,
    recommendation,
    isRead,
    source,
    createdAt,
  );
}

import 'package:agrishield/core/models/data_source.dart';

class SensorReading {
  const SensorReading({
    required this.deviceCode,
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.waterLevel,
    required this.createdAt,
    required this.source,
    required this.firmwareVersion,
  });

  final String deviceCode;
  final double temperature;
  final double humidity;
  final int soilMoisture;
  final double waterLevel;
  final DateTime createdAt;
  final DataSource source;
  final String firmwareVersion;

  @override
  bool operator ==(Object other) {
    return other is SensorReading &&
        other.deviceCode == deviceCode &&
        other.temperature == temperature &&
        other.humidity == humidity &&
        other.soilMoisture == soilMoisture &&
        other.waterLevel == waterLevel &&
        other.createdAt == createdAt &&
        other.source == source &&
        other.firmwareVersion == firmwareVersion;
  }

  @override
  int get hashCode => Object.hash(
    deviceCode,
    temperature,
    humidity,
    soilMoisture,
    waterLevel,
    createdAt,
    source,
    firmwareVersion,
  );
}

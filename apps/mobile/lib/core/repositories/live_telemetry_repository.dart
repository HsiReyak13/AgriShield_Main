<<<<<<< HEAD
=======
import 'dart:developer' as developer;

>>>>>>> origin/main
import 'package:agrishield/core/models/data_source.dart';
import 'package:agrishield/core/models/sensor_reading.dart';

abstract interface class LiveTelemetryRepository {
  Stream<LiveTelemetryResult> watchLatest(String deviceCode);
}

abstract interface class LiveTelemetryDataSource {
  Stream<Object?> watchLatestPayload(String deviceCode);
}

<<<<<<< HEAD
=======
class UnavailableLiveTelemetryDataSource implements LiveTelemetryDataSource {
  const UnavailableLiveTelemetryDataSource();

  @override
  Stream<Object?> watchLatestPayload(String deviceCode) {
    throw const LiveTelemetryDataSourceException('live-telemetry-unavailable');
  }
}

>>>>>>> origin/main
class FirebaseLiveTelemetryRepository implements LiveTelemetryRepository {
  const FirebaseLiveTelemetryRepository({
    required LiveTelemetryDataSource dataSource,
  }) : _dataSource = dataSource;

  final LiveTelemetryDataSource _dataSource;

  @override
  Stream<LiveTelemetryResult> watchLatest(String deviceCode) async* {
    try {
<<<<<<< HEAD
      await for (final payload in _dataSource.watchLatestPayload(deviceCode)) {
        yield _parsePayload(deviceCode, payload);
      }
=======
      bool hasEmitted = false;
      await for (final payload in _dataSource.watchLatestPayload(deviceCode)) {
        hasEmitted = true;
        yield _parsePayload(deviceCode, payload);
      }
      if (!hasEmitted) {
        yield const LiveTelemetryResult.failure(
          LiveTelemetryFailure(
            code: LiveTelemetryFailureCode.noData,
            message: 'No latest reading has arrived yet.',
          ),
        );
      }
>>>>>>> origin/main
    } on LiveTelemetryDataSourceException {
      yield const LiveTelemetryResult.failure(
        LiveTelemetryFailure(
          code: LiveTelemetryFailureCode.unavailable,
          message: 'Latest field readings are unavailable right now.',
        ),
      );
<<<<<<< HEAD
    } catch (_) {
=======
    } catch (e, st) {
      developer.log('Unknown live telemetry error', error: e, stackTrace: st);
>>>>>>> origin/main
      yield const LiveTelemetryResult.failure(
        LiveTelemetryFailure(
          code: LiveTelemetryFailureCode.unknown,
          message: 'Latest field readings could not be loaded.',
        ),
      );
    }
  }

  LiveTelemetryResult _parsePayload(
    String requestedDeviceCode,
    Object? payload,
  ) {
    if (payload == null) {
      return const LiveTelemetryResult.failure(
        LiveTelemetryFailure(
          code: LiveTelemetryFailureCode.noData,
          message: 'No latest reading has arrived yet.',
        ),
      );
    }

    if (payload is! Map) {
      return _malformed('Latest reading data is not an object.');
    }

    final json = payload.map((key, value) => MapEntry(key.toString(), value));
    final payloadDeviceCode = json['deviceCode'];
    if (payloadDeviceCode is! String || payloadDeviceCode.isEmpty) {
      return _malformed('Latest reading is missing a device code.');
    }
    if (payloadDeviceCode != requestedDeviceCode) {
      return const LiveTelemetryResult.failure(
        LiveTelemetryFailure(
          code: LiveTelemetryFailureCode.deviceMismatch,
          message: 'Latest reading belongs to a different device.',
        ),
      );
    }

    final temperature = _readDouble(json['temperature']);
    final humidity = _readDouble(json['humidity']);
    final soilMoisture = _readInt(json['soilMoisture']);
    final waterLevel = _readDouble(json['waterLevel']);
    final createdAt = _readEpochMilliseconds(json['createdAt']);
    final source = json['source'];
    final firmwareVersion = json['firmwareVersion'];

    if (temperature == null ||
        temperature < -40 ||
        temperature > 80 ||
        humidity == null ||
        humidity < 0 ||
        humidity > 100 ||
        soilMoisture == null ||
        soilMoisture < 0 ||
<<<<<<< HEAD
        soilMoisture > 4095 ||
        waterLevel == null ||
        waterLevel < 0 ||
        createdAt == null ||
=======
        waterLevel == null ||
        waterLevel < 0 ||
        waterLevel > 1000 ||
        createdAt == null ||
        createdAt.isAfter(DateTime.now().add(const Duration(hours: 24))) ||
>>>>>>> origin/main
        source != 'live' ||
        firmwareVersion is! String ||
        firmwareVersion.isEmpty) {
      return _malformed('Latest reading contains invalid values.');
    }

    return LiveTelemetryResult.success(
      SensorReading(
        deviceCode: payloadDeviceCode,
        temperature: temperature,
        humidity: humidity,
        soilMoisture: soilMoisture,
        waterLevel: waterLevel,
        createdAt: createdAt,
        source: DataSource.live,
        firmwareVersion: firmwareVersion,
      ),
    );
  }

  LiveTelemetryResult _malformed(String message) {
    return LiveTelemetryResult.failure(
      LiveTelemetryFailure(
        code: LiveTelemetryFailureCode.malformedData,
        message: message,
      ),
    );
  }

  double? _readDouble(Object? value) {
    if (value is num && value.isFinite) return value.toDouble();
<<<<<<< HEAD
=======
    if (value is String) return double.tryParse(value);
>>>>>>> origin/main
    return null;
  }

  int? _readInt(Object? value) {
    if (value is int) return value;
<<<<<<< HEAD
=======
    if (value is num && value.isFinite) return value.toInt();
    if (value is String) return int.tryParse(value);
>>>>>>> origin/main
    return null;
  }

  DateTime? _readEpochMilliseconds(Object? value) {
<<<<<<< HEAD
    if (value is! int || value <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(value);
=======
    final millis = _readInt(value);
    if (millis == null || millis <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
>>>>>>> origin/main
  }
}

class LiveTelemetryResult {
  const LiveTelemetryResult._({this.reading, this.failure});

  const LiveTelemetryResult.success(SensorReading reading)
    : this._(reading: reading);

  const LiveTelemetryResult.failure(LiveTelemetryFailure failure)
    : this._(failure: failure);

  final SensorReading? reading;
  final LiveTelemetryFailure? failure;

  bool get isSuccess => reading != null;

  bool get isFailure => failure != null;
}

class LiveTelemetryFailure {
  const LiveTelemetryFailure({required this.code, required this.message});

  final LiveTelemetryFailureCode code;
  final String message;
}

enum LiveTelemetryFailureCode {
  noData,
  malformedData,
  deviceMismatch,
  unavailable,
  unknown,
}

class LiveTelemetryDataSourceException implements Exception {
  const LiveTelemetryDataSourceException(this.message);

  final String message;

  @override
  String toString() => 'LiveTelemetryDataSourceException: $message';
}

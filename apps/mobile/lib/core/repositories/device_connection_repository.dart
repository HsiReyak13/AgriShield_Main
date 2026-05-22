import 'package:agrishield/core/models/data_source.dart';
import 'package:agrishield/core/models/device_connection.dart';
import 'package:agrishield/core/repositories/device_code_key_encoder.dart';

abstract interface class DeviceConnectionRepository {
  Future<DeviceConnectionResult> resolveDeviceCode(String code);

  Future<DeviceConnection?> readSavedConnection();

  Future<void> saveConnection(DeviceConnection connection);

  Future<void> clearConnection();
}

abstract interface class DeviceCodeLookupDataSource {
  Future<Map<String, dynamic>?> readDeviceCode(String codeKey);
}

class FirebaseDeviceConnectionRepository implements DeviceConnectionRepository {
  FirebaseDeviceConnectionRepository({
    required DeviceCodeLookupDataSource lookupDataSource,
    DeviceCodeKeyEncoder keyEncoder = const DeviceCodeKeyEncoder(),
  }) : _lookupDataSource = lookupDataSource,
       _keyEncoder = keyEncoder;

  final DeviceCodeLookupDataSource _lookupDataSource;
  final DeviceCodeKeyEncoder _keyEncoder;

  DeviceConnection? _savedConnection;

  @override
  Future<DeviceConnectionResult> resolveDeviceCode(String code) async {
    final normalizedCode = _keyEncoder.normalize(code);
    if (normalizedCode.isEmpty) {
      return const DeviceConnectionResult.failure(
        DeviceConnectionFailure(
          code: DeviceConnectionFailureCode.malformedData,
          message: 'Device code is required.',
        ),
      );
    }

    try {
      final payload = await _lookupDataSource.readDeviceCode(
        _keyEncoder.encode(normalizedCode),
      );
      if (payload == null) {
        return const DeviceConnectionResult.failure(
          DeviceConnectionFailure(
            code: DeviceConnectionFailureCode.notFound,
            message: 'Device code was not found.',
          ),
        );
      }

      final lookup = DeviceCodeLookup.fromJson(payload);
      if (lookup == null) {
        return const DeviceConnectionResult.failure(
          DeviceConnectionFailure(
            code: DeviceConnectionFailureCode.malformedData,
            message: 'Device code data is incomplete.',
          ),
        );
      }

      if (!lookup.active) {
        return const DeviceConnectionResult.failure(
          DeviceConnectionFailure(
            code: DeviceConnectionFailureCode.inactive,
            message: 'Device code is inactive.',
          ),
        );
      }

      return DeviceConnectionResult.success(
        DeviceConnection(
          deviceCode: normalizedCode,
          deviceId: lookup.deviceId,
          farmId: lookup.farmId,
          dataSource: DataSource.live,
        ),
      );
    } on DeviceConnectionDataSourceException {
      return const DeviceConnectionResult.failure(
        DeviceConnectionFailure(
          code: DeviceConnectionFailureCode.unavailable,
          message: 'Device lookup is unavailable.',
        ),
      );
    } catch (_) {
      return const DeviceConnectionResult.failure(
        DeviceConnectionFailure(
          code: DeviceConnectionFailureCode.unknown,
          message: 'Device lookup failed.',
        ),
      );
    }
  }

  @override
  Future<DeviceConnection?> readSavedConnection() async => _savedConnection;

  @override
  Future<void> saveConnection(DeviceConnection connection) async {
    _savedConnection = connection;
  }

  @override
  Future<void> clearConnection() async {
    _savedConnection = null;
  }
}

class DeviceConnectionResult {
  const DeviceConnectionResult._({this.connection, this.failure});

  const DeviceConnectionResult.success(DeviceConnection connection)
    : this._(connection: connection);

  const DeviceConnectionResult.failure(DeviceConnectionFailure failure)
    : this._(failure: failure);

  final DeviceConnection? connection;
  final DeviceConnectionFailure? failure;

  bool get isSuccess => connection != null;

  bool get isFailure => failure != null;
}

class DeviceConnectionFailure {
  const DeviceConnectionFailure({required this.code, required this.message});

  final DeviceConnectionFailureCode code;
  final String message;
}

enum DeviceConnectionFailureCode {
  notFound,
  inactive,
  malformedData,
  unavailable,
  unknown,
}

class DeviceConnectionDataSourceException implements Exception {
  const DeviceConnectionDataSourceException(this.message);

  final String message;

  @override
  String toString() => 'DeviceConnectionDataSourceException: $message';
}

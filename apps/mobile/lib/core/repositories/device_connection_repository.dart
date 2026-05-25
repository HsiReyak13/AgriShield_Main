import 'dart:convert';

import 'package:agrishield/core/models/data_source.dart';
import 'package:agrishield/core/models/device_connection.dart';
import 'package:agrishield/core/repositories/device_code_key_encoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class DeviceConnectionRepository {
  Future<DeviceConnectionResult> resolveDeviceCode(String code);

  Future<DeviceConnection?> readSavedConnection();

  Future<void> saveConnection(DeviceConnection connection);

  Future<void> clearConnection();
}

abstract interface class DeviceCodeLookupDataSource {
  Future<Object?> readDeviceCode(String codeKey);
}

class UnavailableDeviceCodeLookupDataSource
    implements DeviceCodeLookupDataSource {
  const UnavailableDeviceCodeLookupDataSource();

  @override
  Future<Object?> readDeviceCode(String codeKey) {
    throw const DeviceConnectionDataSourceException('lookup-unavailable');
  }
}

abstract interface class DeviceConnectionStore {
  Future<DeviceConnection?> read();

  Future<void> save(DeviceConnection connection);

  Future<void> clear();
}

class SharedPreferencesDeviceConnectionStore implements DeviceConnectionStore {
  SharedPreferencesDeviceConnectionStore({
    SharedPreferencesAsync? preferences,
    String storageKey = 'agrishield.deviceConnection',
  }) : _preferences = preferences ?? SharedPreferencesAsync(),
       _storageKey = storageKey;

  final SharedPreferencesAsync _preferences;
  final String _storageKey;

  @override
  Future<DeviceConnection?> read() async {
    final raw = await _preferences.getString(_storageKey);
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return DeviceConnection.fromStorageJson(
        decoded.map((key, value) => MapEntry(key.toString(), value)),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(DeviceConnection connection) async {
    await _preferences.setString(
      _storageKey,
      jsonEncode(connection.toStorageJson()),
    );
  }

  @override
  Future<void> clear() async {
    await _preferences.remove(_storageKey);
  }
}

class MemoryDeviceConnectionStore implements DeviceConnectionStore {
  DeviceConnection? _connection;

  @override
  Future<DeviceConnection?> read() async => _connection;

  @override
  Future<void> save(DeviceConnection connection) async {
    _connection = connection;
  }

  @override
  Future<void> clear() async {
    _connection = null;
  }
}

class FirebaseDeviceConnectionRepository implements DeviceConnectionRepository {
  FirebaseDeviceConnectionRepository({
    required DeviceCodeLookupDataSource lookupDataSource,
    DeviceConnectionStore? connectionStore,
    DeviceCodeKeyEncoder keyEncoder = const DeviceCodeKeyEncoder(),
  }) : _lookupDataSource = lookupDataSource,
       _connectionStore =
           connectionStore ?? SharedPreferencesDeviceConnectionStore(),
       _keyEncoder = keyEncoder;

  final DeviceCodeLookupDataSource _lookupDataSource;
  final DeviceConnectionStore _connectionStore;
  final DeviceCodeKeyEncoder _keyEncoder;

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
        _keyEncoder.hashNormalized(normalizedCode),
      );
      if (payload == null) {
        return const DeviceConnectionResult.failure(
          DeviceConnectionFailure(
            code: DeviceConnectionFailureCode.notFound,
            message: 'Device code was not found.',
          ),
        );
      }

      if (payload is! Map) {
        return const DeviceConnectionResult.failure(
          DeviceConnectionFailure(
            code: DeviceConnectionFailureCode.malformedData,
            message: 'Device code data is not an object.',
          ),
        );
      }

      final lookup = DeviceCodeLookup.fromJson(
        payload.map((key, value) => MapEntry(key.toString(), value)),
      );
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
  Future<DeviceConnection?> readSavedConnection() => _connectionStore.read();

  @override
  Future<void> saveConnection(DeviceConnection connection) async {
    await _connectionStore.save(connection);
  }

  @override
  Future<void> clearConnection() async {
    await _connectionStore.clear();
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

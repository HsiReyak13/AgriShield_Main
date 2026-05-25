import 'package:agrishield/core/models/data_source.dart';

class DeviceConnection {
  const DeviceConnection({
    required this.deviceCode,
    required this.deviceId,
    required this.farmId,
    this.dataSource = DataSource.live,
  });

  final String deviceCode;
  final String deviceId;
  final String farmId;
  final DataSource dataSource;

  Map<String, String> toStorageJson() {
    return {
      'deviceCode': deviceCode,
      'deviceId': deviceId,
      'farmId': farmId,
      'dataSource': dataSource.name,
    };
  }

  static DeviceConnection? fromStorageJson(Map<String, Object?> json) {
    final deviceCode = json['deviceCode'];
    final deviceId = json['deviceId'];
    final farmId = json['farmId'];
    final dataSourceName = json['dataSource'];

    if (deviceCode is! String ||
        deviceId is! String ||
        farmId is! String ||
        dataSourceName is! String) {
      return null;
    }

    final normalizedDeviceCode = _normalizeStoredDeviceCode(deviceCode);
    final trimmedDeviceId = deviceId.trim();
    final trimmedFarmId = farmId.trim();
    if (normalizedDeviceCode.isEmpty ||
        trimmedDeviceId.isEmpty ||
        trimmedFarmId.isEmpty) {
      return null;
    }

    final dataSource = DataSource.values
        .where((source) => source.name == dataSourceName)
        .firstOrNull;
    if (dataSource == null) return null;

    return DeviceConnection(
      deviceCode: normalizedDeviceCode,
      deviceId: trimmedDeviceId,
      farmId: trimmedFarmId,
      dataSource: dataSource,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DeviceConnection &&
            other.deviceCode == deviceCode &&
            other.deviceId == deviceId &&
            other.farmId == farmId &&
            other.dataSource == dataSource;
  }

  @override
  int get hashCode => Object.hash(deviceCode, deviceId, farmId, dataSource);
}

String _normalizeStoredDeviceCode(String code) {
  return code.trim().replaceAll(RegExp(r'[.#$\[\]\s-]+'), '').toUpperCase();
}

class DeviceCodeLookup {
  const DeviceCodeLookup({
    required this.farmId,
    required this.deviceId,
    required this.active,
  });

  final String farmId;
  final String deviceId;
  final bool active;

  static DeviceCodeLookup? fromJson(Map<String, dynamic> json) {
    final farmId = json['farmId'];
    final deviceId = json['deviceId'];
    final active = json['active'];

    if (farmId is! String ||
        farmId.trim().isEmpty ||
        deviceId is! String ||
        deviceId.trim().isEmpty ||
        active is! bool) {
      return null;
    }

    return DeviceCodeLookup(farmId: farmId, deviceId: deviceId, active: active);
  }
}

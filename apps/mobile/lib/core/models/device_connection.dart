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

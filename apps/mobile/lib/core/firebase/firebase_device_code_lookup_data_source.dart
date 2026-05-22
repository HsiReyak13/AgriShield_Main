import 'package:agrishield/core/firebase/rtdb_paths.dart';
import 'package:agrishield/core/repositories/device_connection_repository.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseDeviceCodeLookupDataSource implements DeviceCodeLookupDataSource {
  const FirebaseDeviceCodeLookupDataSource(this._database);

  final FirebaseDatabase _database;

  @override
  Future<Map<String, dynamic>?> readDeviceCode(String codeKey) async {
    try {
      final snapshot = await _database.ref(RtdbPaths.deviceCode(codeKey)).get();
      final value = snapshot.value;

      if (value == null) {
        return null;
      }

      if (value is Map) {
        return value.map((key, value) => MapEntry(key.toString(), value));
      }

      throw const DeviceConnectionDataSourceException(
        'Device code payload was not an object.',
      );
    } on DeviceConnectionDataSourceException {
      rethrow;
    } catch (error) {
      throw DeviceConnectionDataSourceException(error.toString());
    }
  }
}

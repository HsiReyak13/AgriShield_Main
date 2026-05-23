import 'package:agrishield/core/firebase/firebase_database_provider.dart';
import 'package:agrishield/core/repositories/device_connection_repository.dart';

class FirebaseDeviceCodeLookupDataSource implements DeviceCodeLookupDataSource {
  const FirebaseDeviceCodeLookupDataSource(this._databaseProvider);

  final FirebaseDatabaseProvider _databaseProvider;

  @override
  Future<Object?> readDeviceCode(String codeKey) async {
    try {
      return await _databaseProvider.readDeviceCode(codeKey);
    } catch (error) {
      throw DeviceConnectionDataSourceException(error.toString());
    }
  }
}

import 'package:agrishield/core/firebase/rtdb_paths.dart';
import 'package:agrishield/core/repositories/live_telemetry_repository.dart';
import 'package:agrishield/core/repositories/device_connection_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseDatabaseProvider
    implements DeviceCodeLookupDataSource, LiveTelemetryDataSource {
  const FirebaseDatabaseProvider(this._database);

  factory FirebaseDatabaseProvider.instance({
    FirebaseApp? app,
    String? databaseUrl,
  }) {
    final firebaseApp = app ?? Firebase.app();
    final database = databaseUrl == null || databaseUrl.isEmpty
        ? FirebaseDatabase.instanceFor(app: firebaseApp)
        : FirebaseDatabase.instanceFor(
            app: firebaseApp,
            databaseURL: databaseUrl,
          );

    return FirebaseDatabaseProvider(database);
  }

  final FirebaseDatabase _database;

  @override
  Future<Object?> readDeviceCode(String codeKey) async {
    final snapshot = await _database.ref(RtdbPaths.deviceCode(codeKey)).get();
    return snapshot.value;
  }

  @override
  Stream<Object?> watchLatestPayload(String deviceCode) {
    return _database
        .ref(RtdbPaths.deviceLatest(deviceCode))
        .onValue
        .map((event) => event.snapshot.value)
        .handleError((Object error) {
          if (error is FirebaseException) {
            throw LiveTelemetryDataSourceException(error.code);
          }
          throw const LiveTelemetryDataSourceException('latest-stream-error');
        });
  }
}

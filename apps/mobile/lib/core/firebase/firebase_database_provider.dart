import 'package:agrishield/core/firebase/rtdb_paths.dart';
import 'package:agrishield/core/repositories/live_telemetry_repository.dart';
import 'package:agrishield/core/repositories/device_connection_repository.dart';
<<<<<<< HEAD
=======
import 'package:agrishield/core/repositories/alert_repository.dart';
>>>>>>> origin/main
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseDatabaseProvider
<<<<<<< HEAD
    implements DeviceCodeLookupDataSource, LiveTelemetryDataSource {
=======
    implements
        DeviceCodeLookupDataSource,
        LiveTelemetryDataSource,
        AlertDataSource {
>>>>>>> origin/main
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
<<<<<<< HEAD
    final snapshot = await _database.ref(RtdbPaths.deviceCode(codeKey)).get();
    return snapshot.value;
=======
    try {
      final snapshot = await _database.ref(RtdbPaths.deviceCode(codeKey)).get();
      return snapshot.value;
    } on FirebaseException catch (e) {
      throw DeviceConnectionDataSourceException(e.code);
    } catch (e) {
      throw DeviceConnectionDataSourceException(e.toString());
    }
>>>>>>> origin/main
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
<<<<<<< HEAD
=======

  @override
  Future<void> writeAlert(
    String deviceCode,
    Map<String, dynamic> alertJson,
  ) async {
    try {
      final alertId = alertJson['id'] as String;
      await _database
          .ref(RtdbPaths.deviceAlerts(deviceCode))
          .child(alertId)
          .set(alertJson);
    } on FirebaseException catch (e) {
      throw AlertDataSourceException(e.code);
    } catch (e) {
      throw AlertDataSourceException(e.toString());
    }
  }

  @override
  Stream<List<Object?>> watchAlertsPayload(String deviceCode) {
    return _database
        .ref(RtdbPaths.deviceAlerts(deviceCode))
        .onValue
        .map((event) {
          final value = event.snapshot.value;
          if (value == null) {
            return <Object?>[];
          }
          if (value is Map) {
            return value.values.toList();
          }
          return <Object?>[];
        })
        .handleError((Object error) {
          if (error is FirebaseException) {
            throw AlertDataSourceException(error.code);
          }
          throw const AlertDataSourceException('alerts-stream-error');
        });
  }
>>>>>>> origin/main
}

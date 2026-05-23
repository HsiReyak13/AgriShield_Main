import 'package:agrishield/core/models/device_connection.dart';
import 'package:agrishield/core/repositories/device_connection_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DevicePairingCubit extends Cubit<DevicePairingState> {
  DevicePairingCubit({required DeviceConnectionRepository repository})
    : _repository = repository,
      super(const DevicePairingState(status: DevicePairingStatus.initial));

  final DeviceConnectionRepository _repository;

  Future<void> load() async {
    emit(const DevicePairingState(status: DevicePairingStatus.loading));
    final connection = await _repository.readSavedConnection();
    emit(
      connection == null
          ? const DevicePairingState(status: DevicePairingStatus.unpaired)
          : DevicePairingState(
              status: DevicePairingStatus.paired,
              connection: connection,
            ),
    );
  }

  Future<void> submit(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      emit(
        DevicePairingState.failure(
          DevicePairingFailure.empty,
          DevicePairingFailure.empty.message,
        ),
      );
      return;
    }

    emit(const DevicePairingState(status: DevicePairingStatus.submitting));
    final result = await _repository.resolveDeviceCode(trimmed);
    final connection = result.connection;
    if (connection != null) {
      await _repository.saveConnection(connection);
      emit(
        DevicePairingState(
          status: DevicePairingStatus.success,
          connection: connection,
        ),
      );
      return;
    }

    final failure = DevicePairingFailure.fromRepositoryCode(
      result.failure?.code ?? DeviceConnectionFailureCode.unknown,
    );
    emit(DevicePairingState.failure(failure, failure.message));
  }

  Future<void> clearConnection() async {
    await _repository.clearConnection();
    emit(const DevicePairingState(status: DevicePairingStatus.unpaired));
  }
}

class DevicePairingState {
  const DevicePairingState({
    required this.status,
    this.connection,
    this.failure,
    this.message,
  });

  const DevicePairingState.failure(DevicePairingFailure failure, String message)
    : this(
        status: DevicePairingStatus.failure,
        failure: failure,
        message: message,
      );

  final DevicePairingStatus status;
  final DeviceConnection? connection;
  final DevicePairingFailure? failure;
  final String? message;

  bool get isBusy {
    return status == DevicePairingStatus.loading ||
        status == DevicePairingStatus.submitting;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DevicePairingState &&
            other.status == status &&
            other.connection == connection &&
            other.failure == failure &&
            other.message == message;
  }

  @override
  int get hashCode => Object.hash(status, connection, failure, message);
}

enum DevicePairingStatus {
  initial,
  loading,
  unpaired,
  paired,
  submitting,
  success,
  failure,
}

enum DevicePairingFailure {
  empty('Enter the device code from your field device.'),
  notFound('We could not find that device code. Check the code and try again.'),
  inactive(
    'This device code is not active. Ask your project team for a new code.',
  ),
  malformedData('Check the device code and try again.'),
  unavailable(
    'Device lookup is unavailable. Check your connection or try Demo Mode.',
  ),
  unknown(
    'Something went wrong while connecting the device. Please try again.',
  );

  const DevicePairingFailure(this.message);

  final String message;

  static DevicePairingFailure fromRepositoryCode(
    DeviceConnectionFailureCode code,
  ) {
    return switch (code) {
      DeviceConnectionFailureCode.notFound => DevicePairingFailure.notFound,
      DeviceConnectionFailureCode.inactive => DevicePairingFailure.inactive,
      DeviceConnectionFailureCode.malformedData =>
        DevicePairingFailure.malformedData,
      DeviceConnectionFailureCode.unavailable =>
        DevicePairingFailure.unavailable,
      DeviceConnectionFailureCode.unknown => DevicePairingFailure.unknown,
    };
  }
}

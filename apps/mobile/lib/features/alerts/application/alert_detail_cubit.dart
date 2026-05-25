import 'dart:async';

import 'package:agrishield/core/models/alert.dart';
import 'package:agrishield/core/repositories/alert_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'alert_detail_state.dart';

class AlertDetailCubit extends Cubit<AlertDetailState> {
  AlertDetailCubit({
    required AlertRepository alertRepository,
    required String deviceCode,
    required String alertId,
  }) : _alertRepository = alertRepository,
       _deviceCode = deviceCode,
       _alertId = alertId,
       super(const AlertDetailLoading());

  final AlertRepository _alertRepository;
  final String _deviceCode;
  final String _alertId;
  StreamSubscription<List<Alert>>? _alertsSubscription;

  Future<void> startListening() async {
    emit(const AlertDetailLoading());

    final previousSubscription = _alertsSubscription;
    _alertsSubscription = null;
    await previousSubscription?.cancel();
    if (isClosed) return;

    _alertsSubscription = _alertRepository
        .watchAlerts(_deviceCode)
        .listen(
          (alerts) {
            if (isClosed) return;
            final matchingAlert = alerts.where(
              (alert) =>
                  alert.id == _alertId && alert.deviceCode == _deviceCode,
            );
            if (matchingAlert.isEmpty) {
              emit(AlertDetailNotFound(alertId: _alertId));
              return;
            }

            emit(AlertDetailLoaded(matchingAlert.first));
          },
          onError: (Object error) {
            if (isClosed) return;
            emit(
              const AlertDetailError(
                message: 'Alert details could not be loaded right now.',
              ),
            );
          },
        );
  }

  @override
  Future<void> close() async {
    final subscription = _alertsSubscription;
    _alertsSubscription = null;
    await subscription?.cancel();
    return super.close();
  }
}

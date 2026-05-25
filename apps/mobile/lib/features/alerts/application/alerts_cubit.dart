import 'dart:async';

import 'package:agrishield/core/models/alert.dart';
import 'package:agrishield/core/models/field_status.dart';
import 'package:agrishield/core/repositories/alert_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'alerts_state.dart';

class AlertsCubit extends Cubit<AlertsState> {
  AlertsCubit({
    required AlertRepository alertRepository,
    required String deviceCode,
  }) : _alertRepository = alertRepository,
       _deviceCode = deviceCode,
       super(const AlertsInitial());

  final AlertRepository _alertRepository;
  final String _deviceCode;
  StreamSubscription<List<Alert>>? _alertsSubscription;
  List<Alert> _allAlerts = [];

  void startListening() {
    emit(AlertsLoading(filter: state.filter));

    _alertsSubscription?.cancel();
    _alertsSubscription = _alertRepository
        .watchAlerts(_deviceCode)
        .listen(
          (alerts) {
            // Requirements: Ensure sorting by createdAt descending
            final sortedAlerts = List<Alert>.from(alerts)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            _allAlerts = sortedAlerts;
            _emitFilteredAlerts();
          },
          onError: (Object error) {
            emit(
              AlertsError(
                message: 'Failed to load alerts',
                filter: state.filter,
              ),
            );
          },
        );
  }

  void setFilter(AlertFilter filter) {
    switch (state) {
      case AlertsLoaded():
        _emitFilteredAlerts(filterOverride: filter);
      case AlertsError(message: final message):
        emit(AlertsError(message: message, filter: filter));
      case AlertsLoading():
        emit(AlertsLoading(filter: filter));
      case AlertsInitial():
        emit(AlertsInitial(filter: filter));
    }
  }

  void _emitFilteredAlerts({AlertFilter? filterOverride}) {
    final activeFilter = filterOverride ?? state.filter;
    final filteredAlerts = _allAlerts
        .where((alert) {
          return switch (activeFilter) {
            AlertFilter.all => true,
            AlertFilter.critical => alert.severity == FieldStatus.critical,
            AlertFilter.warning => alert.severity == FieldStatus.warning,
            AlertFilter.normal => alert.severity == FieldStatus.normal,
            AlertFilter.active => !alert.isRead,
            AlertFilter.resolved => alert.isRead,
          };
        })
        .toList(growable: false);

    emit(AlertsLoaded(alerts: filteredAlerts, filter: activeFilter));
  }

  @override
  Future<void> close() {
    _alertsSubscription?.cancel();
    return super.close();
  }
}

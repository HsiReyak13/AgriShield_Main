import 'package:agrishield/core/models/alert.dart';
import 'package:flutter/foundation.dart';

enum AlertFilter {
  all,
  critical,
  warning,
  normal,
  active,
  resolved,
}

sealed class AlertsState {
  const AlertsState({this.filter = AlertFilter.all});

  final AlertFilter filter;
}

final class AlertsInitial extends AlertsState {
  const AlertsInitial({super.filter});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlertsInitial && other.filter == filter;
  }

  @override
  int get hashCode => Object.hash('AlertsInitial', filter);
}

final class AlertsLoading extends AlertsState {
  const AlertsLoading({super.filter});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlertsLoading && other.filter == filter;
  }

  @override
  int get hashCode => Object.hash('AlertsLoading', filter);
}

final class AlertsLoaded extends AlertsState {
  const AlertsLoaded({
    required this.alerts,
    super.filter,
  });

  final List<Alert> alerts;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlertsLoaded && 
           listEquals(other.alerts, alerts) && 
           other.filter == filter;
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(alerts), filter);
}

final class AlertsError extends AlertsState {
  const AlertsError({
    required this.message,
    super.filter,
  });

  final String message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlertsError && 
           other.message == message && 
           other.filter == filter;
  }

  @override
  int get hashCode => Object.hash(message, filter);
}

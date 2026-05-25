import 'package:agrishield/core/models/alert.dart';

sealed class AlertDetailState {
  const AlertDetailState();
}

final class AlertDetailLoading extends AlertDetailState {
  const AlertDetailLoading();

  @override
  bool operator ==(Object other) => other is AlertDetailLoading;

  @override
  int get hashCode => 'AlertDetailLoading'.hashCode;
}

final class AlertDetailLoaded extends AlertDetailState {
  const AlertDetailLoaded(this.alert);

  final Alert alert;

  @override
  bool operator ==(Object other) {
    return other is AlertDetailLoaded && other.alert == alert;
  }

  @override
  int get hashCode => alert.hashCode;
}

final class AlertDetailNotFound extends AlertDetailState {
  const AlertDetailNotFound({required this.alertId});

  final String alertId;

  @override
  bool operator ==(Object other) {
    return other is AlertDetailNotFound && other.alertId == alertId;
  }

  @override
  int get hashCode => alertId.hashCode;
}

final class AlertDetailError extends AlertDetailState {
  const AlertDetailError({required this.message});

  final String message;

  @override
  bool operator ==(Object other) {
    return other is AlertDetailError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

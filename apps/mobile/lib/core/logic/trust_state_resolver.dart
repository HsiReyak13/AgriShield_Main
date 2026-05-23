import 'package:agrishield/core/logic/field_status_classifier.dart';
import 'package:agrishield/core/models/field_classification.dart';
import 'package:agrishield/core/models/field_status.dart';
import 'package:agrishield/core/models/field_thresholds.dart';
import 'package:agrishield/core/models/trust_state.dart';
import 'package:agrishield/core/repositories/live_telemetry_repository.dart';

class TrustStateResolver {
  const TrustStateResolver({
    FieldStatusClassifier classifier = const FieldStatusClassifier(),
  }) : _classifier = classifier;

  final FieldStatusClassifier _classifier;

  TrustResolution resolve(
    LiveTelemetryResult telemetryResult, {
    required DateTime now,
    FieldThresholds thresholds = FieldThresholds.prototypeDefaults,
    FieldClassification? lastKnownClassification,
  }) {
    final failure = telemetryResult.failure;
    if (failure != null) {
      return TrustResolution(
        trustState: _trustStateForFailure(failure.code),
        lastKnownClassification: lastKnownClassification,
      );
    }

    final reading = telemetryResult.reading;
    if (reading == null) {
      return TrustResolution(
        trustState: TrustState.noData,
        lastKnownClassification: lastKnownClassification,
      );
    }

    if (now.difference(reading.createdAt) > thresholds.freshnessThreshold) {
      return TrustResolution(
        trustState: TrustState.stale,
        lastKnownClassification: lastKnownClassification,
      );
    }

    final classification = _classifier.classify(
      reading,
      thresholds: thresholds,
    );

    return TrustResolution(
      trustState: _trustStateForStatus(classification.fieldStatus),
      currentClassification: classification,
      lastKnownClassification: lastKnownClassification,
    );
  }

  TrustState _trustStateForFailure(LiveTelemetryFailureCode failureCode) {
    return switch (failureCode) {
      LiveTelemetryFailureCode.noData => TrustState.noData,
      LiveTelemetryFailureCode.unavailable => TrustState.offline,
      LiveTelemetryFailureCode.malformedData ||
      LiveTelemetryFailureCode.deviceMismatch ||
      LiveTelemetryFailureCode.unknown => TrustState.error,
    };
  }

  TrustState _trustStateForStatus(FieldStatus status) {
    return switch (status) {
      FieldStatus.critical => TrustState.critical,
      FieldStatus.warning => TrustState.warning,
      FieldStatus.normal => TrustState.healthy,
    };
  }
}

class TrustResolution {
  const TrustResolution({
    required this.trustState,
    this.currentClassification,
    this.lastKnownClassification,
  });

  final TrustState trustState;
  final FieldClassification? currentClassification;
  final FieldClassification? lastKnownClassification;
}

import 'dart:async';

import 'package:agrishield/core/logic/trust_state_resolver.dart';
import 'package:agrishield/core/models/field_classification.dart';
import 'package:agrishield/core/models/field_recommendation.dart';
import 'package:agrishield/core/models/field_status.dart';
import 'package:agrishield/core/models/field_thresholds.dart';
import 'package:agrishield/core/models/sensor_reading.dart';
import 'package:agrishield/core/models/trust_state.dart';
import 'package:agrishield/core/repositories/live_telemetry_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required LiveTelemetryRepository liveTelemetryRepository,
    TrustStateResolver trustStateResolver = const TrustStateResolver(),
    DateTime Function()? now,
    FieldThresholds thresholds = FieldThresholds.prototypeDefaults,
  }) : _liveTelemetryRepository = liveTelemetryRepository,
       _trustStateResolver = trustStateResolver,
       _now = now ?? DateTime.now,
       _thresholds = thresholds,
       super(const DashboardState.initial());

  final LiveTelemetryRepository _liveTelemetryRepository;
  final TrustStateResolver _trustStateResolver;
  final DateTime Function() _now;
  final FieldThresholds _thresholds;
  StreamSubscription<LiveTelemetryResult>? _subscription;
  Timer? _staleCheckTimer;
  FieldClassification? _lastKnownClassification;

  void watchDevice(String deviceCode, {bool forceRefresh = false}) {
    if (!forceRefresh &&
        state.deviceCode == deviceCode &&
        _subscription != null) {
      return;
    }
    _subscription?.cancel();
    _staleCheckTimer?.cancel();
    _subscription = null;
    _staleCheckTimer = null;
    if (isClosed) return;

    if (state.deviceCode != deviceCode) {
      _lastKnownClassification = null;
    }

    emit(DashboardState.loading(deviceCode: deviceCode));
    _staleCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkStale(),
    );
    _subscription = _liveTelemetryRepository
        .watchLatest(deviceCode)
        .listen(
          (result) => _resolveResult(deviceCode, result),
          onError: (_) {
            _resolveResult(
              deviceCode,
              const LiveTelemetryResult.failure(
                LiveTelemetryFailure(
                  code: LiveTelemetryFailureCode.unavailable,
                  message: 'Latest field readings are unavailable right now.',
                ),
              ),
            );
          },
          onDone: () {
            if (isClosed) return;
            _subscription = null;
            emit(
              DashboardState.ready(
                trustState: TrustState.offline,
                deviceCode: deviceCode,
                lastKnownClassification: _stripNormalLastKnown(),
                message: 'Latest field readings are unavailable right now.',
                updatedAt: _now(),
              ),
            );
          },
        );
  }

  void _checkStale() {
    if (isClosed || state.deviceCode == null || state.reading == null) return;
    if (state.trustState == TrustState.stale) return; // already stale

    final age = _now().difference(state.reading!.createdAt);
    if (age > _thresholds.freshnessThreshold) {
      // Re-resolve with the existing reading to trigger stale state
      _resolveResult(
        state.deviceCode!,
        LiveTelemetryResult.success(state.reading!),
      );
    }
  }

  void _resolveResult(String deviceCode, LiveTelemetryResult result) {
    if (isClosed) return;
    if (state.deviceCode != null && state.deviceCode != deviceCode) return;

    final resolution = _trustStateResolver.resolve(
      result,
      now: _now(),
      thresholds: _thresholds,
      lastKnownClassification: _lastKnownClassification,
    );
    final currentClassification = resolution.currentClassification;
    if (currentClassification != null) {
      _lastKnownClassification = currentClassification;
    }

    emit(
      DashboardState.ready(
        trustState: resolution.trustState,
        deviceCode: deviceCode,
        reading: currentClassification == null ? null : result.reading,
        classification: currentClassification,
        lastKnownClassification:
            currentClassification ?? resolution.lastKnownClassification,
        message: _messageFor(result, resolution.trustState),
        updatedAt: _now(),
      ),
    );
  }

  FieldClassification? _stripNormalLastKnown() {
    final classification = _lastKnownClassification;
    if (classification == null) return null;
    return classification.fieldStatus == FieldStatus.normal
        ? null
        : classification;
  }

  String _messageFor(LiveTelemetryResult result, TrustState trustState) {
    final failureMessage = result.failure?.message;
    if (failureMessage != null && failureMessage.isNotEmpty) {
      return failureMessage;
    }

    return switch (trustState) {
      TrustState.loading => 'Checking for the latest field reading.',
      TrustState.noData => 'No latest reading has arrived yet.',
      TrustState.offline => 'Latest field readings are unavailable right now.',
      TrustState.stale =>
        'The latest reading is stale. Retry sync before relying on it.',
      TrustState.error => 'The latest reading could not be verified.',
      TrustState.critical || TrustState.warning || TrustState.healthy =>
        _lastKnownClassification?.recommendation.message ??
            'Latest field reading is available.',
      TrustState.demo => 'Showing simulated readings for demonstration.',
    };
  }

  @override
  Future<void> close() async {
    _staleCheckTimer?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}

enum DashboardStatus { initial, loading, ready }

class DashboardState {
  const DashboardState({
    required this.status,
    required this.trustState,
    this.deviceCode,
    this.reading,
    this.classification,
    this.lastKnownClassification,
    this.message,
    this.updatedAt,
  });

  const DashboardState.initial()
    : this(status: DashboardStatus.initial, trustState: TrustState.loading);

  const DashboardState.loading({String? deviceCode})
    : this(
        status: DashboardStatus.loading,
        trustState: TrustState.loading,
        deviceCode: deviceCode,
      );

  const DashboardState.ready({
    required TrustState trustState,
    String? deviceCode,
    SensorReading? reading,
    FieldClassification? classification,
    FieldClassification? lastKnownClassification,
    String? message,
    DateTime? updatedAt,
  }) : this(
         status: DashboardStatus.ready,
         trustState: trustState,
         deviceCode: deviceCode,
         reading: reading,
         classification: classification,
         lastKnownClassification: lastKnownClassification,
         message: message,
         updatedAt: updatedAt,
       );

  final DashboardStatus status;
  final TrustState trustState;
  final String? deviceCode;
  final SensorReading? reading;
  final FieldClassification? classification;
  final FieldClassification? lastKnownClassification;
  final String? message;
  final DateTime? updatedAt;

  FieldStatus? get fieldStatus => classification?.fieldStatus;

  SensorCondition? get leadingCondition => classification?.leadingCondition;

  FieldRecommendation? get recommendation => classification?.recommendation;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DashboardState &&
            other.status == status &&
            other.trustState == trustState &&
            other.deviceCode == deviceCode &&
            other.reading == reading &&
            other.classification == classification &&
            other.lastKnownClassification == lastKnownClassification &&
            other.message == message &&
            other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
    status,
    trustState,
    deviceCode,
    reading,
    classification,
    lastKnownClassification,
    message,
    updatedAt,
  );
}

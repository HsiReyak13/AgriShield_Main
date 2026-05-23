import 'package:agrishield/core/models/field_classification.dart';
import 'package:agrishield/core/models/field_recommendation.dart';
import 'package:agrishield/core/models/field_status.dart';
import 'package:agrishield/core/models/field_thresholds.dart';
import 'package:agrishield/core/models/sensor_reading.dart';

class FieldStatusClassifier {
  const FieldStatusClassifier();

  FieldClassification classify(
    SensorReading reading, {
    FieldThresholds thresholds = FieldThresholds.prototypeDefaults,
  }) {
    final conditions = [
      _lowCondition(
        sensorKey: 'soilMoisture',
        displayLabel: 'Soil moisture',
        value: reading.soilMoisture.toDouble(),
        unit: 'raw',
        thresholds: thresholds.soilMoisture,
        concern: 'Soil moisture may need irrigation checks.',
      ),
      _lowCondition(
        sensorKey: 'waterLevel',
        displayLabel: 'Water level',
        value: reading.waterLevel,
        unit: 'cm',
        thresholds: thresholds.waterLevel,
        concern: 'Water level is low for the field setup.',
      ),
      _highCondition(
        sensorKey: 'temperature',
        displayLabel: 'Temperature',
        value: reading.temperature,
        unit: 'C',
        thresholds: thresholds.temperature,
        concern: 'Field temperature is above the monitoring range.',
      ),
      _rangeCondition(
        sensorKey: 'humidity',
        displayLabel: 'Humidity',
        value: reading.humidity,
        unit: '%',
        thresholds: thresholds.humidity,
        concern: 'Humidity is outside the monitoring range.',
      ),
    ];

    final leadingCondition = _leadingCondition(conditions);

    return FieldClassification(
      fieldStatus: leadingCondition.status,
      leadingCondition: leadingCondition,
      conditions: conditions,
      recommendation: _recommendationFor(leadingCondition),
    );
  }

  SensorCondition _lowCondition({
    required String sensorKey,
    required String displayLabel,
    required double value,
    required String unit,
    required LowThresholds thresholds,
    required String concern,
  }) {
    final status = value <= thresholds.criticalLow
        ? FieldStatus.critical
        : value <= thresholds.warningLow
        ? FieldStatus.warning
        : FieldStatus.normal;

    return SensorCondition(
      sensorKey: sensorKey,
      displayLabel: displayLabel,
      status: status,
      value: value,
      unit: unit,
      thresholdContext:
          'Warning at or below ${thresholds.warningLow}, critical at or below ${thresholds.criticalLow}.',
      concern: status == FieldStatus.normal
          ? 'Within monitoring range.'
          : concern,
    );
  }

  SensorCondition _highCondition({
    required String sensorKey,
    required String displayLabel,
    required double value,
    required String unit,
    required HighThresholds thresholds,
    required String concern,
  }) {
    final status = value >= thresholds.criticalHigh
        ? FieldStatus.critical
        : value >= thresholds.warningHigh
        ? FieldStatus.warning
        : FieldStatus.normal;

    return SensorCondition(
      sensorKey: sensorKey,
      displayLabel: displayLabel,
      status: status,
      value: value,
      unit: unit,
      thresholdContext:
          'Warning at or above ${thresholds.warningHigh}, critical at or above ${thresholds.criticalHigh}.',
      concern: status == FieldStatus.normal
          ? 'Within monitoring range.'
          : concern,
    );
  }

  SensorCondition _rangeCondition({
    required String sensorKey,
    required String displayLabel,
    required double value,
    required String unit,
    required RangeThresholds thresholds,
    required String concern,
  }) {
    final status =
        value <= thresholds.criticalLow || value >= thresholds.criticalHigh
        ? FieldStatus.critical
        : value <= thresholds.warningLow || value >= thresholds.warningHigh
        ? FieldStatus.warning
        : FieldStatus.normal;

    return SensorCondition(
      sensorKey: sensorKey,
      displayLabel: displayLabel,
      status: status,
      value: value,
      unit: unit,
      thresholdContext:
          'Warning outside ${thresholds.warningLow}-${thresholds.warningHigh}, critical outside ${thresholds.criticalLow}-${thresholds.criticalHigh}.',
      concern: status == FieldStatus.normal
          ? 'Within monitoring range.'
          : concern,
    );
  }

  SensorCondition _leadingCondition(List<SensorCondition> conditions) {
    final critical = conditions.where(
      (condition) => condition.status == FieldStatus.critical,
    );
    if (critical.isNotEmpty) return critical.first;

    final warning = conditions.where(
      (condition) => condition.status == FieldStatus.warning,
    );
    if (warning.isNotEmpty) return warning.first;

    return conditions.first;
  }

  FieldRecommendation _recommendationFor(SensorCondition leadingCondition) {
    if (leadingCondition.status == FieldStatus.normal) {
      return const FieldRecommendation(
        title: 'Continue monitoring',
        action: 'monitor',
        message: 'Continue to monitor field readings during normal checks.',
      );
    }

    return switch (leadingCondition.sensorKey) {
      'soilMoisture' => const FieldRecommendation(
        title: 'Check soil moisture',
        action: 'check',
        message:
            'Check soil moisture and inspect irrigation if dryness continues.',
      ),
      'waterLevel' => const FieldRecommendation(
        title: 'Check water level',
        action: 'check',
        message:
            'Check water level and monitor the source before the next cycle.',
      ),
      'temperature' => const FieldRecommendation(
        title: 'Inspect field temperature',
        action: 'inspect',
        message: 'Inspect field temperature and monitor for heat stress signs.',
      ),
      'humidity' => const FieldRecommendation(
        title: 'Monitor humidity',
        action: 'monitor',
        message:
            'Monitor humidity and inspect field conditions if it persists.',
      ),
      _ => FieldRecommendation(
        title: 'Check ${leadingCondition.displayLabel.toLowerCase()}',
        action: 'check',
        message: leadingCondition.concern,
      ),
    };
  }
}

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
        actionRecommendation: const FieldRecommendation(
          title: 'Check soil moisture',
          action: 'check',
          message:
              'Check soil moisture and inspect irrigation if dryness continues.',
        ),
      ),
      _lowCondition(
        sensorKey: 'waterLevel',
        displayLabel: 'Water level',
        value: reading.waterLevel,
        unit: 'cm',
        thresholds: thresholds.waterLevel,
        concern: 'Water level is low for the field setup.',
        actionRecommendation: const FieldRecommendation(
          title: 'Check water level',
          action: 'check',
          message:
              'Check water level and monitor the source before the next cycle.',
        ),
      ),
      _highCondition(
        sensorKey: 'temperature',
        displayLabel: 'Temperature',
        value: reading.temperature,
        unit: 'C',
        thresholds: thresholds.temperature,
        concern: 'Field temperature is above the monitoring range.',
        actionRecommendation: const FieldRecommendation(
          title: 'Inspect field temperature',
          action: 'inspect',
          message:
              'Inspect field temperature and monitor for heat stress signs.',
        ),
      ),
      _rangeCondition(
        sensorKey: 'humidity',
        displayLabel: 'Humidity',
        value: reading.humidity,
        unit: '%',
        thresholds: thresholds.humidity,
        concern: 'Humidity is outside the monitoring range.',
        actionRecommendation: const FieldRecommendation(
          title: 'Monitor humidity',
          action: 'monitor',
          message:
              'Monitor humidity and inspect field conditions if it persists.',
        ),
      ),
    ];

    final leadingCondition = _leadingCondition(conditions);

    return FieldClassification(
      fieldStatus: leadingCondition.status,
      leadingCondition: leadingCondition,
      conditions: conditions,
      recommendation: leadingCondition.status == FieldStatus.normal
          ? const FieldRecommendation(
              title: 'Continue monitoring',
              action: 'monitor',
              message:
                  'Continue to monitor field readings during normal checks.',
            )
          : leadingCondition.actionRecommendation,
    );
  }

  SensorCondition _lowCondition({
    required String sensorKey,
    required String displayLabel,
    required double value,
    required String unit,
    required LowThresholds thresholds,
    required String concern,
    required FieldRecommendation actionRecommendation,
  }) {
    if (value.isNaN) {
      return SensorCondition(
        sensorKey: sensorKey,
        displayLabel: displayLabel,
        status: FieldStatus.critical,
        value: value,
        unit: unit,
        thresholdContext: 'Invalid (NaN) reading.',
        concern: concern,
        deviationScore: double.infinity,
        actionRecommendation: actionRecommendation,
      );
    }
    final status = value <= thresholds.criticalLow
        ? FieldStatus.critical
        : value <= thresholds.warningLow
        ? FieldStatus.warning
        : FieldStatus.normal;

    final divisor = thresholds.warningLow - thresholds.criticalLow;
    final deviation = value <= thresholds.warningLow
        ? (divisor == 0 ? 1.0 : (thresholds.warningLow - value) / divisor)
        : 0.0;

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
      deviationScore: deviation,
      actionRecommendation: actionRecommendation,
    );
  }

  SensorCondition _highCondition({
    required String sensorKey,
    required String displayLabel,
    required double value,
    required String unit,
    required HighThresholds thresholds,
    required String concern,
    required FieldRecommendation actionRecommendation,
  }) {
    if (value.isNaN) {
      return SensorCondition(
        sensorKey: sensorKey,
        displayLabel: displayLabel,
        status: FieldStatus.critical,
        value: value,
        unit: unit,
        thresholdContext: 'Invalid (NaN) reading.',
        concern: concern,
        deviationScore: double.infinity,
        actionRecommendation: actionRecommendation,
      );
    }
    final status = value >= thresholds.criticalHigh
        ? FieldStatus.critical
        : value >= thresholds.warningHigh
        ? FieldStatus.warning
        : FieldStatus.normal;

    final divisor = thresholds.criticalHigh - thresholds.warningHigh;
    final deviation = value >= thresholds.warningHigh
        ? (divisor == 0 ? 1.0 : (value - thresholds.warningHigh) / divisor)
        : 0.0;

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
      deviationScore: deviation,
      actionRecommendation: actionRecommendation,
    );
  }

  SensorCondition _rangeCondition({
    required String sensorKey,
    required String displayLabel,
    required double value,
    required String unit,
    required RangeThresholds thresholds,
    required String concern,
    required FieldRecommendation actionRecommendation,
  }) {
    if (value.isNaN) {
      return SensorCondition(
        sensorKey: sensorKey,
        displayLabel: displayLabel,
        status: FieldStatus.critical,
        value: value,
        unit: unit,
        thresholdContext: 'Invalid (NaN) reading.',
        concern: concern,
        deviationScore: double.infinity,
        actionRecommendation: actionRecommendation,
      );
    }
    final status =
        value <= thresholds.criticalLow || value >= thresholds.criticalHigh
        ? FieldStatus.critical
        : value <= thresholds.warningLow || value >= thresholds.warningHigh
        ? FieldStatus.warning
        : FieldStatus.normal;

    double deviation = 0.0;
    if (value <= thresholds.warningLow) {
      final div = thresholds.warningLow - thresholds.criticalLow;
      deviation = div == 0 ? 1.0 : (thresholds.warningLow - value) / div;
    } else if (value >= thresholds.warningHigh) {
      final div = thresholds.criticalHigh - thresholds.warningHigh;
      deviation = div == 0 ? 1.0 : (value - thresholds.warningHigh) / div;
    }

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
      deviationScore: deviation,
      actionRecommendation: actionRecommendation,
    );
  }

  SensorCondition _leadingCondition(List<SensorCondition> conditions) {
    final sorted = List<SensorCondition>.from(conditions);
    sorted.sort((a, b) {
      if (a.status == b.status) {
        return b.deviationScore.compareTo(a.deviationScore);
      }
      if (a.status == FieldStatus.critical) return -1;
      if (b.status == FieldStatus.critical) return 1;
      if (a.status == FieldStatus.warning) return -1;
      if (b.status == FieldStatus.warning) return 1;
      return 0;
    });
    return sorted.first;
  }
}

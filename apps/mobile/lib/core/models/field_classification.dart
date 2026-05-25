import 'package:agrishield/core/models/field_recommendation.dart';
import 'package:agrishield/core/models/field_status.dart';

class SensorCondition {
  const SensorCondition({
    required this.sensorKey,
    required this.displayLabel,
    required this.status,
    required this.value,
    required this.unit,
    required this.thresholdContext,
    required this.concern,
    required this.deviationScore,
    required this.actionRecommendation,
  });

  final String sensorKey;
  final String displayLabel;
  final FieldStatus status;
  final double value;
  final String unit;
  final String thresholdContext;
  final String concern;
  final double deviationScore;
  final FieldRecommendation actionRecommendation;
}

class FieldClassification {
  const FieldClassification({
    required this.fieldStatus,
    required this.leadingCondition,
    required this.conditions,
    required this.recommendation,
  });

  final FieldStatus fieldStatus;
  final SensorCondition leadingCondition;
  final List<SensorCondition> conditions;
  final FieldRecommendation recommendation;

  SensorCondition? conditionFor(String sensorKey) {
    for (final condition in conditions) {
      if (condition.sensorKey == sensorKey) return condition;
    }
    return null;
  }
}

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
  });

  final String sensorKey;
  final String displayLabel;
  final FieldStatus status;
  final double value;
  final String unit;
  final String thresholdContext;
  final String concern;
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

  SensorCondition conditionFor(String sensorKey) {
    return conditions.singleWhere(
      (condition) => condition.sensorKey == sensorKey,
    );
  }
}

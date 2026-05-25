class FieldThresholds {
  const FieldThresholds({
    required this.freshnessThreshold,
    required this.soilMoisture,
    required this.waterLevel,
    required this.temperature,
    required this.humidity,
  });

  static const prototypeDefaults = FieldThresholds(
    freshnessThreshold: Duration(seconds: 300),
    soilMoisture: LowThresholds(criticalLow: 1100, warningLow: 1600),
    waterLevel: LowThresholds(criticalLow: 5, warningLow: 10),
    temperature: HighThresholds(warningHigh: 34, criticalHigh: 38),
    humidity: RangeThresholds(
      criticalLow: 35,
      warningLow: 45,
      warningHigh: 90,
      criticalHigh: 95,
    ),
  );

  final Duration freshnessThreshold;
  final LowThresholds soilMoisture;
  final LowThresholds waterLevel;
  final HighThresholds temperature;
  final RangeThresholds humidity;

  static FieldThresholds fromConfig(Map<String, Object?>? config) {
    if (config == null) return prototypeDefaults;

    final freshnessSeconds = _parseNumber(config['freshnessThresholdSeconds']);
    final thresholdConfig = config['thresholds'];
    final thresholds = thresholdConfig is Map ? thresholdConfig : const {};
    final soilMoisture = LowThresholds.fromConfig(thresholds['soilMoisture']);
    final waterLevel = LowThresholds.fromConfig(thresholds['waterLevel']);
    final temperature = HighThresholds.fromConfig(thresholds['temperature']);
    final humidity = RangeThresholds.fromConfig(thresholds['humidity']);

    return FieldThresholds(
      freshnessThreshold: freshnessSeconds != null
          ? Duration(seconds: freshnessSeconds.round())
          : prototypeDefaults.freshnessThreshold,
      soilMoisture: soilMoisture ?? prototypeDefaults.soilMoisture,
      waterLevel: waterLevel ?? prototypeDefaults.waterLevel,
      temperature: temperature ?? prototypeDefaults.temperature,
      humidity: humidity ?? prototypeDefaults.humidity,
    );
  }

  FieldThresholds copyWith({
    Duration? freshnessThreshold,
    LowThresholds? soilMoisture,
    LowThresholds? waterLevel,
    HighThresholds? temperature,
    RangeThresholds? humidity,
  }) {
    return FieldThresholds(
      freshnessThreshold: freshnessThreshold ?? this.freshnessThreshold,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      waterLevel: waterLevel ?? this.waterLevel,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FieldThresholds &&
        other.freshnessThreshold == freshnessThreshold &&
        other.soilMoisture == soilMoisture &&
        other.waterLevel == waterLevel &&
        other.temperature == temperature &&
        other.humidity == humidity;
  }

  @override
  int get hashCode => Object.hash(
    freshnessThreshold,
    soilMoisture,
    waterLevel,
    temperature,
    humidity,
  );
}

class LowThresholds {
  const LowThresholds({required this.criticalLow, required this.warningLow});

  final double criticalLow;
  final double warningLow;

  static LowThresholds? fromConfig(Object? value) {
    if (value is! Map) return null;

    final criticalLow = _parseNumber(value['criticalLow']);
    final warningLow = _parseNumber(value['warningLow']);
    if (criticalLow == null ||
        warningLow == null ||
        criticalLow >= warningLow) {
      return null;
    }

    return LowThresholds(criticalLow: criticalLow, warningLow: warningLow);
  }

  @override
  bool operator ==(Object other) {
    return other is LowThresholds &&
        other.criticalLow == criticalLow &&
        other.warningLow == warningLow;
  }

  @override
  int get hashCode => Object.hash(criticalLow, warningLow);
}

class HighThresholds {
  const HighThresholds({required this.warningHigh, required this.criticalHigh});

  final double warningHigh;
  final double criticalHigh;

  static HighThresholds? fromConfig(Object? value) {
    if (value is! Map) return null;

    final warningHigh = _parseNumber(value['warningHigh']);
    final criticalHigh = _parseNumber(value['criticalHigh']);
    if (warningHigh == null ||
        criticalHigh == null ||
        warningHigh >= criticalHigh) {
      return null;
    }

    return HighThresholds(warningHigh: warningHigh, criticalHigh: criticalHigh);
  }

  @override
  bool operator ==(Object other) {
    return other is HighThresholds &&
        other.warningHigh == warningHigh &&
        other.criticalHigh == criticalHigh;
  }

  @override
  int get hashCode => Object.hash(warningHigh, criticalHigh);
}

class RangeThresholds {
  const RangeThresholds({
    required this.criticalLow,
    required this.warningLow,
    required this.warningHigh,
    required this.criticalHigh,
  });

  final double criticalLow;
  final double warningLow;
  final double warningHigh;
  final double criticalHigh;

  static RangeThresholds? fromConfig(Object? value) {
    if (value is! Map) return null;

    final criticalLow = _parseNumber(value['criticalLow']);
    final warningLow = _parseNumber(value['warningLow']);
    final warningHigh = _parseNumber(value['warningHigh']);
    final criticalHigh = _parseNumber(value['criticalHigh']);
    if (criticalLow == null ||
        warningLow == null ||
        warningHigh == null ||
        criticalHigh == null ||
        criticalLow >= warningLow ||
        warningLow >= warningHigh ||
        warningHigh >= criticalHigh) {
      return null;
    }

    return RangeThresholds(
      criticalLow: criticalLow,
      warningLow: warningLow,
      warningHigh: warningHigh,
      criticalHigh: criticalHigh,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RangeThresholds &&
        other.criticalLow == criticalLow &&
        other.warningLow == warningLow &&
        other.warningHigh == warningHigh &&
        other.criticalHigh == criticalHigh;
  }

  @override
  int get hashCode =>
      Object.hash(criticalLow, warningLow, warningHigh, criticalHigh);
}

double? _parseNumber(Object? value) {
  if (value is num && value.isFinite) return value.toDouble();
  return null;
}

import 'package:flutter/material.dart';

@immutable
class AgriFieldTokens extends ThemeExtension<AgriFieldTokens> {
  const AgriFieldTokens({
    required this.statusOkay,
    required this.statusNeedsAttention,
    required this.statusCritical,
    required this.confidenceRecent,
    required this.confidenceDelayed,
    required this.confidenceStale,
    required this.confidenceNoConnection,
    required this.surfaceAppBackground,
    required this.surfaceCard,
    required this.surfaceStatusCard,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHelper,
    required this.borderSubtle,
    required this.stateDisabled,
  });

  final Color statusOkay;
  final Color statusNeedsAttention;
  final Color statusCritical;
  final Color confidenceRecent;
  final Color confidenceDelayed;
  final Color confidenceStale;
  final Color confidenceNoConnection;
  final Color surfaceAppBackground;
  final Color surfaceCard;
  final Color surfaceStatusCard;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHelper;
  final Color borderSubtle;
  final Color stateDisabled;

  static const light = AgriFieldTokens(
    statusOkay: Color(0xFF34C759),
    statusNeedsAttention: Color(0xFFFF9500),
    statusCritical: Color(0xFFFF3B30),
    confidenceRecent: Color(0xFF218A44),
    confidenceDelayed: Color(0xFFFFB020),
    confidenceStale: Color(0xFFFF9500),
    confidenceNoConnection: Color(0xFFD92D20),
    surfaceAppBackground: Color(0xFFF4F8F1),
    surfaceCard: Color(0xFFFFFFFF),
    surfaceStatusCard: Color(0xFFE4F8EA),
    textPrimary: Color(0xFF0B1014),
    textSecondary: Color(0xFF697386),
    textHelper: Color(0xFF7C8798),
    borderSubtle: Color(0xFFE4E8E2),
    stateDisabled: Color(0xFFC9D1C8),
  );

  @override
  AgriFieldTokens copyWith({
    Color? statusOkay,
    Color? statusNeedsAttention,
    Color? statusCritical,
    Color? confidenceRecent,
    Color? confidenceDelayed,
    Color? confidenceStale,
    Color? confidenceNoConnection,
    Color? surfaceAppBackground,
    Color? surfaceCard,
    Color? surfaceStatusCard,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHelper,
    Color? borderSubtle,
    Color? stateDisabled,
  }) {
    return AgriFieldTokens(
      statusOkay: statusOkay ?? this.statusOkay,
      statusNeedsAttention: statusNeedsAttention ?? this.statusNeedsAttention,
      statusCritical: statusCritical ?? this.statusCritical,
      confidenceRecent: confidenceRecent ?? this.confidenceRecent,
      confidenceDelayed: confidenceDelayed ?? this.confidenceDelayed,
      confidenceStale: confidenceStale ?? this.confidenceStale,
      confidenceNoConnection:
          confidenceNoConnection ?? this.confidenceNoConnection,
      surfaceAppBackground: surfaceAppBackground ?? this.surfaceAppBackground,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceStatusCard: surfaceStatusCard ?? this.surfaceStatusCard,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHelper: textHelper ?? this.textHelper,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      stateDisabled: stateDisabled ?? this.stateDisabled,
    );
  }

  @override
  AgriFieldTokens lerp(ThemeExtension<AgriFieldTokens>? other, double t) {
    if (other is! AgriFieldTokens) {
      return this;
    }

    return AgriFieldTokens(
      statusOkay: Color.lerp(statusOkay, other.statusOkay, t)!,
      statusNeedsAttention: Color.lerp(
        statusNeedsAttention,
        other.statusNeedsAttention,
        t,
      )!,
      statusCritical: Color.lerp(statusCritical, other.statusCritical, t)!,
      confidenceRecent: Color.lerp(
        confidenceRecent,
        other.confidenceRecent,
        t,
      )!,
      confidenceDelayed: Color.lerp(
        confidenceDelayed,
        other.confidenceDelayed,
        t,
      )!,
      confidenceStale: Color.lerp(confidenceStale, other.confidenceStale, t)!,
      confidenceNoConnection: Color.lerp(
        confidenceNoConnection,
        other.confidenceNoConnection,
        t,
      )!,
      surfaceAppBackground: Color.lerp(
        surfaceAppBackground,
        other.surfaceAppBackground,
        t,
      )!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceStatusCard: Color.lerp(
        surfaceStatusCard,
        other.surfaceStatusCard,
        t,
      )!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHelper: Color.lerp(textHelper, other.textHelper, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      stateDisabled: Color.lerp(stateDisabled, other.stateDisabled, t)!,
    );
  }
}

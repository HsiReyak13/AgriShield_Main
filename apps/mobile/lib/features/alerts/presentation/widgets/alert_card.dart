import 'package:agrishield/app/theme/agri_tokens.dart';
import 'package:agrishield/core/models/alert.dart';
import 'package:agrishield/core/models/field_status.dart';
import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget {
  const AlertCard({super.key, required this.alert, this.onTap});

  final Alert alert;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AgriFieldTokens>() ?? AgriFieldTokens.light;

    final Color severityColor;
    final String severityText;

    switch (alert.severity) {
      case FieldStatus.critical:
        severityColor = tokens.statusCritical;
        severityText = 'Critical';
        break;
      case FieldStatus.warning:
        severityColor = tokens.statusNeedsAttention;
        severityText = 'Warning';
        break;
      case FieldStatus.normal:
        severityColor = tokens.statusOkay;
        severityText = 'Normal';
        break;
    }

    return Card(
      color: tokens.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: tokens.borderSubtle),
      ),
      elevation: 0,
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: severityColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      severityText,
                      style: TextStyle(
                        color: severityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    _formatRelativeTime(alert.createdAt),
                    style: TextStyle(color: tokens.textHelper, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                alert.sensor,
                style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                alert.thresholdMessage,
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: tokens.textHelper),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      alert.recommendation,
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime time) {
    final now = DateTime.now();
    if (time.isAfter(now.add(const Duration(minutes: 1)))) {
      return 'Time syncing';
    }

    final diff = now.difference(time);
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hr ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }
}

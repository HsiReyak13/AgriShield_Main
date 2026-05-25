import 'package:agrishield/features/alerts/application/alerts_state.dart';
import 'package:flutter/material.dart';

class AlertFilterPills extends StatelessWidget {
  const AlertFilterPills({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final AlertFilter selectedFilter;
  final ValueChanged<AlertFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: AlertFilter.values.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(_getLabelForFilter(filter)),
              selected: selectedFilter == filter,
              onSelected: (selected) {
                if (selected) {
                  onFilterSelected(filter);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getLabelForFilter(AlertFilter filter) {
    switch (filter) {
      case AlertFilter.all:
        return 'All';
      case AlertFilter.critical:
        return 'Critical';
      case AlertFilter.warning:
        return 'Warning';
      case AlertFilter.normal:
        return 'Normal';
      case AlertFilter.active:
        return 'Active';
      case AlertFilter.resolved:
        return 'Resolved';
    }
  }
}

import 'package:agrishield/features/dashboard/view/prototype_screens.dart'
    as prototype;
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return prototype.PageFrame(
      title: 'History',
      subtitle: 'Past readings from this field',
      children: prototype.MockAgriData.readings
          .map(
            (reading) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: prototype.HistoryReadingCard(reading: reading),
            ),
          )
          .toList(),
    );
  }
}

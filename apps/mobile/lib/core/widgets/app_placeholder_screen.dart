import 'package:agrishield/app/theme/agri_theme.dart';
import 'package:flutter/material.dart';

class AppPlaceholderScreen extends StatelessWidget {
  const AppPlaceholderScreen({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 12),
              Text(message, style: Theme.of(context).textTheme.bodyLarge),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AgriTheme.deepGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final String category;

  const EmptyStateWidget({super.key, this.category = 'All'});

  @override
  Widget build(BuildContext context) {
    final isFiltered = category != 'All';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing visual container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.indigo.withOpacity(0.1),
                border: Border.all(
                  color: AppTheme.indigo.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.indigo.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                '✨',
                style: TextStyle(fontSize: 48),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isFiltered
                  ? 'No $category routines'
                  : 'Start your DailyFlow',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'No active routines found under this category. Tap + to add one!'
                  : 'Your daily routine list is empty. Add your first habit and build consistent momentum!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

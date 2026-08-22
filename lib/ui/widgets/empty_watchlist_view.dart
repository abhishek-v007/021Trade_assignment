import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EmptyWatchlistView extends StatelessWidget {
  final VoidCallback? onAddStocks;

  const EmptyWatchlistView({super.key, this.onAddStocks});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                color: AppTheme.accent,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No stocks in this watchlist',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add from the 10 available stocks to start tracking',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            if (onAddStocks != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAddStocks,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add stocks'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

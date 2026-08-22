import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'live_price_cell.dart';

/// Watchlist row keyed by [symbol]. Listens only to that symbol's notifier so
/// ticks never paint the wrong row after reorder.
class LiveWatchlistTile extends StatelessWidget {
  final String symbol;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const LiveWatchlistTile({
    super.key,
    required this.symbol,
    required this.index,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('dismiss_$symbol'),
      direction: DismissDirection.endToStart,
      background: const _DismissBackground(),
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        return true;
      },
      onDismissed: (_) => onRemove(),
      child: LivePriceCell(
        symbol: symbol,
        onTap: onTap,
        leading: ReorderableDragStartListener(
          index: index,
          child: const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(
              Icons.drag_indicator_rounded,
              color: AppTheme.textMuted,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.lossRed.withValues(alpha: 0.15),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline_rounded,
            color: AppTheme.lossRed,
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            'Remove',
            style: TextStyle(
              color: AppTheme.lossRed,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

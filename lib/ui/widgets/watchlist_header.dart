import 'package:flutter/material.dart';

import '../../data/models/watchlist.dart';
import '../theme/app_theme.dart';

class WatchlistHeader extends StatelessWidget {
  final Watchlist watchlist;

  const WatchlistHeader({super.key, required this.watchlist});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Text(
            '${watchlist.symbols.length}',
            style: const TextStyle(
              color: AppTheme.accent,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            watchlist.symbols.length == 1 ? 'stock' : 'stocks',
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.swap_vert_rounded,
            color: AppTheme.textMuted,
            size: 18,
          ),
          const SizedBox(width: 6),
          const Text(
            'Drag to reorder · Tap to trade',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

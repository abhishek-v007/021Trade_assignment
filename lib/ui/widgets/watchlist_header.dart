import 'package:flutter/material.dart';
import '../../data/models/watchlist.dart';
import '../../data/models/stock.dart';
import '../theme/app_theme.dart';

class WatchlistHeader extends StatelessWidget {
  final Watchlist watchlist;

  const WatchlistHeader({super.key, required this.watchlist});

  int get _gainers =>
      watchlist.stocks.where((s) => s.trend == StockTrend.up).length;

  int get _losers =>
      watchlist.stocks.where((s) => s.trend == StockTrend.down).length;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2D45), Color(0xFF162035)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          _StatChip(
            label: 'Stocks',
            value: '${watchlist.stocks.length}',
            color: AppTheme.accent,
          ),
          const SizedBox(width: 12),
          _StatChip(
            label: 'Gainers',
            value: '$_gainers',
            color: AppTheme.gainGreen,
          ),
          const SizedBox(width: 12),
          _StatChip(
            label: 'Losers',
            value: '$_losers',
            color: AppTheme.lossRed,
          ),
          const Spacer(),
          const Icon(
            Icons.swap_vert_rounded,
            color: AppTheme.textMuted,
            size: 18,
          ),
          const SizedBox(width: 6),
          const Text(
            'Drag to reorder',
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

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

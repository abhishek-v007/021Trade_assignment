import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models/stock.dart';
import '../theme/app_theme.dart';
import 'stock_avatar.dart';
import 'price_change_badge.dart';

class StockListTile extends StatelessWidget {
  final Stock stock;
  final int index;
  final bool isDragging;
  final VoidCallback? onRemove;

  const StockListTile({
    super.key,
    required this.stock,
    required this.index,
    this.isDragging = false,
    this.onRemove,
  });

  Color get _priceColor {
    return switch (stock.trend) {
      StockTrend.up => AppTheme.gainGreen,
      StockTrend.down => AppTheme.lossRed,
      StockTrend.neutral => AppTheme.neutralColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDragging ? AppTheme.cardHover : AppTheme.cardDark,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.dividerColor,
            width: 1,
          ),
        ),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: AppTheme.accent.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.drag_indicator_rounded,
                color: AppTheme.textMuted,
                size: 20,
              ),
            ),
          ),

          StockAvatar(symbol: stock.symbol),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stock.symbol,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  stock.companyName,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                stock.formattedPrice,
                style: TextStyle(
                  color: _priceColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              PriceChangeBadge(stock: stock),
            ],
          ),
        ],
      ),
    );
  }
}

class DismissibleStockTile extends StatelessWidget {
  final Stock stock;
  final int index;
  final bool isDragging;
  final VoidCallback onRemove;

  const DismissibleStockTile({
    super.key,
    required this.stock,
    required this.index,
    required this.onRemove,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(stock.id),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        return true;
      },
      onDismissed: (_) => onRemove(),
      child: StockListTile(
        stock: stock,
        index: index,
        isDragging: isDragging,
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      color: AppTheme.lossRed.withOpacity(0.15),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.delete_outline_rounded,
            color: AppTheme.lossRed,
            size: 24,
          ),
          const SizedBox(height: 4),
          const Text(
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

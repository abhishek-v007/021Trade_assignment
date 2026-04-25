import 'package:flutter/material.dart';
import '../../data/models/stock.dart';
import '../theme/app_theme.dart';

class PriceChangeBadge extends StatelessWidget {
  final Stock stock;
  final bool showAmount;

  const PriceChangeBadge({
    super.key,
    required this.stock,
    this.showAmount = false,
  });

  Color get _backgroundColor {
    return switch (stock.trend) {
      StockTrend.up => AppTheme.gainGreenBg,
      StockTrend.down => AppTheme.lossRedBg,
      StockTrend.neutral => AppTheme.neutralBg,
    };
  }

  Color get _textColor {
    return switch (stock.trend) {
      StockTrend.up => AppTheme.gainGreen,
      StockTrend.down => AppTheme.lossRed,
      StockTrend.neutral => AppTheme.neutralColor,
    };
  }

  IconData get _icon {
    return switch (stock.trend) {
      StockTrend.up => Icons.arrow_drop_up_rounded,
      StockTrend.down => Icons.arrow_drop_down_rounded,
      StockTrend.neutral => Icons.remove,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: _textColor, size: 16),
          const SizedBox(width: 2),
          Text(
            showAmount
                ? stock.formattedChangePercent
                : stock.formattedChangePercent,
            style: TextStyle(
              color: _textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

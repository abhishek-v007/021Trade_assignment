import 'package:flutter/material.dart';

import '../../data/models/stock_quote.dart';
import '../theme/app_theme.dart';

class PriceChangeBadge extends StatelessWidget {
  final StockQuote quote;

  const PriceChangeBadge({
    super.key,
    required this.quote,
  });

  Color get _backgroundColor {
    return switch (quote.direction) {
      PriceDirection.up => AppTheme.gainGreenBg,
      PriceDirection.down => AppTheme.lossRedBg,
      PriceDirection.flat => AppTheme.neutralBg,
    };
  }

  Color get _textColor {
    return switch (quote.direction) {
      PriceDirection.up => AppTheme.gainGreen,
      PriceDirection.down => AppTheme.lossRed,
      PriceDirection.flat => AppTheme.neutralColor,
    };
  }

  IconData get _icon {
    return switch (quote.direction) {
      PriceDirection.up => Icons.arrow_drop_up_rounded,
      PriceDirection.down => Icons.arrow_drop_down_rounded,
      PriceDirection.flat => Icons.remove,
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
            quote.formattedChangePercent,
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

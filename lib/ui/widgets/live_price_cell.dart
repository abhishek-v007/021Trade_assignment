import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/stock_universe.dart';
import '../../data/market/market_data_feed.dart';
import '../../data/models/stock_quote.dart';
import '../theme/app_theme.dart';
import 'price_change_badge.dart';
import 'stock_avatar.dart';

/// Single-symbol live cell. Rebuilds only when **this** symbol ticks.
class LivePriceCell extends StatelessWidget {
  final String symbol;
  final VoidCallback? onTap;
  final bool dense;
  final Widget? leading;

  const LivePriceCell({
    super.key,
    required this.symbol,
    this.onTap,
    this.dense = false,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final feed = context.read<MarketDataFeed>();
    return ValueListenableBuilder<StockQuote>(
      valueListenable: feed.listenable(symbol),
      builder: (context, quote, _) {
        return _FlashingQuoteRow(
          quote: quote,
          onTap: onTap,
          dense: dense,
          leading: leading,
        );
      },
    );
  }
}

class _FlashingQuoteRow extends StatefulWidget {
  final StockQuote quote;
  final VoidCallback? onTap;
  final bool dense;
  final Widget? leading;

  const _FlashingQuoteRow({
    required this.quote,
    this.onTap,
    this.dense = false,
    this.leading,
  });

  @override
  State<_FlashingQuoteRow> createState() => _FlashingQuoteRowState();
}

class _FlashingQuoteRowState extends State<_FlashingQuoteRow> {
  Color? _flash;
  int _flashGen = 0;

  @override
  void didUpdateWidget(covariant _FlashingQuoteRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldPaise = oldWidget.quote.ltp.paise;
    final newPaise = widget.quote.ltp.paise;
    if (oldPaise == newPaise) return;

    // Flash follows the **tick** direction, not day change vs previous close.
    final Color flash;
    if (newPaise > oldPaise) {
      flash = AppTheme.gainGreen.withValues(alpha: 0.2);
    } else {
      flash = AppTheme.lossRed.withValues(alpha: 0.2);
    }

    final gen = ++_flashGen;
    setState(() => _flash = flash);
    Future<void>.delayed(const Duration(milliseconds: 220), () {
      if (mounted && _flashGen == gen) {
        setState(() => _flash = null);
      }
    });
  }

  Color get _priceColor {
    return switch (widget.quote.direction) {
      PriceDirection.up => AppTheme.gainGreen,
      PriceDirection.down => AppTheme.lossRed,
      PriceDirection.flat => AppTheme.textPrimary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final quote = widget.quote;
    final company = StockUniverse.companyName(quote.symbol);
    final padV = widget.dense ? 12.0 : 14.0;

    return Material(
      color: _flash ?? AppTheme.cardDark,
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: padV),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppTheme.dividerColor),
            ),
          ),
          child: Row(
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: 4),
              ],
              StockAvatar(symbol: quote.symbol, size: widget.dense ? 40 : 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      quote.symbol,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      company,
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
                    quote.ltp.formatted,
                    style: TextStyle(
                      color: _priceColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        quote.change.formattedSigned,
                        style: TextStyle(
                          color: _priceColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      PriceChangeBadge(quote: quote),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

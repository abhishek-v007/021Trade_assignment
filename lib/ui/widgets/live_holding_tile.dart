import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/money.dart';
import '../../data/market/market_data_feed.dart';
import '../../data/models/holding.dart';
import '../../data/models/stock_quote.dart';
import '../../data/portfolio/holding_metrics.dart';
import '../theme/app_theme.dart';
import 'stock_avatar.dart';

/// One holding row. Rebuilds only when **this** symbol's quote ticks.
class LiveHoldingTile extends StatelessWidget {
  final Holding holding;
  final VoidCallback onTap;

  const LiveHoldingTile({
    super.key,
    required this.holding,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final feed = context.read<MarketDataFeed>();

    return ValueListenableBuilder<StockQuote>(
      valueListenable: feed.listenable(holding.symbol),
      builder: (context, quote, _) {
        final metrics = HoldingMetrics(holding: holding, ltp: quote.ltp);
        return _HoldingRow(metrics: metrics, onTap: onTap);
      },
    );
  }
}

class _HoldingRow extends StatelessWidget {
  final HoldingMetrics metrics;
  final VoidCallback onTap;

  const _HoldingRow({required this.metrics, required this.onTap});

  Color get _pnlColor {
    if (metrics.pnl.isPositive) return AppTheme.gainGreen;
    if (metrics.pnl.isNegative) return AppTheme.lossRed;
    return AppTheme.neutralColor;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cardDark,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppTheme.dividerColor),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StockAvatar(symbol: metrics.symbol, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metrics.symbol,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty ${metrics.quantity} · Avg ${metrics.avgCost.formatted}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'LTP ${metrics.ltp.formatted}',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    metrics.currentValue.formatted,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    metrics.pnl.formattedSigned,
                    style: TextStyle(
                      color: _pnlColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    metrics.formattedPnlPercent,
                    style: TextStyle(
                      color: _pnlColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
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

/// Aggregate header — listens to every held symbol so totals stay in sync
/// with individual rows at any tick.
class LiveHoldingsSummary extends StatelessWidget {
  final List<Holding> holdings;
  final Money cashBalance;

  const LiveHoldingsSummary({
    super.key,
    required this.holdings,
    required this.cashBalance,
  });

  @override
  Widget build(BuildContext context) {
    final feed = context.read<MarketDataFeed>();
    final listenables = [
      for (final h in holdings) feed.listenable(h.symbol),
    ];

    return AnimatedBuilder(
      animation: Listenable.merge(listenables),
      builder: (context, _) {
        final metrics = PortfolioMetrics.fromHoldings(
          holdings: holdings,
          ltpOf: (s) => feed.quote(s).ltp,
        );
        final pnlColor = metrics.totalPnl.isPositive
            ? AppTheme.gainGreen
            : metrics.totalPnl.isNegative
                ? AppTheme.lossRed
                : AppTheme.neutralColor;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Portfolio',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Cash ${cashBalance.formatted}',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      label: 'Invested',
                      value: metrics.totalInvested.formatted,
                    ),
                  ),
                  Expanded(
                    child: _Metric(
                      label: 'Current',
                      value: metrics.currentValue.formatted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total P&L',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          metrics.totalPnl.formattedSigned,
                          style: TextStyle(
                            color: pnlColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: pnlColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      metrics.formattedPnlPercent,
                      style: TextStyle(
                        color: pnlColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/stock_universe.dart';
import '../../data/market/market_data_feed.dart';
import '../theme/app_theme.dart';
import '../widgets/live_price_cell.dart';
import 'trade_ticket_screen.dart';

/// Market overview: all 10 stocks, live from [MarketDataFeed].
class LivePricesScreen extends StatelessWidget {
  const LivePricesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final feed = context.read<MarketDataFeed>();

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Prices',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            ValueListenableBuilder<MarketFeedConfig>(
              valueListenable: feed.configListenable,
              builder: (context, config, _) {
                return Text(
                  '${config.label} · ~${config.overallTicksPerSecond.toStringAsFixed(0)} ticks/sec',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Tick rate',
            icon: const Icon(Icons.speed_rounded, color: AppTheme.textSecondary),
            onPressed: () => _showTickRateSheet(context),
          ),
          const SizedBox(width: 4),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.dividerColor),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _TickRateChips(),
          const _ColumnHeaders(),
          Expanded(
            child: ListView.builder(
              // Keep off-screen rows alive briefly so scroll + ticks stay smooth.
              itemCount: StockUniverse.all.length,
              itemBuilder: (context, index) {
                final symbol = StockUniverse.all[index].symbol;
                return LivePriceCell(
                  key: ValueKey(symbol),
                  symbol: symbol,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => TradeTicketScreen(symbol: symbol),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ColumnHeaders extends StatelessWidget {
  const _ColumnHeaders();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'SYMBOL',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Text(
            'LTP / CHANGE',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _TickRateChips extends StatelessWidget {
  const _TickRateChips();

  @override
  Widget build(BuildContext context) {
    final feed = context.read<MarketDataFeed>();

    return ValueListenableBuilder<MarketFeedConfig>(
      valueListenable: feed.configListenable,
      builder: (context, current, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              for (final preset in MarketFeedConfig.presets) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      '${preset.label} (${preset.overallTicksPerSecond.round()}/s)',
                    ),
                    selected: current == preset,
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      feed.updateConfig(preset);
                    },
                    selectedColor: AppTheme.accent.withValues(alpha: 0.25),
                    backgroundColor: AppTheme.cardDark,
                    labelStyle: TextStyle(
                      color: current == preset
                          ? AppTheme.accentLight
                          : AppTheme.textSecondary,
                      fontWeight:
                          current == preset ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: current == preset
                          ? AppTheme.accent
                          : AppTheme.borderColor,
                    ),
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

Future<void> _showTickRateSheet(BuildContext context) async {
  final feed = context.read<MarketDataFeed>();

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppTheme.surfaceDark,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: ValueListenableBuilder<MarketFeedConfig>(
          valueListenable: feed.configListenable,
          builder: (context, current, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    'Mock feed tick rate',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    'Debug setting — same feed powers Watchlist, Live Prices, and Trade.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                for (final preset in MarketFeedConfig.presets)
                  ListTile(
                    title: Text(preset.label),
                    subtitle: Text(
                      '${preset.ticksPerSecondPerStock}/s per stock · '
                      '~${preset.overallTicksPerSecond.round()} ticks/s overall',
                    ),
                    trailing: current == preset
                        ? const Icon(Icons.check_rounded, color: AppTheme.accent)
                        : null,
                    onTap: () {
                      feed.updateConfig(preset);
                      Navigator.pop(sheetContext);
                    },
                  ),
                const SizedBox(height: 8),
              ],
            );
          },
        ),
      );
    },
  );
}

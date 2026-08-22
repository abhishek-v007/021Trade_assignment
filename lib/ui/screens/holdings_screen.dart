import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/portfolio/portfolio_bloc.dart';
import '../../core/money.dart';
import '../../data/market/market_data_feed.dart';
import '../../data/models/holding.dart';
import '../../data/portfolio/holding_metrics.dart';
import '../theme/app_theme.dart';
import '../widgets/error_view.dart';
import '../widgets/live_holding_tile.dart';
import 'trade_ticket_screen.dart';

class HoldingsScreen extends StatelessWidget {
  const HoldingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Holdings',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Live P&L',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.dividerColor),
        ),
      ),
      body: BlocBuilder<PortfolioBloc, PortfolioState>(
        builder: (context, state) {
          return switch (state) {
            PortfolioInitial() || PortfolioLoading() => const Center(
                child: CircularProgressIndicator(color: AppTheme.accent),
              ),
            PortfolioError(:final message) => ErrorView(
                message: message,
                onRetry: () => context
                    .read<PortfolioBloc>()
                    .add(const PortfolioLoadRequested()),
              ),
            PortfolioReady(:final portfolio) => portfolio.holdings.isEmpty
                ? const _EmptyHoldings()
                : _HoldingsBody(
                    holdings: portfolio.holdings,
                    cashBalance: portfolio.cashBalance,
                  ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _HoldingsBody extends StatefulWidget {
  final List<Holding> holdings;
  final Money cashBalance;

  const _HoldingsBody({
    required this.holdings,
    required this.cashBalance,
  });

  @override
  State<_HoldingsBody> createState() => _HoldingsBodyState();
}

class _HoldingsBodyState extends State<_HoldingsBody> {
  HoldingsSortBy _sortBy = HoldingsSortBy.pnlDesc;

  List<Holding> _sorted(MarketDataFeed feed) {
    return sortHoldings(
      holdings: widget.holdings,
      ltpOf: (s) => feed.quote(s).ltp,
      sortBy: _sortBy,
    );
  }

  Widget _list(List<Holding> sorted) {
    return ListView.builder(
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final holding = sorted[index];
        return LiveHoldingTile(
          key: ValueKey(holding.symbol),
          holding: holding,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TradeTicketScreen(symbol: holding.symbol),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.read<MarketDataFeed>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LiveHoldingsSummary(
          holdings: widget.holdings,
          cashBalance: widget.cashBalance,
        ),
        _SortBar(
          sortBy: _sortBy,
          onChanged: (s) {
            HapticFeedback.selectionClick();
            setState(() => _sortBy = s);
          },
        ),
        Expanded(
          child: _sortBy == HoldingsSortBy.symbolAsc
              // Symbol order is static — only each row rebuilds on its tick.
              ? _list(_sorted(feed))
              // P&L / value sorts re-order as prices cross.
              : AnimatedBuilder(
                  animation: Listenable.merge([
                    for (final h in widget.holdings) feed.listenable(h.symbol),
                  ]),
                  builder: (context, _) => _list(_sorted(feed)),
                ),
        ),
      ],
    );
  }
}

class _SortBar extends StatelessWidget {
  final HoldingsSortBy sortBy;
  final ValueChanged<HoldingsSortBy> onChanged;

  const _SortBar({required this.sortBy, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          const Text(
            'Sort',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          for (final option in HoldingsSortBy.values) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  option == HoldingsSortBy.pnlDesc
                      ? 'P&L ↓'
                      : option.label,
                ),
                selected: sortBy == option,
                onSelected: (_) => onChanged(option),
                selectedColor: AppTheme.accent.withValues(alpha: 0.25),
                backgroundColor: AppTheme.cardDark,
                labelStyle: TextStyle(
                  color: sortBy == option
                      ? AppTheme.accentLight
                      : AppTheme.textSecondary,
                  fontWeight:
                      sortBy == option ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 12,
                ),
                side: BorderSide(
                  color: sortBy == option
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
  }
}

class _EmptyHoldings extends StatelessWidget {
  const _EmptyHoldings();

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
                Icons.account_balance_wallet_outlined,
                color: AppTheme.accent,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No holdings yet',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Place a Buy order from Watchlist or Live Prices\nto build your portfolio.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'holdings_screen.dart';
import 'live_prices_screen.dart';
import 'watchlist_screen.dart';

/// Root shell with bottom navigation. Uses [IndexedStack] so leaving a tab
/// does not tear down listeners; the app-level feed keeps quotes fresh.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: IndexedStack(
        index: _index,
        children: const [
          WatchlistScreen(),
          LivePricesScreen(),
          HoldingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppTheme.surfaceDark,
        indicatorColor: AppTheme.accent.withValues(alpha: 0.2),
        surfaceTintColor: Colors.transparent,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bookmark_border_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded),
            label: 'Watchlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_rounded),
            selectedIcon: Icon(Icons.show_chart_rounded),
            label: 'Live Prices',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Holdings',
          ),
        ],
      ),
    );
  }
}

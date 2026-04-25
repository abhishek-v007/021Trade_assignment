import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/watchlist/watchlist_bloc.dart';
import '../../data/models/stock.dart';
import '../theme/app_theme.dart';
import '../widgets/dismissible_stock_tile.dart';
import '../widgets/empty_watchlist_view.dart';
import '../widgets/error_view.dart';
import '../widgets/watchlist_header.dart';
import '../widgets/stock_list_tile.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: _buildAppBar(context),
      body: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          return switch (state) {
            WatchlistInitial() => const SizedBox.shrink(),
            WatchlistLoading() => _buildLoadingView(),
            WatchlistLoaded() => _buildLoadedView(context, state),
            WatchlistError(:final message) => ErrorView(
                message: message,
                onRetry: () => context.read<WatchlistBloc>().add(
                      const WatchlistLoadRequested(),
                    ),
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryDark,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.gainGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '021 Trade',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const Text(
            'My Watchlist',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        BlocBuilder<WatchlistBloc, WatchlistState>(
          builder: (context, state) {
            return IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
              onPressed: state is WatchlistLoading
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      context.read<WatchlistBloc>().add(
                            const WatchlistRefreshRequested(),
                          );
                    },
              tooltip: 'Refresh',
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
          onPressed: () {},
          tooltip: 'Search',
        ),
        const SizedBox(width: 4),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppTheme.dividerColor),
      ),
    );
  }

  Widget _buildLoadingView() {
    return ListView.builder(
      itemCount: 8,
      padding: const EdgeInsets.only(top: 8),
      itemBuilder: (_, index) => _ShimmerTile(index: index),
    );
  }

  Widget _buildLoadedView(BuildContext context, WatchlistLoaded state) {
    final watchlist = state.watchlist;

    if (watchlist.stocks.isEmpty) {
      return const EmptyWatchlistView();
    }

    return Column(
      children: [
        WatchlistHeader(watchlist: watchlist),
        Expanded(
          child: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            itemCount: watchlist.stocks.length,
            onReorder: (oldIndex, newIndex) {
              HapticFeedback.mediumImpact();
              context.read<WatchlistBloc>().add(
                    WatchlistStockReordered(
                      oldIndex: oldIndex,
                      newIndex: newIndex,
                    ),
                  );
            },
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (_, __) {
                  final elevation = Tween<double>(begin: 0, end: 8)
                      .animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        ),
                      )
                      .value;
                  return Material(
                    elevation: elevation,
                    color: Colors.transparent,
                    shadowColor: AppTheme.accent.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(0),
                    child: child,
                  );
                },
                child: child,
              );
            },
            itemBuilder: (context, index) {
              final stock = watchlist.stocks[index];
              return _buildStockTile(context, stock, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStockTile(BuildContext context, Stock stock, int index) {
    return DismissibleStockTile(
      key: ValueKey(stock.id),
      stock: stock,
      index: index,
      onRemove: () {
        context.read<WatchlistBloc>().add(
              WatchlistStockRemoved(stockId: stock.id),
            );
        _showRemovedSnackbar(context, stock);
      },
    );
  }

  void _showRemovedSnackbar(BuildContext context, Stock stock) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${stock.symbol} removed from watchlist',
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          backgroundColor: AppTheme.cardDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppTheme.borderColor),
          ),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: AppTheme.accent,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
  }
}

class _ShimmerTile extends StatefulWidget {
  final int index;
  const _ShimmerTile({required this.index});

  @override
  State<_ShimmerTile> createState() => _ShimmerTileState();
}

class _ShimmerTileState extends State<_ShimmerTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, __) {
        return Opacity(
          opacity: _opacity.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.dividerColor),
              ),
            ),
            child: Row(
              children: [
                _shimmerBox(20, 20, radius: 4),
                const SizedBox(width: 12),
                _shimmerBox(44, 44, radius: 10),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(14, 90, radius: 4),
                      const SizedBox(height: 6),
                      _shimmerBox(11, 140, radius: 4),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _shimmerBox(15, 80, radius: 4),
                    const SizedBox(height: 6),
                    _shimmerBox(22, 60, radius: 6),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _shimmerBox(double height, double width, {double radius = 4}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

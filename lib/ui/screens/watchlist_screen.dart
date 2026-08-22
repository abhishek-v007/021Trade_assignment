import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/watchlist/watchlist_bloc.dart';
import '../../data/models/watchlist.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_watchlist_view.dart';
import '../widgets/error_view.dart';
import '../widgets/stock_list_tile.dart';
import '../widgets/stock_picker_sheet.dart';
import '../widgets/watchlist_header.dart';
import 'trade_ticket_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: _WatchlistAppBar(),
      floatingActionButton: BlocBuilder<WatchlistBloc, WatchlistState>(
        buildWhen: (p, c) => c is WatchlistLoaded || p is WatchlistLoaded,
        builder: (context, state) {
          if (state is! WatchlistLoaded) return const SizedBox.shrink();
          return FloatingActionButton(
            backgroundColor: AppTheme.accent,
            foregroundColor: Colors.white,
            onPressed: () => _openStockPicker(context, state.selected),
            tooltip: 'Add stock',
            child: const Icon(Icons.add_rounded),
          );
        },
      ),
      body: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          return switch (state) {
            WatchlistInitial() => const SizedBox.shrink(),
            WatchlistLoading() => const _LoadingView(),
            WatchlistLoaded() => _LoadedBody(state: state),
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

  static Future<void> _openStockPicker(
    BuildContext context,
    Watchlist watchlist,
  ) {
    return showStockPickerSheet(
      context: context,
      alreadyAdded: watchlist.symbols.toSet(),
      onSelected: (symbol) {
        context.read<WatchlistBloc>().add(WatchlistStockAdded(symbol));
      },
    );
  }
}

class _WatchlistAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryDark,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LiveDot(),
              SizedBox(width: 8),
              Text(
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
          Text(
            'Watchlists',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.playlist_add_rounded),
          color: AppTheme.textSecondary,
          tooltip: 'New watchlist',
          onPressed: () => _promptCreateWatchlist(context),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          color: AppTheme.textSecondary,
          tooltip: 'Manage',
          onPressed: () => _showManageMenu(context),
        ),
        const SizedBox(width: 4),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppTheme.dividerColor),
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppTheme.gainGreen,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  final WatchlistLoaded state;

  const _LoadedBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final selected = state.selected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WatchlistTabs(state: state),
        if (selected.symbols.isEmpty)
          Expanded(
            child: EmptyWatchlistView(
              onAddStocks: () => WatchlistScreen._openStockPicker(
                context,
                selected,
              ),
            ),
          )
        else ...[
          WatchlistHeader(watchlist: selected),
          Expanded(
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              itemCount: selected.symbols.length,
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
                      shadowColor: AppTheme.accent.withValues(alpha: 0.3),
                      child: child,
                    );
                  },
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final symbol = selected.symbols[index];
                return LiveWatchlistTile(
                  key: ValueKey(symbol),
                  symbol: symbol,
                  index: index,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => TradeTicketScreen(symbol: symbol),
                      ),
                    );
                  },
                  onRemove: () {
                    context
                        .read<WatchlistBloc>()
                        .add(WatchlistStockRemoved(symbol));
                    _showRemovedSnackbar(context, symbol);
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  void _showRemovedSnackbar(BuildContext context, String symbol) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$symbol removed',
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          backgroundColor: AppTheme.cardDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppTheme.borderColor),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

class _WatchlistTabs extends StatelessWidget {
  final WatchlistLoaded state;

  const _WatchlistTabs({required this.state});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
        itemCount: state.watchlists.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final wl = state.watchlists[index];
          final selected = wl.id == state.selectedId;
          return ChoiceChip(
            label: Text(wl.name),
            selected: selected,
            onSelected: (_) {
              HapticFeedback.selectionClick();
              context.read<WatchlistBloc>().add(WatchlistSelected(wl.id));
            },
            selectedColor: AppTheme.accent.withValues(alpha: 0.25),
            backgroundColor: AppTheme.cardDark,
            labelStyle: TextStyle(
              color: selected ? AppTheme.accentLight : AppTheme.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
            side: BorderSide(
              color: selected ? AppTheme.accent : AppTheme.borderColor,
            ),
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      padding: const EdgeInsets.only(top: 8),
      itemBuilder: (_, index) => _ShimmerTile(index: index),
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
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
                _box(20, 20),
                const SizedBox(width: 12),
                _box(44, 44, radius: 10),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(14, 90),
                      const SizedBox(height: 6),
                      _box(11, 140),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _box(15, 80),
                    const SizedBox(height: 6),
                    _box(22, 60, radius: 6),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _box(double h, double w, {double radius = 4}) {
    return Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

Future<void> _promptCreateWatchlist(BuildContext context) async {
  final controller = TextEditingController();
  final name = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('New watchlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Name',
            hintStyle: TextStyle(color: AppTheme.textMuted),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      );
    },
  );

  if (name == null || name.trim().isEmpty || !context.mounted) return;
  context.read<WatchlistBloc>().add(WatchlistCreated(name.trim()));
}

Future<void> _showManageMenu(BuildContext context) async {
  final state = context.read<WatchlistBloc>().state;
  if (state is! WatchlistLoaded) return;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppTheme.surfaceDark,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: AppTheme.accent),
              title: const Text('Rename watchlist'),
              onTap: () {
                Navigator.pop(sheetContext);
                _promptRenameWatchlist(context, state.selected);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline_rounded,
                color: state.watchlists.length <= 1
                    ? AppTheme.textMuted
                    : AppTheme.lossRed,
              ),
              title: Text(
                'Delete watchlist',
                style: TextStyle(
                  color: state.watchlists.length <= 1
                      ? AppTheme.textMuted
                      : AppTheme.textPrimary,
                ),
              ),
              subtitle: state.watchlists.length <= 1
                  ? const Text('Keep at least one watchlist')
                  : Text('Delete "${state.selected.name}"'),
              onTap: state.watchlists.length <= 1
                  ? null
                  : () {
                      Navigator.pop(sheetContext);
                      _confirmDeleteWatchlist(context, state.selected);
                    },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

Future<void> _promptRenameWatchlist(
  BuildContext context,
  Watchlist watchlist,
) async {
  final controller = TextEditingController(text: watchlist.name);
  final name = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Rename watchlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(hintText: 'Name'),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      );
    },
  );

  if (name == null || name.trim().isEmpty || !context.mounted) return;
  context.read<WatchlistBloc>().add(
        WatchlistRenamed(watchlistId: watchlist.id, name: name.trim()),
      );
}

Future<void> _confirmDeleteWatchlist(
  BuildContext context,
  Watchlist watchlist,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Delete watchlist?'),
        content: Text('Remove "${watchlist.name}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.lossRed),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (confirmed != true || !context.mounted) return;
  context.read<WatchlistBloc>().add(WatchlistDeleted(watchlist.id));
}

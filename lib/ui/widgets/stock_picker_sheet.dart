import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/stock_universe.dart';
import '../../data/market/market_data_feed.dart';
import '../../data/models/stock_quote.dart';
import '../theme/app_theme.dart';
import 'stock_avatar.dart';

Future<void> showStockPickerSheet({
  required BuildContext context,
  required Set<String> alreadyAdded,
  required ValueChanged<String> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surfaceDark,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return _StockPickerSheet(
        alreadyAdded: alreadyAdded,
        onSelected: onSelected,
      );
    },
  );
}

class _StockPickerSheet extends StatelessWidget {
  final Set<String> alreadyAdded;
  final ValueChanged<String> onSelected;

  const _StockPickerSheet({
    required this.alreadyAdded,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final feed = context.read<MarketDataFeed>();
    final height = MediaQuery.sizeOf(context).height * 0.72;

    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Add stock',
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
              'Pick from the 10 available symbols',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: StockUniverse.all.length,
              itemBuilder: (context, index) {
                final info = StockUniverse.all[index];
                final added = alreadyAdded.contains(info.symbol);
                return ValueListenableBuilder<StockQuote>(
                  valueListenable: feed.listenable(info.symbol),
                  builder: (context, quote, _) {
                    return ListTile(
                      enabled: !added,
                      leading: StockAvatar(symbol: info.symbol, size: 40),
                      title: Text(
                        info.symbol,
                        style: TextStyle(
                          color:
                              added ? AppTheme.textMuted : AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        info.companyName,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      trailing: added
                          ? const Text(
                              'Added',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 12,
                              ),
                            )
                          : Text(
                              quote.ltp.formatted,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                      onTap: added
                          ? null
                          : () {
                              HapticFeedback.selectionClick();
                              onSelected(info.symbol);
                              Navigator.of(context).pop();
                            },
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

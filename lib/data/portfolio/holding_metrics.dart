import '../../core/money.dart';
import '../models/holding.dart';

/// Live valuation for one holding at a given LTP (paise-precise).
class HoldingMetrics {
  final Holding holding;
  final Money ltp;

  const HoldingMetrics({required this.holding, required this.ltp});

  String get symbol => holding.symbol;
  int get quantity => holding.quantity;
  Money get avgCost => holding.avgCost;

  Money get invested => holding.invested;
  Money get currentValue => ltp * holding.quantity;
  Money get pnl => currentValue - invested;

  double get pnlPercent => pnl.percentOf(invested);

  String get formattedPnlPercent {
    final sign = pnlPercent > 0 ? '+' : '';
    return '$sign${pnlPercent.toStringAsFixed(2)}%';
  }
}

enum HoldingsSortBy {
  pnlDesc,
  symbolAsc,
  valueDesc,
}

extension HoldingsSortByX on HoldingsSortBy {
  String get label => switch (this) {
        HoldingsSortBy.pnlDesc => 'P&L',
        HoldingsSortBy.symbolAsc => 'Symbol',
        HoldingsSortBy.valueDesc => 'Value',
      };
}

List<Holding> sortHoldings({
  required List<Holding> holdings,
  required Money Function(String symbol) ltpOf,
  required HoldingsSortBy sortBy,
}) {
  final list = List<Holding>.from(holdings);
  switch (sortBy) {
    case HoldingsSortBy.pnlDesc:
      list.sort((a, b) {
        final ma = HoldingMetrics(holding: a, ltp: ltpOf(a.symbol));
        final mb = HoldingMetrics(holding: b, ltp: ltpOf(b.symbol));
        final byPnl = mb.pnl.compareTo(ma.pnl);
        if (byPnl != 0) return byPnl;
        return a.symbol.compareTo(b.symbol);
      });
    case HoldingsSortBy.symbolAsc:
      list.sort((a, b) => a.symbol.compareTo(b.symbol));
    case HoldingsSortBy.valueDesc:
      list.sort((a, b) {
        final ma = HoldingMetrics(holding: a, ltp: ltpOf(a.symbol));
        final mb = HoldingMetrics(holding: b, ltp: ltpOf(b.symbol));
        final byValue = mb.currentValue.compareTo(ma.currentValue);
        if (byValue != 0) return byValue;
        return a.symbol.compareTo(b.symbol);
      });
  }
  return list;
}

class PortfolioMetrics {
  final Money totalInvested;
  final Money currentValue;
  final Money totalPnl;

  const PortfolioMetrics({
    required this.totalInvested,
    required this.currentValue,
    required this.totalPnl,
  });

  double get totalPnlPercent => totalPnl.percentOf(totalInvested);

  String get formattedPnlPercent {
    final sign = totalPnlPercent > 0 ? '+' : '';
    return '$sign${totalPnlPercent.toStringAsFixed(2)}%';
  }

  factory PortfolioMetrics.fromHoldings({
    required List<Holding> holdings,
    required Money Function(String symbol) ltpOf,
  }) {
    var invested = const Money(0);
    var value = const Money(0);
    for (final h in holdings) {
      final m = HoldingMetrics(holding: h, ltp: ltpOf(h.symbol));
      invested += m.invested;
      value += m.currentValue;
    }
    return PortfolioMetrics(
      totalInvested: invested,
      currentValue: value,
      totalPnl: value - invested,
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist_app/core/money.dart';
import 'package:watchlist_app/data/models/holding.dart';
import 'package:watchlist_app/data/portfolio/holding_metrics.dart';

void main() {
  group('HoldingMetrics', () {
    test('computes value and P&L in paise', () {
      const holding = Holding(
        symbol: 'TCS',
        quantity: 10,
        avgCost: Money(10000), // ₹100.00
      );
      const metrics = HoldingMetrics(
        holding: holding,
        ltp: Money(11000), // ₹110.00
      );

      expect(metrics.invested.paise, 100000);
      expect(metrics.currentValue.paise, 110000);
      expect(metrics.pnl.paise, 10000);
      expect(metrics.pnlPercent, closeTo(10.0, 0.0001));
      expect(metrics.pnl.formattedSigned, '+₹100.00');
    });
  });

  group('sortHoldings', () {
    final holdings = [
      const Holding(symbol: 'B', quantity: 1, avgCost: Money(10000)),
      const Holding(symbol: 'A', quantity: 1, avgCost: Money(10000)),
      const Holding(symbol: 'C', quantity: 1, avgCost: Money(10000)),
    ];

    Money ltpOf(String s) => switch (s) {
          'A' => const Money(9000), // loss
          'B' => const Money(15000), // big gain
          'C' => const Money(12000), // smaller gain
          _ => const Money(10000),
        };

    test('default P&L descending', () {
      final sorted = sortHoldings(
        holdings: holdings,
        ltpOf: ltpOf,
        sortBy: HoldingsSortBy.pnlDesc,
      );
      expect(sorted.map((h) => h.symbol).toList(), ['B', 'C', 'A']);
    });

    test('symbol ascending', () {
      final sorted = sortHoldings(
        holdings: holdings,
        ltpOf: ltpOf,
        sortBy: HoldingsSortBy.symbolAsc,
      );
      expect(sorted.map((h) => h.symbol).toList(), ['A', 'B', 'C']);
    });

    test('current value descending', () {
      final sorted = sortHoldings(
        holdings: holdings,
        ltpOf: ltpOf,
        sortBy: HoldingsSortBy.valueDesc,
      );
      expect(sorted.map((h) => h.symbol).toList(), ['B', 'C', 'A']);
    });

    test('P&L order updates when prices cross', () {
      Money crossing(String s) => switch (s) {
            'A' => const Money(20000), // now best
            'B' => const Money(15000),
            'C' => const Money(12000),
            _ => const Money(10000),
          };

      final sorted = sortHoldings(
        holdings: holdings,
        ltpOf: crossing,
        sortBy: HoldingsSortBy.pnlDesc,
      );
      expect(sorted.first.symbol, 'A');
    });
  });

  group('PortfolioMetrics', () {
    test('aggregate equals sum of rows', () {
      final holdings = [
        const Holding(symbol: 'X', quantity: 2, avgCost: Money(10000)),
        const Holding(symbol: 'Y', quantity: 3, avgCost: Money(20000)),
      ];
      Money ltpOf(String s) =>
          s == 'X' ? const Money(11000) : const Money(19000);

      final agg = PortfolioMetrics.fromHoldings(
        holdings: holdings,
        ltpOf: ltpOf,
      );

      var invested = const Money(0);
      var value = const Money(0);
      for (final h in holdings) {
        final m = HoldingMetrics(holding: h, ltp: ltpOf(h.symbol));
        invested += m.invested;
        value += m.currentValue;
      }

      expect(agg.totalInvested, invested);
      expect(agg.currentValue, value);
      expect(agg.totalPnl, value - invested);
    });
  });
}

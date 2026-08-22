import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist_app/core/money.dart';
import 'package:watchlist_app/data/models/holding.dart';
import 'package:watchlist_app/data/models/order.dart';
import 'package:watchlist_app/data/models/portfolio.dart';
import 'package:watchlist_app/data/portfolio/order_executor.dart';

void main() {
  const executor = OrderExecutor();

  group('OrderExecutor validation', () {
    test('rejects empty / fractional / zero quantity', () {
      final p = Portfolio.initial();
      final ltp = Money.fromRupees(100);

      expect(
        executor.validate(
          portfolio: p,
          symbol: 'TCS',
          side: OrderSide.buy,
          quantityText: '',
          ltp: ltp,
        ),
        isNotNull,
      );
      expect(
        executor.validate(
          portfolio: p,
          symbol: 'TCS',
          side: OrderSide.buy,
          quantityText: '1.5',
          ltp: ltp,
        ),
        isNotNull,
      );
      expect(
        executor.validate(
          portfolio: p,
          symbol: 'TCS',
          side: OrderSide.buy,
          quantityText: '0',
          ltp: ltp,
        ),
        isNotNull,
      );
      expect(
        executor.validate(
          portfolio: p,
          symbol: 'TCS',
          side: OrderSide.buy,
          quantityText: '-2',
          ltp: ltp,
        ),
        isNotNull,
      );
    });

    test('blocks buy when order value exceeds cash', () {
      final p = Portfolio.initial();
      final error = executor.validate(
        portfolio: p,
        symbol: 'RELIANCE',
        side: OrderSide.buy,
        quantityText: '1000',
        ltp: Money.fromRupees(2843.50),
      );
      expect(error, contains('Insufficient balance'));
    });

    test('blocks sell when qty exceeds holdings', () {
      final p = Portfolio.initial().copyWith(
        holdings: [
          Holding(
            symbol: 'TCS',
            quantity: 2,
            avgCost: Money.fromRupees(3500),
          ),
        ],
      );
      final error = executor.validate(
        portfolio: p,
        symbol: 'TCS',
        side: OrderSide.sell,
        quantityText: '5',
        ltp: Money.fromRupees(3600),
      );
      expect(error, contains('Cannot sell more than held'));
    });
  });

  group('OrderExecutor place', () {
    test('buy deducts cash and creates holding at LTP', () {
      final p = Portfolio.initial();
      final ltp = Money.fromRupees(100.25);
      final result = executor.place(
        portfolio: p,
        id: 'o1',
        symbol: 'INFY',
        side: OrderSide.buy,
        quantityText: '10',
        ltp: ltp,
      );

      expect(result.order.orderValue, Money.fromRupees(1002.50));
      expect(
        result.portfolio.cashBalance,
        Portfolio.defaultCash - Money.fromRupees(1002.50),
      );
      final h = result.portfolio.holdingFor('INFY')!;
      expect(h.quantity, 10);
      expect(h.avgCost, ltp);
    });

    test('second buy updates weighted average cost precisely', () {
      var p = Portfolio.initial();
      p = executor
          .place(
            portfolio: p,
            id: 'o1',
            symbol: 'SBIN',
            side: OrderSide.buy,
            quantityText: '2',
            ltp: Money.fromRupees(100),
          )
          .portfolio;

      p = executor
          .place(
            portfolio: p,
            id: 'o2',
            symbol: 'SBIN',
            side: OrderSide.buy,
            quantityText: '2',
            ltp: Money.fromRupees(200),
          )
          .portfolio;

      final h = p.holdingFor('SBIN')!;
      expect(h.quantity, 4);
      // (2*100 + 2*200) / 4 = 150
      expect(h.avgCost, Money.fromRupees(150));
    });

    test('sell credits cash and removes holding at zero qty', () {
      var p = Portfolio.initial();
      p = executor
          .place(
            portfolio: p,
            id: 'o1',
            symbol: 'ITC',
            side: OrderSide.buy,
            quantityText: '5',
            ltp: Money.fromRupees(400),
          )
          .portfolio;

      final afterSell = executor.place(
        portfolio: p,
        id: 'o2',
        symbol: 'ITC',
        side: OrderSide.sell,
        quantityText: '5',
        ltp: Money.fromRupees(410),
      );

      expect(afterSell.portfolio.holdingFor('ITC'), isNull);
      expect(
        afterSell.portfolio.cashBalance,
        Portfolio.defaultCash - Money.fromRupees(2000) + Money.fromRupees(2050),
      );
      expect(afterSell.portfolio.orders.length, 2);
    });

    test('order value uses LTP at submit (paise math)', () {
      final result = executor.place(
        portfolio: Portfolio.initial(),
        id: 'o1',
        symbol: 'TCS',
        side: OrderSide.buy,
        quantityText: '3',
        ltp: const Money(362180), // ₹3621.80
      );
      expect(result.order.orderValue.paise, 362180 * 3);
      expect(result.order.orderValue.formatted, '₹10865.40');
    });
  });
}

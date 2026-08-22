import 'package:equatable/equatable.dart';

import '../../core/money.dart';

enum PriceDirection { up, down, flat }

/// Live quote for a single symbol. Prices are Money (paise) — never raw doubles.
class StockQuote extends Equatable {
  final String symbol;
  final Money ltp;
  final Money previousClose;
  final Money change;
  final double changePercent;
  final PriceDirection direction;
  final DateTime updatedAt;

  const StockQuote({
    required this.symbol,
    required this.ltp,
    required this.previousClose,
    required this.change,
    required this.changePercent,
    required this.direction,
    required this.updatedAt,
  });

  factory StockQuote.seed({
    required String symbol,
    required Money price,
    DateTime? at,
  }) {
    return StockQuote(
      symbol: symbol,
      ltp: price,
      previousClose: price,
      change: const Money(0),
      changePercent: 0,
      direction: PriceDirection.flat,
      updatedAt: at ?? DateTime.now(),
    );
  }

  StockQuote withLtp(Money newLtp, {DateTime? at}) {
    final change = newLtp - previousClose;
    final pct = change.percentOf(previousClose);
    final direction = change.paise > 0
        ? PriceDirection.up
        : change.paise < 0
            ? PriceDirection.down
            : PriceDirection.flat;
    return StockQuote(
      symbol: symbol,
      ltp: newLtp,
      previousClose: previousClose,
      change: change,
      changePercent: pct,
      direction: direction,
      updatedAt: at ?? DateTime.now(),
    );
  }

  String get formattedChangePercent {
    final sign = changePercent > 0 ? '+' : '';
    return '$sign${changePercent.toStringAsFixed(2)}%';
  }

  @override
  List<Object?> get props => [
        symbol,
        ltp,
        previousClose,
        change,
        changePercent,
        direction,
        updatedAt,
      ];
}

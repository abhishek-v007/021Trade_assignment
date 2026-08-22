import 'package:equatable/equatable.dart';

import '../../core/money.dart';

/// A held position. [avgCost] is weighted average buy price (paise-precise).
class Holding extends Equatable {
  final String symbol;
  final int quantity;
  final Money avgCost;

  const Holding({
    required this.symbol,
    required this.quantity,
    required this.avgCost,
  });

  Money get invested => avgCost * quantity;

  Holding copyWith({
    String? symbol,
    int? quantity,
    Money? avgCost,
  }) {
    return Holding(
      symbol: symbol ?? this.symbol,
      quantity: quantity ?? this.quantity,
      avgCost: avgCost ?? this.avgCost,
    );
  }

  /// Apply a buy: increase qty and recompute weighted average cost.
  Holding applyBuy({required int buyQty, required Money buyPrice}) {
    final totalCostPaise =
        (avgCost.paise * quantity) + (buyPrice.paise * buyQty);
    final newQty = quantity + buyQty;
    final newAvg = Money((totalCostPaise / newQty).round());
    return Holding(symbol: symbol, quantity: newQty, avgCost: newAvg);
  }

  /// Apply a sell: reduce qty; avg cost unchanged. Returns null if qty hits 0.
  Holding? applySell({required int sellQty}) {
    final remaining = quantity - sellQty;
    if (remaining <= 0) return null;
    return copyWith(quantity: remaining);
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'quantity': quantity,
        'avgCostPaise': avgCost.paise,
      };

  factory Holding.fromJson(Map<String, dynamic> json) {
    return Holding(
      symbol: json['symbol'] as String,
      quantity: json['quantity'] as int,
      avgCost: Money(json['avgCostPaise'] as int),
    );
  }

  @override
  List<Object?> get props => [symbol, quantity, avgCost];
}

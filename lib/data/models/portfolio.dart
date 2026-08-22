import 'package:equatable/equatable.dart';

import '../../core/money.dart';
import 'holding.dart';
import 'order.dart';

class Portfolio extends Equatable {
  final Money cashBalance;
  final List<Holding> holdings;
  final List<Order> orders;

  const Portfolio({
    required this.cashBalance,
    required this.holdings,
    required this.orders,
  });

  static final Money defaultCash = Money.fromRupees(100000);

  factory Portfolio.initial() => Portfolio(
        cashBalance: defaultCash,
        holdings: const [],
        orders: const [],
      );

  Holding? holdingFor(String symbol) {
    for (final h in holdings) {
      if (h.symbol == symbol) return h;
    }
    return null;
  }

  int quantityHeld(String symbol) => holdingFor(symbol)?.quantity ?? 0;

  Portfolio copyWith({
    Money? cashBalance,
    List<Holding>? holdings,
    List<Order>? orders,
  }) {
    return Portfolio(
      cashBalance: cashBalance ?? this.cashBalance,
      holdings: holdings ?? this.holdings,
      orders: orders ?? this.orders,
    );
  }

  Map<String, dynamic> toJson() => {
        'cashBalancePaise': cashBalance.paise,
        'holdings': holdings.map((h) => h.toJson()).toList(),
        'orders': orders.map((o) => o.toJson()).toList(),
      };

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      cashBalance: Money(json['cashBalancePaise'] as int),
      holdings: (json['holdings'] as List<dynamic>)
          .map((e) => Holding.fromJson(e as Map<String, dynamic>))
          .toList(),
      orders: (json['orders'] as List<dynamic>)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [cashBalance, holdings, orders];
}

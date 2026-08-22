import 'package:equatable/equatable.dart';

import '../../core/money.dart';

enum OrderSide { buy, sell }

extension OrderSideX on OrderSide {
  String get label => this == OrderSide.buy ? 'Buy' : 'Sell';
}

class Order extends Equatable {
  final String id;
  final String symbol;
  final OrderSide side;
  final int quantity;
  final Money ltpAtSubmit;
  final Money orderValue;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.ltpAtSubmit,
    required this.orderValue,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'symbol': symbol,
        'side': side.name,
        'quantity': quantity,
        'ltpAtSubmitPaise': ltpAtSubmit.paise,
        'orderValuePaise': orderValue.paise,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      side: OrderSide.values.byName(json['side'] as String),
      quantity: json['quantity'] as int,
      ltpAtSubmit: Money(json['ltpAtSubmitPaise'] as int),
      orderValue: Money(json['orderValuePaise'] as int),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props =>
      [id, symbol, side, quantity, ltpAtSubmit, orderValue, createdAt];
}

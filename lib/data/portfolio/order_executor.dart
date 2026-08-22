import '../../core/money.dart';
import '../../core/stock_universe.dart';
import '../models/holding.dart';
import '../models/order.dart';
import '../models/portfolio.dart';

class OrderValidationException implements Exception {
  final String message;
  const OrderValidationException(this.message);

  @override
  String toString() => message;
}

class PlaceOrderResult {
  final Portfolio portfolio;
  final Order order;

  const PlaceOrderResult({required this.portfolio, required this.order});
}

/// Pure order placement — wallet, holdings, and order history updates.
class OrderExecutor {
  const OrderExecutor();

  /// Validates inputs and returns an inline error message, or null if OK.
  String? validate({
    required Portfolio portfolio,
    required String symbol,
    required OrderSide side,
    required String quantityText,
    required Money ltp,
  }) {
    if (!StockUniverse.contains(symbol)) {
      return 'Unknown symbol';
    }

    final qty = _parseQuantity(quantityText);
    if (qty == null) {
      return 'Enter a whole-number quantity';
    }
    if (qty <= 0) {
      return 'Quantity must be greater than zero';
    }

    final orderValue = ltp * qty;

    if (side == OrderSide.buy) {
      if (orderValue.paise > portfolio.cashBalance.paise) {
        return 'Insufficient balance '
            '(need ${orderValue.formatted}, have ${portfolio.cashBalance.formatted})';
      }
    } else {
      final held = portfolio.quantityHeld(symbol);
      if (qty > held) {
        return held == 0
            ? 'No holdings for $symbol'
            : 'Cannot sell more than held ($held available)';
      }
    }

    return null;
  }

  PlaceOrderResult place({
    required Portfolio portfolio,
    required String id,
    required String symbol,
    required OrderSide side,
    required String quantityText,
    required Money ltp,
    DateTime? at,
  }) {
    final error = validate(
      portfolio: portfolio,
      symbol: symbol,
      side: side,
      quantityText: quantityText,
      ltp: ltp,
    );
    if (error != null) {
      throw OrderValidationException(error);
    }

    final qty = _parseQuantity(quantityText)!;
    final orderValue = ltp * qty;
    final createdAt = at ?? DateTime.now();

    final order = Order(
      id: id,
      symbol: symbol,
      side: side,
      quantity: qty,
      ltpAtSubmit: ltp,
      orderValue: orderValue,
      createdAt: createdAt,
    );

    if (side == OrderSide.buy) {
      return PlaceOrderResult(
        order: order,
        portfolio: _applyBuy(portfolio, order),
      );
    }
    return PlaceOrderResult(
      order: order,
      portfolio: _applySell(portfolio, order),
    );
  }

  Portfolio _applyBuy(Portfolio portfolio, Order order) {
    final existing = portfolio.holdingFor(order.symbol);
    final Holding updated;
    if (existing == null) {
      updated = Holding(
        symbol: order.symbol,
        quantity: order.quantity,
        avgCost: order.ltpAtSubmit,
      );
    } else {
      updated = existing.applyBuy(
        buyQty: order.quantity,
        buyPrice: order.ltpAtSubmit,
      );
    }

    final holdings = [
      for (final h in portfolio.holdings)
        if (h.symbol != order.symbol) h,
      updated,
    ]..sort((a, b) => a.symbol.compareTo(b.symbol));

    return portfolio.copyWith(
      cashBalance: portfolio.cashBalance - order.orderValue,
      holdings: holdings,
      orders: [order, ...portfolio.orders],
    );
  }

  Portfolio _applySell(Portfolio portfolio, Order order) {
    final existing = portfolio.holdingFor(order.symbol)!;
    final remaining = existing.applySell(sellQty: order.quantity);

    final holdings = [
      for (final h in portfolio.holdings)
        if (h.symbol != order.symbol) h,
      if (remaining != null) remaining,
    ]..sort((a, b) => a.symbol.compareTo(b.symbol));

    return portfolio.copyWith(
      cashBalance: portfolio.cashBalance + order.orderValue,
      holdings: holdings,
      orders: [order, ...portfolio.orders],
    );
  }

  /// Whole shares only — rejects empty, fractional, and non-numeric input.
  int? _parseQuantity(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.contains('.') || trimmed.contains(',')) return null;
    return int.tryParse(trimmed);
  }
}

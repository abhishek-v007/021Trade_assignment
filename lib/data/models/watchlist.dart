import 'package:equatable/equatable.dart';
import 'stock.dart';

class Watchlist extends Equatable {
  final String id;
  final String name;
  final List<Stock> stocks;

  const Watchlist({
    required this.id,
    required this.name,
    required this.stocks,
  });

  Watchlist copyWith({
    String? id,
    String? name,
    List<Stock>? stocks,
  }) {
    return Watchlist(
      id: id ?? this.id,
      name: name ?? this.name,
      stocks: stocks ?? this.stocks,
    );
  }

  Watchlist reorderStock(int oldIndex, int newIndex) {
    final updatedStocks = List<Stock>.from(stocks);
    final stock = updatedStocks.removeAt(oldIndex);
    final insertIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    updatedStocks.insert(insertIndex, stock);
    return copyWith(stocks: updatedStocks);
  }

  Watchlist removeStock(String stockId) {
    return copyWith(
      stocks: stocks.where((s) => s.id != stockId).toList(),
    );
  }

  @override
  List<Object?> get props => [id, name, stocks];
}

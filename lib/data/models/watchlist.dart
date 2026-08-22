import 'package:equatable/equatable.dart';

/// A named watchlist. Stores **symbols only** so live prices always bind by
/// symbol (reorder never shows stale ticks for the wrong row).
class Watchlist extends Equatable {
  final String id;
  final String name;
  final List<String> symbols;

  const Watchlist({
    required this.id,
    required this.name,
    required this.symbols,
  });

  Watchlist copyWith({
    String? id,
    String? name,
    List<String>? symbols,
  }) {
    return Watchlist(
      id: id ?? this.id,
      name: name ?? this.name,
      symbols: symbols ?? this.symbols,
    );
  }

  bool contains(String symbol) => symbols.contains(symbol);

  Watchlist addSymbol(String symbol) {
    if (symbols.contains(symbol)) return this;
    return copyWith(symbols: [...symbols, symbol]);
  }

  Watchlist removeSymbol(String symbol) {
    return copyWith(
      symbols: symbols.where((s) => s != symbol).toList(growable: false),
    );
  }

  Watchlist reorderSymbol(int oldIndex, int newIndex) {
    final updated = List<String>.from(symbols);
    final item = updated.removeAt(oldIndex);
    final insertIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    updated.insert(insertIndex, item);
    return copyWith(symbols: updated);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'symbols': symbols,
      };

  factory Watchlist.fromJson(Map<String, dynamic> json) {
    return Watchlist(
      id: json['id'] as String,
      name: json['name'] as String,
      symbols: (json['symbols'] as List<dynamic>).cast<String>(),
    );
  }

  @override
  List<Object?> get props => [id, name, symbols];
}

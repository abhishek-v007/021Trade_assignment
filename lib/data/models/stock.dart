import 'package:equatable/equatable.dart';

enum StockTrend { up, down, neutral }

class Stock extends Equatable {
  final String id;
  final String symbol;
  final String companyName;
  final double currentPrice;
  final double changeAmount;
  final double changePercent;
  final StockTrend trend;
  final String logoAsset;
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final double volume;

  const Stock({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.currentPrice,
    required this.changeAmount,
    required this.changePercent,
    required this.trend,
    required this.logoAsset,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
  });

  bool get isPositive => trend == StockTrend.up;
  bool get isNegative => trend == StockTrend.down;

  String get formattedPrice => '₹${currentPrice.toStringAsFixed(2)}';

  String get formattedChange {
    final sign = isPositive ? '+' : '';
    return '$sign${changeAmount.toStringAsFixed(2)}';
  }

  String get formattedChangePercent {
    final sign = isPositive ? '+' : '';
    return '$sign${changePercent.toStringAsFixed(2)}%';
  }

  String get formattedVolume {
    if (volume >= 10000000) return '${(volume / 10000000).toStringAsFixed(2)}Cr';
    if (volume >= 100000) return '${(volume / 100000).toStringAsFixed(2)}L';
    if (volume >= 1000) return '${(volume / 1000).toStringAsFixed(2)}K';
    return volume.toStringAsFixed(0);
  }

  Stock copyWith({
    String? id,
    String? symbol,
    String? companyName,
    double? currentPrice,
    double? changeAmount,
    double? changePercent,
    StockTrend? trend,
    String? logoAsset,
    double? openPrice,
    double? highPrice,
    double? lowPrice,
    double? volume,
  }) {
    return Stock(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      companyName: companyName ?? this.companyName,
      currentPrice: currentPrice ?? this.currentPrice,
      changeAmount: changeAmount ?? this.changeAmount,
      changePercent: changePercent ?? this.changePercent,
      trend: trend ?? this.trend,
      logoAsset: logoAsset ?? this.logoAsset,
      openPrice: openPrice ?? this.openPrice,
      highPrice: highPrice ?? this.highPrice,
      lowPrice: lowPrice ?? this.lowPrice,
      volume: volume ?? this.volume,
    );
  }

  @override
  List<Object?> get props => [
        id,
        symbol,
        companyName,
        currentPrice,
        changeAmount,
        changePercent,
        trend,
        logoAsset,
        openPrice,
        highPrice,
        lowPrice,
        volume,
      ];
}

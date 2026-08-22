import 'money.dart';

/// Canonical 10 stocks used throughout the app (assignment requirement).
class StockInfo {
  final String symbol;
  final String companyName;
  final Money startingPrice;

  const StockInfo({
    required this.symbol,
    required this.companyName,
    required this.startingPrice,
  });
}

class StockUniverse {
  StockUniverse._();

  static final List<StockInfo> all = [
    StockInfo(
      symbol: 'RELIANCE',
      companyName: 'Reliance Industries Ltd.',
      startingPrice: Money.fromRupees(2843.50),
    ),
    StockInfo(
      symbol: 'TCS',
      companyName: 'Tata Consultancy Services',
      startingPrice: Money.fromRupees(3621.80),
    ),
    StockInfo(
      symbol: 'INFY',
      companyName: 'Infosys Limited',
      startingPrice: Money.fromRupees(1456.35),
    ),
    StockInfo(
      symbol: 'HDFCBANK',
      companyName: 'HDFC Bank Limited',
      startingPrice: Money.fromRupees(1678.90),
    ),
    StockInfo(
      symbol: 'ICICIBANK',
      companyName: 'ICICI Bank Limited',
      startingPrice: Money.fromRupees(1092.75),
    ),
    StockInfo(
      symbol: 'SBIN',
      companyName: 'State Bank of India',
      startingPrice: Money.fromRupees(812.40),
    ),
    StockInfo(
      symbol: 'ITC',
      companyName: 'ITC Limited',
      startingPrice: Money.fromRupees(462.15),
    ),
    StockInfo(
      symbol: 'LT',
      companyName: 'Larsen & Toubro Ltd.',
      startingPrice: Money.fromRupees(3542.60),
    ),
    StockInfo(
      symbol: 'BHARTIARTL',
      companyName: 'Bharti Airtel Limited',
      startingPrice: Money.fromRupees(1287.30),
    ),
    StockInfo(
      symbol: 'AXISBANK',
      companyName: 'Axis Bank Limited',
      startingPrice: Money.fromRupees(1124.55),
    ),
  ];

  static final Map<String, StockInfo> _bySymbol = {
    for (final s in all) s.symbol: s,
  };

  static StockInfo? of(String symbol) => _bySymbol[symbol];

  static String companyName(String symbol) =>
      _bySymbol[symbol]?.companyName ?? symbol;

  static bool contains(String symbol) => _bySymbol.containsKey(symbol);

  static List<String> get symbols =>
      all.map((s) => s.symbol).toList(growable: false);
}

import '../models/stock.dart';
import '../models/watchlist.dart';

abstract class WatchlistRepository {
  Future<Watchlist> fetchWatchlist();
  Future<Watchlist> reorderStock(Watchlist watchlist, int oldIndex, int newIndex);
  Future<Watchlist> removeStock(Watchlist watchlist, String stockId);
}

class WatchlistRepositoryImpl implements WatchlistRepository {
  static const _sampleStocks = <Map<String, dynamic>>[
    {
      'id': '1',
      'symbol': 'RELIANCE',
      'companyName': 'Reliance Industries Ltd.',
      'currentPrice': 2843.50,
      'changeAmount': 45.30,
      'changePercent': 1.62,
      'trend': StockTrend.up,
      'openPrice': 2798.20,
      'highPrice': 2860.00,
      'lowPrice': 2790.15,
      'volume': 8543210.0,
    },
    {
      'id': '2',
      'symbol': 'TCS',
      'companyName': 'Tata Consultancy Services',
      'currentPrice': 3621.80,
      'changeAmount': -38.45,
      'changePercent': -1.05,
      'trend': StockTrend.down,
      'openPrice': 3660.25,
      'highPrice': 3672.00,
      'lowPrice': 3610.50,
      'volume': 2341560.0,
    },
    {
      'id': '3',
      'symbol': 'HDFCBANK',
      'companyName': 'HDFC Bank Limited',
      'currentPrice': 1678.90,
      'changeAmount': 22.15,
      'changePercent': 1.34,
      'trend': StockTrend.up,
      'openPrice': 1656.75,
      'highPrice': 1685.40,
      'lowPrice': 1652.00,
      'volume': 5672340.0,
    },
    {
      'id': '4',
      'symbol': 'INFY',
      'companyName': 'Infosys Limited',
      'currentPrice': 1456.35,
      'changeAmount': -12.70,
      'changePercent': -0.87,
      'trend': StockTrend.down,
      'openPrice': 1469.05,
      'highPrice': 1475.80,
      'lowPrice': 1450.20,
      'volume': 4123890.0,
    },
    {
      'id': '5',
      'symbol': 'WIPRO',
      'companyName': 'Wipro Limited',
      'currentPrice': 452.60,
      'changeAmount': 3.85,
      'changePercent': 0.86,
      'trend': StockTrend.up,
      'openPrice': 448.75,
      'highPrice': 458.90,
      'lowPrice': 447.00,
      'volume': 3215670.0,
    },
    {
      'id': '6',
      'symbol': 'BAJFINANCE',
      'companyName': 'Bajaj Finance Limited',
      'currentPrice': 6834.20,
      'changeAmount': -95.40,
      'changePercent': -1.38,
      'trend': StockTrend.down,
      'openPrice': 6929.60,
      'highPrice': 6950.00,
      'lowPrice': 6820.10,
      'volume': 1543210.0,
    },
    {
      'id': '7',
      'symbol': 'ICICIBANK',
      'companyName': 'ICICI Bank Limited',
      'currentPrice': 1092.75,
      'changeAmount': 14.30,
      'changePercent': 1.33,
      'trend': StockTrend.up,
      'openPrice': 1078.45,
      'highPrice': 1098.50,
      'lowPrice': 1075.20,
      'volume': 7832450.0,
    },
    {
      'id': '8',
      'symbol': 'SBIN',
      'companyName': 'State Bank of India',
      'currentPrice': 812.40,
      'changeAmount': 0.00,
      'changePercent': 0.00,
      'trend': StockTrend.neutral,
      'openPrice': 812.40,
      'highPrice': 820.30,
      'lowPrice': 808.75,
      'volume': 9234560.0,
    },
    {
      'id': '9',
      'symbol': 'TATAMOTORS',
      'companyName': 'Tata Motors Limited',
      'currentPrice': 962.15,
      'changeAmount': 28.65,
      'changePercent': 3.07,
      'trend': StockTrend.up,
      'openPrice': 933.50,
      'highPrice': 968.90,
      'lowPrice': 930.00,
      'volume': 6543210.0,
    },
    {
      'id': '10',
      'symbol': 'ADANIENT',
      'companyName': 'Adani Enterprises Ltd.',
      'currentPrice': 2345.60,
      'changeAmount': -42.30,
      'changePercent': -1.77,
      'trend': StockTrend.down,
      'openPrice': 2387.90,
      'highPrice': 2400.00,
      'lowPrice': 2338.50,
      'volume': 2134560.0,
    },
  ];

  @override
  Future<Watchlist> fetchWatchlist() async {
    await Future.delayed(const Duration(milliseconds: 600));

    final stocks = _sampleStocks
        .map(
          (data) => Stock(
            id: data['id'] as String,
            symbol: data['symbol'] as String,
            companyName: data['companyName'] as String,
            currentPrice: (data['currentPrice'] as num).toDouble(),
            changeAmount: (data['changeAmount'] as num).toDouble(),
            changePercent: (data['changePercent'] as num).toDouble(),
            trend: data['trend'] as StockTrend,
            logoAsset: '',
            openPrice: (data['openPrice'] as num).toDouble(),
            highPrice: (data['highPrice'] as num).toDouble(),
            lowPrice: (data['lowPrice'] as num).toDouble(),
            volume: (data['volume'] as num).toDouble(),
          ),
        )
        .toList();

    return Watchlist(
      id: 'watchlist_1',
      name: 'My Watchlist',
      stocks: stocks,
    );
  }

  @override
  Future<Watchlist> reorderStock(
    Watchlist watchlist,
    int oldIndex,
    int newIndex,
  ) async {
    return watchlist.reorderStock(oldIndex, newIndex);
  }

  @override
  Future<Watchlist> removeStock(Watchlist watchlist, String stockId) async {
    return watchlist.removeStock(stockId);
  }
}

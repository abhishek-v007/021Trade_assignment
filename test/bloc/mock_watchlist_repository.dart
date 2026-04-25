import 'package:watchlist_app/data/models/stock.dart';
import 'package:watchlist_app/data/models/watchlist.dart';
import 'package:watchlist_app/data/repositories/watchlist_repository.dart';

const mockStocks = <Stock>[
  Stock(
    id: '1',
    symbol: 'RELIANCE',
    companyName: 'Reliance Industries',
    currentPrice: 2843.50,
    changeAmount: 45.30,
    changePercent: 1.62,
    trend: StockTrend.up,
    logoAsset: '',
    openPrice: 2798.0,
    highPrice: 2860.0,
    lowPrice: 2790.0,
    volume: 1000000,
  ),
  Stock(
    id: '2',
    symbol: 'TCS',
    companyName: 'Tata Consultancy Services',
    currentPrice: 3621.80,
    changeAmount: -38.45,
    changePercent: -1.05,
    trend: StockTrend.down,
    logoAsset: '',
    openPrice: 3660.0,
    highPrice: 3672.0,
    lowPrice: 3610.0,
    volume: 500000,
  ),
  Stock(
    id: '3',
    symbol: 'INFY',
    companyName: 'Infosys Limited',
    currentPrice: 1456.35,
    changeAmount: -12.70,
    changePercent: -0.87,
    trend: StockTrend.down,
    logoAsset: '',
    openPrice: 1469.0,
    highPrice: 1475.0,
    lowPrice: 1450.0,
    volume: 750000,
  ),
];

const mockWatchlist = Watchlist(
  id: 'watchlist_1',
  name: 'My Watchlist',
  stocks: mockStocks,
);

class MockWatchlistRepository implements WatchlistRepository {
  bool shouldThrow;

  MockWatchlistRepository({this.shouldThrow = false});

  @override
  Future<Watchlist> fetchWatchlist() async {
    if (shouldThrow) throw Exception('Network error');
    return mockWatchlist;
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

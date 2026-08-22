import 'package:watchlist_app/data/models/watchlist.dart';
import 'package:watchlist_app/data/repositories/watchlist_repository.dart';

class MockWatchlistRepository implements WatchlistRepository {
  MockWatchlistRepository({
    this.shouldThrow = false,
    List<Watchlist>? initial,
  }) : _watchlists = List<Watchlist>.from(
          initial ??
              const [
                Watchlist(
                  id: 'wl_1',
                  name: 'My Watchlist',
                  symbols: ['RELIANCE', 'TCS', 'INFY'],
                ),
              ],
        );

  final bool shouldThrow;
  List<Watchlist> _watchlists;
  String? _selectedId;

  @override
  Future<List<Watchlist>> loadWatchlists() async {
    if (shouldThrow) throw Exception('load failed');
    return List<Watchlist>.from(_watchlists);
  }

  @override
  Future<String?> loadSelectedWatchlistId() async => _selectedId;

  @override
  Future<void> saveWatchlists(List<Watchlist> watchlists) async {
    if (shouldThrow) throw Exception('save failed');
    _watchlists = List<Watchlist>.from(watchlists);
  }

  @override
  Future<void> saveSelectedWatchlistId(String id) async {
    _selectedId = id;
  }
}

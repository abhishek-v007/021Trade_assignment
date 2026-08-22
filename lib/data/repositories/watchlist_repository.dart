import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/watchlist.dart';

abstract class WatchlistRepository {
  Future<List<Watchlist>> loadWatchlists();
  Future<String?> loadSelectedWatchlistId();
  Future<void> saveWatchlists(List<Watchlist> watchlists);
  Future<void> saveSelectedWatchlistId(String id);
}

class WatchlistRepositoryImpl implements WatchlistRepository {
  WatchlistRepositoryImpl({
    SharedPreferences? prefs,
    Uuid? uuid,
  })  : _prefsOverride = prefs,
        _uuid = uuid ?? const Uuid();

  static const _watchlistsKey = 'watchlists_v1';
  static const _selectedKey = 'selected_watchlist_id_v1';

  final SharedPreferences? _prefsOverride;
  final Uuid _uuid;

  Future<SharedPreferences> get _prefs async {
    if (_prefsOverride != null) return _prefsOverride!;
    return SharedPreferences.getInstance();
  }

  @override
  Future<List<Watchlist>> loadWatchlists() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_watchlistsKey);
    if (raw == null || raw.isEmpty) {
      return [_defaultWatchlist()];
    }
    try {
      final list = (jsonDecode(raw) as List<dynamic>)
          .map((e) => Watchlist.fromJson(e as Map<String, dynamic>))
          .toList();
      if (list.isEmpty) return [_defaultWatchlist()];
      return list;
    } catch (_) {
      return [_defaultWatchlist()];
    }
  }

  @override
  Future<String?> loadSelectedWatchlistId() async {
    final prefs = await _prefs;
    return prefs.getString(_selectedKey);
  }

  @override
  Future<void> saveWatchlists(List<Watchlist> watchlists) async {
    final prefs = await _prefs;
    final encoded =
        jsonEncode(watchlists.map((w) => w.toJson()).toList(growable: false));
    await prefs.setString(_watchlistsKey, encoded);
  }

  @override
  Future<void> saveSelectedWatchlistId(String id) async {
    final prefs = await _prefs;
    await prefs.setString(_selectedKey, id);
  }

  Watchlist _defaultWatchlist() {
    return Watchlist(
      id: _uuid.v4(),
      name: 'My Watchlist',
      symbols: const ['RELIANCE', 'TCS', 'INFY', 'HDFCBANK', 'ICICIBANK'],
    );
  }

  String newId() => _uuid.v4();
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/portfolio.dart';

abstract class PortfolioRepository {
  Future<Portfolio> load();
  Future<void> save(Portfolio portfolio);
}

class PortfolioRepositoryImpl implements PortfolioRepository {
  PortfolioRepositoryImpl({SharedPreferences? prefs}) : _prefsOverride = prefs;

  static const _key = 'portfolio_v1';

  final SharedPreferences? _prefsOverride;

  Future<SharedPreferences> get _prefs async {
    if (_prefsOverride != null) return _prefsOverride!;
    return SharedPreferences.getInstance();
  }

  @override
  Future<Portfolio> load() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return Portfolio.initial();
    }
    try {
      return Portfolio.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return Portfolio.initial();
    }
  }

  @override
  Future<void> save(Portfolio portfolio) async {
    final prefs = await _prefs;
    await prefs.setString(_key, jsonEncode(portfolio.toJson()));
  }
}

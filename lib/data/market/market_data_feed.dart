import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../core/money.dart';
import '../../core/stock_universe.dart';
import '../models/stock_quote.dart';

/// Configurable tick rate for the mock market feed.
///
/// Raise [ticksPerSecondPerStock] for stress testing
/// (e.g. 5 → 50+ ticks/sec overall across 10 stocks).
class MarketFeedConfig {
  /// Ticks emitted per second **per stock**.
  final double ticksPerSecondPerStock;

  /// Max absolute move per tick as a fraction of LTP (e.g. 0.002 = 0.2%).
  final double maxMoveFraction;

  final String label;

  const MarketFeedConfig({
    this.ticksPerSecondPerStock = 0.5,
    this.maxMoveFraction = 0.002,
    this.label = 'Normal',
  });

  /// Calm / realistic daytime tape (~5 ticks/sec overall).
  static const normal = MarketFeedConfig(
    ticksPerSecondPerStock: 0.5,
    maxMoveFraction: 0.002,
    label: 'Normal',
  );

  /// Busier tape (~20 ticks/sec overall).
  static const busy = MarketFeedConfig(
    ticksPerSecondPerStock: 2,
    maxMoveFraction: 0.0025,
    label: 'Busy',
  );

  /// Stress profile: 5 ticks/sec/stock ≈ 50 ticks/sec overall.
  static const stress = MarketFeedConfig(
    ticksPerSecondPerStock: 5,
    maxMoveFraction: 0.003,
    label: 'Stress',
  );

  static const List<MarketFeedConfig> presets = [normal, busy, stress];

  /// Approximate ticks per second across the whole universe.
  double get overallTicksPerSecond =>
      ticksPerSecondPerStock * StockUniverse.all.length;

  Duration get tickInterval {
    final overallMs = 1000 / overallTicksPerSecond;
    return Duration(milliseconds: max(8, overallMs.round()));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketFeedConfig &&
          ticksPerSecondPerStock == other.ticksPerSecondPerStock &&
          maxMoveFraction == other.maxMoveFraction &&
          label == other.label;

  @override
  int get hashCode => Object.hash(ticksPerSecondPerStock, maxMoveFraction, label);
}

/// Single source of truth for live prices across the entire app.
///
/// Each symbol has a [ValueNotifier] so UI rows/cells rebuild independently
/// without rebuilding the whole list on every tick.
class MarketDataFeed {
  MarketDataFeed({
    MarketFeedConfig config = MarketFeedConfig.normal,
    Random? random,
  })  : _config = ValueNotifier(config),
        _random = random ?? Random() {
    for (final info in StockUniverse.all) {
      _quotes[info.symbol] = ValueNotifier(
        StockQuote.seed(symbol: info.symbol, price: info.startingPrice),
      );
    }
  }

  final ValueNotifier<MarketFeedConfig> _config;
  final Random _random;
  final Map<String, ValueNotifier<StockQuote>> _quotes = {};
  Timer? _timer;
  int _roundRobin = 0;
  bool _running = false;

  MarketFeedConfig get config => _config.value;

  ValueListenable<MarketFeedConfig> get configListenable => _config;

  ValueListenable<StockQuote> listenable(String symbol) {
    final n = _quotes[symbol];
    if (n == null) {
      throw ArgumentError.value(symbol, 'symbol', 'Unknown stock');
    }
    return n;
  }

  StockQuote quote(String symbol) => listenable(symbol).value;

  Map<String, StockQuote> get allQuotes => {
        for (final e in _quotes.entries) e.key: e.value.value,
      };

  void updateConfig(MarketFeedConfig config) {
    if (_config.value == config) return;
    _config.value = config;
    if (_running) {
      stop();
      start();
    }
  }

  void start() {
    if (_running) return;
    _running = true;
    _schedule();
  }

  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
    _config.dispose();
    for (final n in _quotes.values) {
      n.dispose();
    }
    _quotes.clear();
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(config.tickInterval, _onTick);
  }

  void _onTick() {
    if (!_running) return;

    final symbols = StockUniverse.symbols;
    final symbol = symbols[_roundRobin % symbols.length];
    _roundRobin++;

    _emitTick(symbol);
    _schedule();
  }

  void _emitTick(String symbol) {
    final current = _quotes[symbol]!.value;
    final maxMove = (current.ltp.paise * config.maxMoveFraction).round();
    final delta = maxMove == 0
        ? (_random.nextBool() ? 1 : -1)
        : _random.nextInt(maxMove * 2 + 1) - maxMove;
    final applied = delta == 0 ? (_random.nextBool() ? 1 : -1) : delta;
    final newPaise = max(1, current.ltp.paise + applied);
    _quotes[symbol]!.value = current.withLtp(Money(newPaise));
  }

  /// Test helper: push an explicit LTP without waiting for the timer.
  @visibleForTesting
  void debugSetLtp(String symbol, Money ltp) {
    final current = _quotes[symbol]!.value;
    _quotes[symbol]!.value = current.withLtp(ltp);
  }
}

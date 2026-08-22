import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist_app/core/money.dart';
import 'package:watchlist_app/core/stock_universe.dart';
import 'package:watchlist_app/data/market/market_data_feed.dart';

void main() {
  group('MarketFeedConfig', () {
    test('stress preset is at least 50 ticks/sec overall', () {
      expect(MarketFeedConfig.stress.overallTicksPerSecond, greaterThanOrEqualTo(50));
      expect(MarketFeedConfig.stress.ticksPerSecondPerStock, greaterThanOrEqualTo(5));
    });

    test('tick interval is never below 8ms', () {
      expect(
        MarketFeedConfig.stress.tickInterval.inMilliseconds,
        greaterThanOrEqualTo(8),
      );
    });
  });

  group('MarketDataFeed', () {
    test('exposes a notifier for every universe symbol', () {
      final feed = MarketDataFeed();
      for (final symbol in StockUniverse.symbols) {
        expect(feed.quote(symbol).symbol, symbol);
        expect(feed.quote(symbol).ltp.paise, greaterThan(0));
      }
      feed.dispose();
    });

    test('debugSetLtp updates only that symbol', () {
      final feed = MarketDataFeed();
      final beforeTcs = feed.quote('TCS').ltp;
      feed.debugSetLtp('RELIANCE', const Money(999900));
      expect(feed.quote('RELIANCE').ltp.paise, 999900);
      expect(feed.quote('TCS').ltp, beforeTcs);
      feed.dispose();
    });

    test('updateConfig switches to stress preset', () {
      final feed = MarketDataFeed();
      feed.updateConfig(MarketFeedConfig.stress);
      expect(feed.config, MarketFeedConfig.stress);
      feed.dispose();
    });
  });
}

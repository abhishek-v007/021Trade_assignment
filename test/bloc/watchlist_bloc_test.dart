import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist_app/bloc/watchlist/watchlist_bloc.dart';
import 'package:watchlist_app/data/models/stock.dart';

import 'mock_watchlist_repository.dart';

void main() {
  late MockWatchlistRepository repository;

  setUp(() {
    repository = MockWatchlistRepository();
  });

  group('WatchlistBloc', () {
    test('initial state is WatchlistInitial', () {
      final bloc = WatchlistBloc(repository: repository);
      expect(bloc.state, isA<WatchlistInitial>());
      bloc.close();
    });

    blocTest<WatchlistBloc, WatchlistState>(
      'emits [Loading, Loaded] on WatchlistLoadRequested success',
      build: () => WatchlistBloc(repository: repository),
      act: (bloc) => bloc.add(const WatchlistLoadRequested()),
      expect: () => [
        isA<WatchlistLoading>(),
        isA<WatchlistLoaded>(),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'emits [Loading, Error] on WatchlistLoadRequested failure',
      build: () => WatchlistBloc(
        repository: MockWatchlistRepository(shouldThrow: true),
      ),
      act: (bloc) => bloc.add(const WatchlistLoadRequested()),
      expect: () => [
        isA<WatchlistLoading>(),
        isA<WatchlistError>(),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'WatchlistLoaded contains correct stock count after load',
      build: () => WatchlistBloc(repository: repository),
      act: (bloc) => bloc.add(const WatchlistLoadRequested()),
      verify: (bloc) {
        final state = bloc.state as WatchlistLoaded;
        expect(state.watchlist.stocks.length, equals(mockStocks.length));
      },
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'emits reordered watchlist on WatchlistStockReordered',
      build: () => WatchlistBloc(repository: repository),
      seed: () => WatchlistLoaded(watchlist: mockWatchlist),
      act: (bloc) => bloc.add(
        const WatchlistStockReordered(oldIndex: 0, newIndex: 2),
      ),
      verify: (bloc) {
        final state = bloc.state as WatchlistLoaded;
        expect(state.watchlist.stocks.first.symbol, equals('TCS'));
        expect(state.watchlist.stocks[1].symbol, equals('RELIANCE'));
      },
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'does nothing on reorder when state is not WatchlistLoaded',
      build: () => WatchlistBloc(repository: repository),
      act: (bloc) => bloc.add(
        const WatchlistStockReordered(oldIndex: 0, newIndex: 1),
      ),
      expect: () => <WatchlistState>[],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'emits watchlist with one fewer stock on WatchlistStockRemoved',
      build: () => WatchlistBloc(repository: repository),
      seed: () => WatchlistLoaded(watchlist: mockWatchlist),
      act: (bloc) => bloc.add(
        const WatchlistStockRemoved(stockId: '1'),
      ),
      verify: (bloc) {
        final state = bloc.state as WatchlistLoaded;
        expect(state.watchlist.stocks.length, equals(mockStocks.length - 1));
        expect(
          state.watchlist.stocks.any((s) => s.id == '1'),
          isFalse,
        );
      },
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'emits [Loading, Loaded] on WatchlistRefreshRequested from initial',
      build: () => WatchlistBloc(repository: repository),
      act: (bloc) => bloc.add(const WatchlistRefreshRequested()),
      expect: () => [
        isA<WatchlistLoading>(),
        isA<WatchlistLoaded>(),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'preserves loaded state during refresh then emits fresh data',
      build: () => WatchlistBloc(repository: repository),
      seed: () => WatchlistLoaded(watchlist: mockWatchlist),
      act: (bloc) => bloc.add(const WatchlistRefreshRequested()),
      expect: () => [
        isA<WatchlistLoaded>(),
        isA<WatchlistLoaded>(),
      ],
    );
  });

  group('Watchlist model reorder logic', () {
    test('reorderStock moves item correctly (forward)', () {
      final reordered = mockWatchlist.reorderStock(0, 2);
      expect(reordered.stocks[0].symbol, equals('TCS'));
      expect(reordered.stocks[1].symbol, equals('RELIANCE'));
      expect(reordered.stocks[2].symbol, equals('INFY'));
    });

    test('reorderStock moves item correctly (backward)', () {
      final reordered = mockWatchlist.reorderStock(2, 0);
      expect(reordered.stocks[0].symbol, equals('INFY'));
      expect(reordered.stocks[1].symbol, equals('RELIANCE'));
      expect(reordered.stocks[2].symbol, equals('TCS'));
    });

    test('removeStock removes correct item', () {
      final updated = mockWatchlist.removeStock('2');
      expect(updated.stocks.length, equals(2));
      expect(updated.stocks.any((s) => s.symbol == 'TCS'), isFalse);
    });
  });

  group('Stock model', () {
    const stock = Stock(
      id: 'test',
      symbol: 'TEST',
      companyName: 'Test Corp',
      currentPrice: 100.50,
      changeAmount: 2.30,
      changePercent: 2.34,
      trend: StockTrend.up,
      logoAsset: '',
      openPrice: 98.20,
      highPrice: 101.00,
      lowPrice: 97.80,
      volume: 1500000,
    );

    test('formattedPrice formats correctly', () {
      expect(stock.formattedPrice, equals('₹100.50'));
    });

    test('formattedChangePercent is positive for up trend', () {
      expect(stock.formattedChangePercent, startsWith('+'));
    });

    test('isPositive is true for up trend', () {
      expect(stock.isPositive, isTrue);
      expect(stock.isNegative, isFalse);
    });

    test('formattedVolume returns Lakh notation for 1.5M', () {
      expect(stock.formattedVolume, equals('15.00L'));
    });
  });
}

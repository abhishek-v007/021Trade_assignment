import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:watchlist_app/bloc/watchlist/watchlist_bloc.dart';
import 'package:watchlist_app/core/money.dart';
import 'package:watchlist_app/data/models/watchlist.dart';

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
      'emits [Loading, Loaded] on WatchlistLoadRequested',
      build: () => WatchlistBloc(repository: repository),
      act: (bloc) => bloc.add(const WatchlistLoadRequested()),
      expect: () => [
        isA<WatchlistLoading>(),
        isA<WatchlistLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as WatchlistLoaded;
        expect(state.selected.symbols, ['RELIANCE', 'TCS', 'INFY']);
      },
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'emits Error when load fails',
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
      'creates a new empty watchlist and selects it',
      build: () => WatchlistBloc(
        repository: repository,
        uuid: const Uuid(),
      ),
      seed: () => const WatchlistLoaded(
        watchlists: [
          Watchlist(id: 'wl_1', name: 'My Watchlist', symbols: ['TCS']),
        ],
        selectedId: 'wl_1',
      ),
      act: (bloc) => bloc.add(const WatchlistCreated('Banks')),
      verify: (bloc) {
        final state = bloc.state as WatchlistLoaded;
        expect(state.watchlists.length, 2);
        expect(state.selected.name, 'Banks');
        expect(state.selected.symbols, isEmpty);
      },
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'renames the selected watchlist',
      build: () => WatchlistBloc(repository: repository),
      seed: () => const WatchlistLoaded(
        watchlists: [
          Watchlist(id: 'wl_1', name: 'Old', symbols: []),
        ],
        selectedId: 'wl_1',
      ),
      act: (bloc) => bloc.add(
        const WatchlistRenamed(watchlistId: 'wl_1', name: 'New Name'),
      ),
      verify: (bloc) {
        final state = bloc.state as WatchlistLoaded;
        expect(state.selected.name, 'New Name');
      },
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'deletes a watchlist when more than one exists',
      build: () => WatchlistBloc(repository: repository),
      seed: () => const WatchlistLoaded(
        watchlists: [
          Watchlist(id: 'wl_1', name: 'A', symbols: []),
          Watchlist(id: 'wl_2', name: 'B', symbols: []),
        ],
        selectedId: 'wl_1',
      ),
      act: (bloc) => bloc.add(const WatchlistDeleted('wl_1')),
      verify: (bloc) {
        final state = bloc.state as WatchlistLoaded;
        expect(state.watchlists.length, 1);
        expect(state.selectedId, 'wl_2');
      },
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'does not delete the last watchlist',
      build: () => WatchlistBloc(repository: repository),
      seed: () => const WatchlistLoaded(
        watchlists: [
          Watchlist(id: 'wl_1', name: 'Only', symbols: []),
        ],
        selectedId: 'wl_1',
      ),
      act: (bloc) => bloc.add(const WatchlistDeleted('wl_1')),
      expect: () => <WatchlistState>[],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'adds a stock to the selected watchlist',
      build: () => WatchlistBloc(repository: repository),
      seed: () => const WatchlistLoaded(
        watchlists: [
          Watchlist(id: 'wl_1', name: 'A', symbols: ['TCS']),
        ],
        selectedId: 'wl_1',
      ),
      act: (bloc) => bloc.add(const WatchlistStockAdded('SBIN')),
      verify: (bloc) {
        final state = bloc.state as WatchlistLoaded;
        expect(state.selected.symbols, ['TCS', 'SBIN']);
      },
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'ignores duplicate stock add',
      build: () => WatchlistBloc(repository: repository),
      seed: () => const WatchlistLoaded(
        watchlists: [
          Watchlist(id: 'wl_1', name: 'A', symbols: ['TCS']),
        ],
        selectedId: 'wl_1',
      ),
      act: (bloc) => bloc.add(const WatchlistStockAdded('TCS')),
      expect: () => <WatchlistState>[],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'removes a stock',
      build: () => WatchlistBloc(repository: repository),
      seed: () => const WatchlistLoaded(
        watchlists: [
          Watchlist(id: 'wl_1', name: 'A', symbols: ['TCS', 'INFY']),
        ],
        selectedId: 'wl_1',
      ),
      act: (bloc) => bloc.add(const WatchlistStockRemoved('TCS')),
      verify: (bloc) {
        final state = bloc.state as WatchlistLoaded;
        expect(state.selected.symbols, ['INFY']);
      },
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'reorders stocks by symbol (binding stays on symbol)',
      build: () => WatchlistBloc(repository: repository),
      seed: () => const WatchlistLoaded(
        watchlists: [
          Watchlist(
            id: 'wl_1',
            name: 'A',
            symbols: ['RELIANCE', 'TCS', 'INFY'],
          ),
        ],
        selectedId: 'wl_1',
      ),
      act: (bloc) => bloc.add(
        const WatchlistStockReordered(oldIndex: 0, newIndex: 2),
      ),
      verify: (bloc) {
        final state = bloc.state as WatchlistLoaded;
        expect(state.selected.symbols, ['TCS', 'RELIANCE', 'INFY']);
      },
    );
  });

  group('Watchlist model', () {
    test('reorderSymbol moves forward correctly', () {
      const wl = Watchlist(
        id: '1',
        name: 'A',
        symbols: ['RELIANCE', 'TCS', 'INFY'],
      );
      expect(wl.reorderSymbol(0, 2).symbols, ['TCS', 'RELIANCE', 'INFY']);
    });

    test('reorderSymbol moves backward correctly', () {
      const wl = Watchlist(
        id: '1',
        name: 'A',
        symbols: ['RELIANCE', 'TCS', 'INFY'],
      );
      expect(wl.reorderSymbol(2, 0).symbols, ['INFY', 'RELIANCE', 'TCS']);
    });
  });

  group('Money', () {
    test('formats without floating drift', () {
      expect(const Money(10050).formatted, '₹100.50');
      expect(const Money(-125).formatted, '-₹1.25');
      expect(Money.fromRupees(2843.50).paise, 284350);
    });

    test('percentOf is precise for typical moves', () {
      const change = Money(162);
      const basis = Money(10000);
      expect(change.percentOf(basis), closeTo(1.62, 0.0001));
    });
  });
}

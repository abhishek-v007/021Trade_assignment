import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist_app/bloc/portfolio/portfolio_bloc.dart';
import 'package:watchlist_app/core/money.dart';
import 'package:watchlist_app/data/models/order.dart';
import 'package:watchlist_app/data/models/portfolio.dart';
import 'package:watchlist_app/data/repositories/portfolio_repository.dart';

class _MemoryPortfolioRepository implements PortfolioRepository {
  Portfolio stored = Portfolio.initial();

  @override
  Future<Portfolio> load() async => stored;

  @override
  Future<void> save(Portfolio portfolio) async {
    stored = portfolio;
  }
}

void main() {
  late _MemoryPortfolioRepository repository;

  setUp(() {
    repository = _MemoryPortfolioRepository();
  });

  group('PortfolioBloc', () {
    blocTest<PortfolioBloc, PortfolioState>(
      'loads portfolio',
      build: () => PortfolioBloc(repository: repository),
      act: (bloc) => bloc.add(const PortfolioLoadRequested()),
      expect: () => [
        isA<PortfolioLoading>(),
        isA<PortfolioReady>(),
      ],
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'successful buy sets lastOrder and persists',
      build: () => PortfolioBloc(repository: repository),
      seed: () => PortfolioReady(portfolio: Portfolio.initial()),
      act: (bloc) => bloc.add(
        PortfolioOrderSubmitted(
          symbol: 'TCS',
          side: OrderSide.buy,
          quantityText: '1',
          ltpAtSubmit: Money.fromRupees(1000),
        ),
      ),
      verify: (bloc) {
        final state = bloc.state as PortfolioReady;
        expect(state.lastOrder, isNotNull);
        expect(state.lastOrder!.symbol, 'TCS');
        expect(state.portfolio.quantityHeld('TCS'), 1);
        expect(
          state.portfolio.cashBalance,
          Portfolio.defaultCash - Money.fromRupees(1000),
        );
        expect(repository.stored.quantityHeld('TCS'), 1);
      },
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'insufficient funds sets submitError',
      build: () => PortfolioBloc(repository: repository),
      seed: () => PortfolioReady(portfolio: Portfolio.initial()),
      act: (bloc) => bloc.add(
        PortfolioOrderSubmitted(
          symbol: 'RELIANCE',
          side: OrderSide.buy,
          quantityText: '10000',
          ltpAtSubmit: Money.fromRupees(2800),
        ),
      ),
      verify: (bloc) {
        final state = bloc.state as PortfolioReady;
        expect(state.submitError, contains('Insufficient balance'));
        expect(state.lastOrder, isNull);
      },
    );
  });
}

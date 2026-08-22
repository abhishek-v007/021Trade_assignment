import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../core/money.dart';
import '../../data/models/order.dart';
import '../../data/models/portfolio.dart';
import '../../data/portfolio/order_executor.dart';
import '../../data/repositories/portfolio_repository.dart';

part 'portfolio_event.dart';
part 'portfolio_state.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  PortfolioBloc({
    required PortfolioRepository repository,
    OrderExecutor executor = const OrderExecutor(),
    Uuid? uuid,
  })  : _repository = repository,
        _executor = executor,
        _uuid = uuid ?? const Uuid(),
        super(const PortfolioInitial()) {
    on<PortfolioLoadRequested>(_onLoad);
    on<PortfolioOrderSubmitted>(_onOrderSubmitted);
    on<PortfolioSubmitAckCleared>(_onAckCleared);
  }

  final PortfolioRepository _repository;
  final OrderExecutor _executor;
  final Uuid _uuid;

  Future<void> _onLoad(
    PortfolioLoadRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(const PortfolioLoading());
    try {
      final portfolio = await _repository.load();
      emit(PortfolioReady(portfolio: portfolio));
    } catch (e) {
      emit(PortfolioError('Failed to load portfolio: $e'));
    }
  }

  Future<void> _onOrderSubmitted(
    PortfolioOrderSubmitted event,
    Emitter<PortfolioState> emit,
  ) async {
    final current = state;
    if (current is! PortfolioReady) return;

    final error = _executor.validate(
      portfolio: current.portfolio,
      symbol: event.symbol,
      side: event.side,
      quantityText: event.quantityText,
      ltp: event.ltpAtSubmit,
    );

    if (error != null) {
      emit(current.copyWith(submitError: error, clearLastOrder: true));
      return;
    }

    try {
      final result = _executor.place(
        portfolio: current.portfolio,
        id: _uuid.v4(),
        symbol: event.symbol,
        side: event.side,
        quantityText: event.quantityText,
        ltp: event.ltpAtSubmit,
      );
      await _repository.save(result.portfolio);
      emit(
        PortfolioReady(
          portfolio: result.portfolio,
          lastOrder: result.order,
        ),
      );
    } on OrderValidationException catch (e) {
      emit(current.copyWith(submitError: e.message, clearLastOrder: true));
    } catch (e) {
      emit(
        current.copyWith(
          submitError: 'Order failed: $e',
          clearLastOrder: true,
        ),
      );
    }
  }

  void _onAckCleared(
    PortfolioSubmitAckCleared event,
    Emitter<PortfolioState> emit,
  ) {
    final current = state;
    if (current is! PortfolioReady) return;
    emit(current.copyWith(clearLastOrder: true, clearSubmitError: true));
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/watchlist.dart';
import '../../data/repositories/watchlist_repository.dart';

part 'watchlist_event.dart';
part 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final WatchlistRepository _repository;

  WatchlistBloc({required WatchlistRepository repository})
      : _repository = repository,
        super(const WatchlistInitial()) {
    on<WatchlistLoadRequested>(_onLoadRequested);
    on<WatchlistStockReordered>(_onStockReordered);
    on<WatchlistStockRemoved>(_onStockRemoved);
    on<WatchlistRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    WatchlistLoadRequested event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(const WatchlistLoading());
    try {
      final watchlist = await _repository.fetchWatchlist();
      emit(WatchlistLoaded(watchlist: watchlist));
    } catch (e) {
      emit(WatchlistError(message: 'Failed to load watchlist: ${e.toString()}'));
    }
  }

  Future<void> _onStockReordered(
    WatchlistStockReordered event,
    Emitter<WatchlistState> emit,
  ) async {
    final currentState = state;
    if (currentState is! WatchlistLoaded) return;

    final reorderedWatchlist = await _repository.reorderStock(
      currentState.watchlist,
      event.oldIndex,
      event.newIndex,
    );

    emit(currentState.copyWith(watchlist: reorderedWatchlist));
  }

  Future<void> _onStockRemoved(
    WatchlistStockRemoved event,
    Emitter<WatchlistState> emit,
  ) async {
    final currentState = state;
    if (currentState is! WatchlistLoaded) return;

    final updatedWatchlist = await _repository.removeStock(
      currentState.watchlist,
      event.stockId,
    );

    emit(currentState.copyWith(watchlist: updatedWatchlist));
  }

  Future<void> _onRefreshRequested(
    WatchlistRefreshRequested event,
    Emitter<WatchlistState> emit,
  ) async {
    final currentState = state;
    if (currentState is WatchlistLoaded) {
      emit(currentState.copyWith(isReordering: false));
    } else {
      emit(const WatchlistLoading());
    }

    try {
      final watchlist = await _repository.fetchWatchlist();
      emit(WatchlistLoaded(watchlist: watchlist));
    } catch (e) {
      emit(WatchlistError(message: 'Failed to refresh watchlist: ${e.toString()}'));
    }
  }
}

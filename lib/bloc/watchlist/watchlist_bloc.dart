import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../core/stock_universe.dart';
import '../../data/models/watchlist.dart';
import '../../data/repositories/watchlist_repository.dart';

part 'watchlist_event.dart';
part 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  WatchlistBloc({
    required WatchlistRepository repository,
    Uuid? uuid,
  })  : _repository = repository,
        _uuid = uuid ?? const Uuid(),
        super(const WatchlistInitial()) {
    on<WatchlistLoadRequested>(_onLoad);
    on<WatchlistSelected>(_onSelected);
    on<WatchlistCreated>(_onCreated);
    on<WatchlistRenamed>(_onRenamed);
    on<WatchlistDeleted>(_onDeleted);
    on<WatchlistStockAdded>(_onStockAdded);
    on<WatchlistStockRemoved>(_onStockRemoved);
    on<WatchlistStockReordered>(_onStockReordered);
  }

  final WatchlistRepository _repository;
  final Uuid _uuid;

  Future<void> _persist(WatchlistLoaded state) async {
    await _repository.saveWatchlists(state.watchlists);
    await _repository.saveSelectedWatchlistId(state.selectedId);
  }

  Future<void> _onLoad(
    WatchlistLoadRequested event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(const WatchlistLoading());
    try {
      final watchlists = await _repository.loadWatchlists();
      final savedId = await _repository.loadSelectedWatchlistId();
      final selectedId = watchlists.any((w) => w.id == savedId)
          ? savedId!
          : watchlists.first.id;
      final loaded = WatchlistLoaded(
        watchlists: watchlists,
        selectedId: selectedId,
      );
      emit(loaded);
      await _persist(loaded);
    } catch (e) {
      emit(WatchlistError(message: 'Failed to load watchlists: $e'));
    }
  }

  Future<void> _onSelected(
    WatchlistSelected event,
    Emitter<WatchlistState> emit,
  ) async {
    final current = state;
    if (current is! WatchlistLoaded) return;
    if (!current.watchlists.any((w) => w.id == event.watchlistId)) return;

    final next = current.copyWith(selectedId: event.watchlistId);
    emit(next);
    await _repository.saveSelectedWatchlistId(event.watchlistId);
  }

  Future<void> _onCreated(
    WatchlistCreated event,
    Emitter<WatchlistState> emit,
  ) async {
    final current = state;
    if (current is! WatchlistLoaded) return;

    final name = event.name.trim();
    if (name.isEmpty) return;

    final created = Watchlist(
      id: _uuid.v4(),
      name: name,
      symbols: const [],
    );
    final next = current.copyWith(
      watchlists: [...current.watchlists, created],
      selectedId: created.id,
    );
    emit(next);
    await _persist(next);
  }

  Future<void> _onRenamed(
    WatchlistRenamed event,
    Emitter<WatchlistState> emit,
  ) async {
    final current = state;
    if (current is! WatchlistLoaded) return;

    final name = event.name.trim();
    if (name.isEmpty) return;

    final next = current.copyWith(
      watchlists: current.watchlists
          .map(
            (w) => w.id == event.watchlistId ? w.copyWith(name: name) : w,
          )
          .toList(growable: false),
    );
    emit(next);
    await _persist(next);
  }

  Future<void> _onDeleted(
    WatchlistDeleted event,
    Emitter<WatchlistState> emit,
  ) async {
    final current = state;
    if (current is! WatchlistLoaded) return;
    if (current.watchlists.length <= 1) return;

    final remaining = current.watchlists
        .where((w) => w.id != event.watchlistId)
        .toList(growable: false);
    if (remaining.length == current.watchlists.length) return;

    final selectedId = current.selectedId == event.watchlistId
        ? remaining.first.id
        : current.selectedId;

    final next = WatchlistLoaded(
      watchlists: remaining,
      selectedId: selectedId,
    );
    emit(next);
    await _persist(next);
  }

  Future<void> _onStockAdded(
    WatchlistStockAdded event,
    Emitter<WatchlistState> emit,
  ) async {
    final current = state;
    if (current is! WatchlistLoaded) return;
    if (!StockUniverse.contains(event.symbol)) return;

    final selected = current.selected;
    if (selected.contains(event.symbol)) return;

    final updated = selected.addSymbol(event.symbol);
    final next = current.copyWith(
      watchlists: current.watchlists
          .map((w) => w.id == selected.id ? updated : w)
          .toList(growable: false),
    );
    emit(next);
    await _persist(next);
  }

  Future<void> _onStockRemoved(
    WatchlistStockRemoved event,
    Emitter<WatchlistState> emit,
  ) async {
    final current = state;
    if (current is! WatchlistLoaded) return;

    final selected = current.selected;
    final updated = selected.removeSymbol(event.symbol);
    final next = current.copyWith(
      watchlists: current.watchlists
          .map((w) => w.id == selected.id ? updated : w)
          .toList(growable: false),
    );
    emit(next);
    await _persist(next);
  }

  Future<void> _onStockReordered(
    WatchlistStockReordered event,
    Emitter<WatchlistState> emit,
  ) async {
    final current = state;
    if (current is! WatchlistLoaded) return;

    final selected = current.selected;
    final updated = selected.reorderSymbol(event.oldIndex, event.newIndex);
    final next = current.copyWith(
      watchlists: current.watchlists
          .map((w) => w.id == selected.id ? updated : w)
          .toList(growable: false),
    );
    emit(next);
    await _persist(next);
  }
}

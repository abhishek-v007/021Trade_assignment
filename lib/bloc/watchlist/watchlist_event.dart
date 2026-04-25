part of 'watchlist_bloc.dart';

abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

class WatchlistLoadRequested extends WatchlistEvent {
  const WatchlistLoadRequested();
}

class WatchlistStockReordered extends WatchlistEvent {
  final int oldIndex;
  final int newIndex;

  const WatchlistStockReordered({
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class WatchlistStockRemoved extends WatchlistEvent {
  final String stockId;

  const WatchlistStockRemoved({required this.stockId});

  @override
  List<Object?> get props => [stockId];
}

class WatchlistRefreshRequested extends WatchlistEvent {
  const WatchlistRefreshRequested();
}

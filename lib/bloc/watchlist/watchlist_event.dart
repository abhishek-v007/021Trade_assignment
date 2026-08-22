part of 'watchlist_bloc.dart';

abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

class WatchlistLoadRequested extends WatchlistEvent {
  const WatchlistLoadRequested();
}

class WatchlistSelected extends WatchlistEvent {
  final String watchlistId;
  const WatchlistSelected(this.watchlistId);

  @override
  List<Object?> get props => [watchlistId];
}

class WatchlistCreated extends WatchlistEvent {
  final String name;
  const WatchlistCreated(this.name);

  @override
  List<Object?> get props => [name];
}

class WatchlistRenamed extends WatchlistEvent {
  final String watchlistId;
  final String name;
  const WatchlistRenamed({required this.watchlistId, required this.name});

  @override
  List<Object?> get props => [watchlistId, name];
}

class WatchlistDeleted extends WatchlistEvent {
  final String watchlistId;
  const WatchlistDeleted(this.watchlistId);

  @override
  List<Object?> get props => [watchlistId];
}

class WatchlistStockAdded extends WatchlistEvent {
  final String symbol;
  const WatchlistStockAdded(this.symbol);

  @override
  List<Object?> get props => [symbol];
}

class WatchlistStockRemoved extends WatchlistEvent {
  final String symbol;
  const WatchlistStockRemoved(this.symbol);

  @override
  List<Object?> get props => [symbol];
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

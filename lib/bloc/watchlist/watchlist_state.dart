part of 'watchlist_bloc.dart';

abstract class WatchlistState extends Equatable {
  const WatchlistState();

  @override
  List<Object?> get props => [];
}

class WatchlistInitial extends WatchlistState {
  const WatchlistInitial();
}

class WatchlistLoading extends WatchlistState {
  const WatchlistLoading();
}

class WatchlistLoaded extends WatchlistState {
  final Watchlist watchlist;
  final bool isReordering;

  const WatchlistLoaded({
    required this.watchlist,
    this.isReordering = false,
  });

  WatchlistLoaded copyWith({
    Watchlist? watchlist,
    bool? isReordering,
  }) {
    return WatchlistLoaded(
      watchlist: watchlist ?? this.watchlist,
      isReordering: isReordering ?? this.isReordering,
    );
  }

  @override
  List<Object?> get props => [watchlist, isReordering];
}

class WatchlistError extends WatchlistState {
  final String message;

  const WatchlistError({required this.message});

  @override
  List<Object?> get props => [message];
}

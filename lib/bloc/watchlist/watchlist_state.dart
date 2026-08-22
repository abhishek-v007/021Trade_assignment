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
  final List<Watchlist> watchlists;
  final String selectedId;

  const WatchlistLoaded({
    required this.watchlists,
    required this.selectedId,
  });

  Watchlist get selected {
    return watchlists.firstWhere(
      (w) => w.id == selectedId,
      orElse: () => watchlists.first,
    );
  }

  WatchlistLoaded copyWith({
    List<Watchlist>? watchlists,
    String? selectedId,
  }) {
    return WatchlistLoaded(
      watchlists: watchlists ?? this.watchlists,
      selectedId: selectedId ?? this.selectedId,
    );
  }

  @override
  List<Object?> get props => [watchlists, selectedId];
}

class WatchlistError extends WatchlistState {
  final String message;

  const WatchlistError({required this.message});

  @override
  List<Object?> get props => [message];
}

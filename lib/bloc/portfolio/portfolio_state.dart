part of 'portfolio_bloc.dart';

abstract class PortfolioState extends Equatable {
  const PortfolioState();

  @override
  List<Object?> get props => [];
}

class PortfolioInitial extends PortfolioState {
  const PortfolioInitial();
}

class PortfolioLoading extends PortfolioState {
  const PortfolioLoading();
}

class PortfolioReady extends PortfolioState {
  final Portfolio portfolio;

  /// Set after a successful submit; UI navigates then clears.
  final Order? lastOrder;

  /// Inline / snackbar error from last failed submit attempt.
  final String? submitError;

  const PortfolioReady({
    required this.portfolio,
    this.lastOrder,
    this.submitError,
  });

  PortfolioReady copyWith({
    Portfolio? portfolio,
    Order? lastOrder,
    String? submitError,
    bool clearLastOrder = false,
    bool clearSubmitError = false,
  }) {
    return PortfolioReady(
      portfolio: portfolio ?? this.portfolio,
      lastOrder: clearLastOrder ? null : (lastOrder ?? this.lastOrder),
      submitError:
          clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }

  @override
  List<Object?> get props => [portfolio, lastOrder, submitError];
}

class PortfolioError extends PortfolioState {
  final String message;
  const PortfolioError(this.message);

  @override
  List<Object?> get props => [message];
}

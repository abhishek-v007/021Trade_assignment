part of 'portfolio_bloc.dart';

abstract class PortfolioEvent extends Equatable {
  const PortfolioEvent();

  @override
  List<Object?> get props => [];
}

class PortfolioLoadRequested extends PortfolioEvent {
  const PortfolioLoadRequested();
}

class PortfolioOrderSubmitted extends PortfolioEvent {
  final String symbol;
  final OrderSide side;
  final String quantityText;
  final Money ltpAtSubmit;

  const PortfolioOrderSubmitted({
    required this.symbol,
    required this.side,
    required this.quantityText,
    required this.ltpAtSubmit,
  });

  @override
  List<Object?> get props => [symbol, side, quantityText, ltpAtSubmit];
}

class PortfolioSubmitAckCleared extends PortfolioEvent {
  const PortfolioSubmitAckCleared();
}

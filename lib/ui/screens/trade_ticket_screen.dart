import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/portfolio/portfolio_bloc.dart';
import '../../core/money.dart';
import '../../core/stock_universe.dart';
import '../../data/market/market_data_feed.dart';
import '../../data/models/order.dart';
import '../../data/models/stock_quote.dart';
import '../theme/app_theme.dart';
import 'order_confirmation_screen.dart';

class TradeTicketScreen extends StatefulWidget {
  final String symbol;
  final OrderSide initialSide;

  const TradeTicketScreen({
    super.key,
    required this.symbol,
    this.initialSide = OrderSide.buy,
  });

  @override
  State<TradeTicketScreen> createState() => _TradeTicketScreenState();
}

class _TradeTicketScreenState extends State<TradeTicketScreen> {
  late OrderSide _side;
  final _qtyController = TextEditingController(text: '1');
  String? _localError;

  @override
  void initState() {
    super.initState();
    _side = widget.initialSide;
    _qtyController.addListener(() {
      if (_localError != null) setState(() => _localError = null);
      setState(() {}); // refresh projected value
    });
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  int? get _parsedQty {
    final t = _qtyController.text.trim();
    if (t.isEmpty || t.contains('.') || t.contains(',')) return null;
    return int.tryParse(t);
  }

  void _submit(Money ltp) {
    FocusScope.of(context).unfocus();
    setState(() => _localError = null);

    context.read<PortfolioBloc>().add(
          PortfolioOrderSubmitted(
            symbol: widget.symbol,
            side: _side,
            quantityText: _qtyController.text,
            ltpAtSubmit: ltp,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.read<MarketDataFeed>();
    final company = StockUniverse.companyName(widget.symbol);

    return BlocConsumer<PortfolioBloc, PortfolioState>(
      listenWhen: (prev, next) {
        if (next is! PortfolioReady) return false;
        if (next.lastOrder != null) return true;
        if (next.submitError != null) {
          final prevErr =
              prev is PortfolioReady ? prev.submitError : null;
          return next.submitError != prevErr;
        }
        return false;
      },
      listener: (context, state) {
        if (state is! PortfolioReady) return;

        if (state.lastOrder != null) {
          final order = state.lastOrder!;
          context.read<PortfolioBloc>().add(const PortfolioSubmitAckCleared());
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => OrderConfirmationScreen(order: order),
            ),
          );
          return;
        }

        if (state.submitError != null) {
          setState(() => _localError = state.submitError);
        }
      },
      builder: (context, state) {
        final portfolio =
            state is PortfolioReady ? state.portfolio : null;
        final held = portfolio?.quantityHeld(widget.symbol) ?? 0;
        final cash = portfolio?.cashBalance;

        return Scaffold(
          backgroundColor: AppTheme.primaryDark,
          appBar: AppBar(
            backgroundColor: AppTheme.primaryDark,
            title: const Text('Buy / Sell'),
          ),
          body: ValueListenableBuilder<StockQuote>(
            valueListenable: feed.listenable(widget.symbol),
            builder: (context, quote, _) {
              final qty = _parsedQty;
              final projected =
                  qty != null && qty > 0 ? quote.ltp * qty : null;

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    widget.symbol,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    company,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _InfoCard(
                    children: [
                      _InfoRow(label: 'Live LTP', value: quote.ltp.formatted),
                      const SizedBox(height: 10),
                      _InfoRow(
                        label: 'Available cash',
                        value: cash?.formatted ?? '—',
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        label: 'Qty held',
                        value: '$held',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Side',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<OrderSide>(
                    segments: const [
                      ButtonSegment(
                        value: OrderSide.buy,
                        label: Text('Buy'),
                        icon: Icon(Icons.trending_up_rounded, size: 18),
                      ),
                      ButtonSegment(
                        value: OrderSide.sell,
                        label: Text('Sell'),
                        icon: Icon(Icons.trending_down_rounded, size: 18),
                      ),
                    ],
                    selected: {_side},
                    onSelectionChanged: (s) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _side = s.first;
                        _localError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Quantity',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.cardDark,
                      hintText: 'Whole shares only',
                      hintStyle: const TextStyle(color: AppTheme.textMuted),
                      errorText: _localError,
                      errorMaxLines: 3,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.accent),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.lossRed),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _InfoCard(
                    children: [
                      _InfoRow(
                        label: 'Order value',
                        value: projected?.formatted ?? '—',
                        emphasize: true,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'qty × LTP at submission',
                        style: TextStyle(
                          color: AppTheme.textMuted.withValues(alpha: 0.9),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _submit(quote.ltp),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _side == OrderSide.buy
                            ? AppTheme.gainGreen
                            : AppTheme.lossRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '${_side.label} ${widget.symbol}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _InfoRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: emphasize ? 20 : 15,
            fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

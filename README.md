# 021 Trade — Flutter Trading App

Flutter trading assignment. **All 4 features** are implemented.

## Run

```bash
flutter pub get
flutter run
```

Requirements: Flutter stable, Dart 3.0+.

```bash
flutter test
```

## Stocks

`RELIANCE`, `TCS`, `INFY`, `HDFCBANK`, `ICICIBANK`, `SBIN`, `ITC`, `LT`, `BHARTIARTL`, `AXISBANK`

## Feature 1 — Watchlists

Multiple watchlists (create / rename / delete), stock picker, drag reorder, swipe remove, live prices, persistence, tap → trade ticket.

## Feature 2 — Live Prices Mimic

Live Prices tab for all 10 stocks, green/red flash, shared `MarketDataFeed` with Normal / Busy / **Stress** tick rates.

## Feature 3 — Buy/Sell Ticket

Buy/Sell + qty, live LTP & order value, cash / holdings checks, execute at submit LTP, confirmation, persist wallet + orders + holdings. Starting cash **₹1,00,000.00**.

## Feature 4 — Holdings

- List: symbol, qty, avg cost, LTP, current value, P&L ₹ / %
- Live P&L per row as ticks arrive
- Sort: **P&L ↓** (default), Symbol, Value
- Aggregate summary: invested, current, total P&L ₹ / % (= sum of rows)
- Tap row → trade ticket; empty state; holdings persist via portfolio store

### Demo path

1. Live Prices / Watchlist → Buy a few stocks  
2. Open **Holdings** — see live P&L  
3. Switch sort to P&L and watch rows reorder as prices move  
4. Sell to zero → row disappears  

## Architecture

- Single `MarketDataFeed` for all prices (per-symbol `ValueNotifier`)
- Watchlists store symbols only
- `PortfolioBloc` + `OrderExecutor` for cash / holdings / orders
- Money in integer **paise**

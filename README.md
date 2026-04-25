# 📊 021 Trade — Stock Watchlist (Flutter BLoC)

A clean and production-ready Flutter implementation of a draggable stock watchlist built using the BLoC (Business Logic Component) pattern.

I tried to keep things modular, testable, and close to real-world architecture — while still focusing on smooth UI/UX interactions.

---

## Features

* Drag-to-reorder stocks using `ReorderableListView` (with haptic feedback)
* Swipe-to-remove items with a snackbar undo-style confirmation *(basic for now)*
* Shimmer loading UI while fetching data (staggered effect)
* Watchlist stats header (total, gainers, losers)
* Animated drag item (slight elevation + glow)
* Error state with retry button
* Empty state when list becomes blank
* Dark theme

---

## Project Structure

```
lib/
├── data/
│   ├── models/
│   │   ├── stock.dart
│   │   └── watchlist.dart
│   └── repositories/
│       └── watchlist_repository.dart
│
├── bloc/
│   └── watchlist/
│       ├── watchlist_bloc.dart
│       ├── watchlist_event.dart
│       └── watchlist_state.dart
│
└── ui/
    ├── theme/
    │   └── app_theme.dart
    ├── screens/
    │   └── watchlist_screen.dart
    └── widgets/
        ├── stock_list_tile.dart
        ├── stock_avatar.dart
        ├── price_change_badge.dart
        ├── watchlist_header.dart
        ├── empty_watchlist_view.dart
        └── error_view.dart
```

---

## BLoC Flow (Simplified)

```
UI Action                →   BLoC               →   State
------------------------------------------------------------
Load Watchlist           →   _onLoadRequested   →   Loading → Loaded
Pull to refresh          →   _onRefresh         →   Loaded → Loaded
Reorder item             →   _onReorder         →   Loaded (updated)
Remove item              →   _onRemove          →   Loaded (updated)
```

---

## Events

| Event                       | When it happens |
| --------------------------- | --------------- |
| `WatchlistLoadRequested`    | App start       |
| `WatchlistRefreshRequested` | Manual refresh  |
| `WatchlistStockReordered`   | Drag released   |
| `WatchlistStockRemoved`     | Swipe dismiss   |

---

## States

| State              | Description          |
| ------------------ | -------------------- |
| `WatchlistInitial` | Initial idle state   |
| `WatchlistLoading` | Fetching data        |
| `WatchlistLoaded`  | Data available       |
| `WatchlistError`   | Something went wrong |

---

## Key Decisions (Why things are done this way)

### Immutable Models (with Equatable)

All models (`Stock`, `Watchlist`) are immutable.
Any change → returns a new instance.

This helps BLoC detect updates cleanly (and avoids weird UI bugs... learned this the hard way 😅).

---

### Business Logic inside Model (Not BLoC)

Reordering logic is inside `Watchlist` model instead of BLoC.

Reason:

* Easier to test
* Keeps BLoC clean
* Avoids index confusion (Flutter reorder logic is slightly weird tbh)

---

### Repository Layer

Used an abstract `WatchlistRepository`.

Right now it's mocked/static data, but can be easily replaced with API later.

---

### Optimistic UI Updates

Reorder and delete actions update UI immediately (no loader).

Makes the app feel fast and responsive.

---

### Custom Drag Feedback

Used `proxyDecorator` to add elevation + glow when dragging.

Small detail, but improves UX a lot.

---

## Testing

Run tests using:

```bash
flutter test
```

Covered:

* BLoC transitions
* Reorder logic (edge cases too)
* Remove functionality
* Model behavior

*(Could add widget tests later — skipped for now)*

---

## 🚀 Getting Started

```bash
flutter pub get
flutter run
```

Requirements:

* Flutter 3.10+
* Dart 3.0+

---

---

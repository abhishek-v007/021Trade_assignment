import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bloc/portfolio/portfolio_bloc.dart';
import 'bloc/watchlist/watchlist_bloc.dart';
import 'data/market/market_data_feed.dart';
import 'data/repositories/portfolio_repository.dart';
import 'data/repositories/watchlist_repository.dart';
import 'ui/screens/home_shell.dart';
import 'ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preload fonts so ₹ (Noto) and UI text (Inter) are ready on web/desktop.
  // Avoids "Could not find a set of Noto fonts" spam for the rupee glyph.
  await GoogleFonts.pendingFonts([
    GoogleFonts.inter(),
    GoogleFonts.notoSans(),
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.primaryDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final MarketDataFeed _feed;
  late final WatchlistRepository _watchlistRepository;
  late final PortfolioRepository _portfolioRepository;

  @override
  void initState() {
    super.initState();
    _feed = MarketDataFeed()..start();
    _watchlistRepository = WatchlistRepositoryImpl();
    _portfolioRepository = PortfolioRepositoryImpl();
  }

  @override
  void dispose() {
    _feed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<MarketDataFeed>.value(value: _feed),
        RepositoryProvider<WatchlistRepository>.value(
          value: _watchlistRepository,
        ),
        RepositoryProvider<PortfolioRepository>.value(
          value: _portfolioRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => WatchlistBloc(
              repository: context.read<WatchlistRepository>(),
            )..add(const WatchlistLoadRequested()),
          ),
          BlocProvider(
            create: (context) => PortfolioBloc(
              repository: context.read<PortfolioRepository>(),
            )..add(const PortfolioLoadRequested()),
          ),
        ],
        child: MaterialApp(
          title: '021 Trade',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const HomeShell(),
        ),
      ),
    );
  }
}

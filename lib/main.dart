import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/watchlist/watchlist_bloc.dart';
import 'data/repositories/watchlist_repository.dart';
import 'ui/screens/watchlist_screen.dart';
import 'ui/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<WatchlistRepository>(
      create: (_) => WatchlistRepositoryImpl(),
      child: BlocProvider<WatchlistBloc>(
        create: (context) => WatchlistBloc(
          repository: context.read<WatchlistRepository>(),
        )..add(const WatchlistLoadRequested()),
        child: MaterialApp(
          title: '021 Trade',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const WatchlistScreen(),
        ),
      ),
    );
  }
}

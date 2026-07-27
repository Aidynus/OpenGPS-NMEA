import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/location_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/main/main_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/log/sentence_log_screen.dart';
import 'features/profiles/connection_profiles_screen.dart';
import 'features/lock/lock_screen.dart';

final _routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const MainScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/log',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const SentenceLogScreen(),
        ),
      ),
      GoRoute(
        path: '/profiles',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const ConnectionProfilesScreen(),
        ),
      ),
      GoRoute(
        path: '/lock',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const LockScreen(),
        ),
      ),
    ],
  );
});

CustomTransitionPage<void> _fadePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
    transitionDuration: Durations.medium1,
    reverseTransitionDuration: Durations.medium1,
  );
}

class OpenGpsNmeaApp extends ConsumerWidget {
  const OpenGpsNmeaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    final settings = ref.watch(appSettingsProvider);
    final isHighContrast = settings.highContrast;

    return MaterialApp.router(
      title: 'OpenGPS-NMEA',
      debugShowCheckedModeBanner: false,
      // Light theme: low contrast or high contrast
      theme: isHighContrast ? AppTheme.highContrast : AppTheme.lowContrast,
      // Dark theme: dark high contrast or standard dark
      darkTheme: isHighContrast ? AppTheme.darkHighContrast : AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

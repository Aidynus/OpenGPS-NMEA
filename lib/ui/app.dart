import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/main/main_screen.dart';
import 'features/settings/settings_screen.dart';

final _routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class OpenGpsNmeaApp extends ConsumerWidget {
  const OpenGpsNmeaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);

    return MaterialApp.router(
      title: 'OpenGPS-NMEA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lowContrast,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}

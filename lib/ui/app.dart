import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/navigation.dart';
import 'core/theme/app_theme.dart';
import 'features/lock/lock_screen.dart';
import 'features/main/main_screen.dart';
import 'features/settings/settings_screen.dart';

final _routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const MainScreen(),
          isHome: true,
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
  bool isHome = false,
}) {
  return CustomTransitionPage<void>(
    key: key,
    // Every screen except home can be closed with a left-to-right swipe.
    child: isHome ? child : _SwipeBackGesture(child: child),
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

    return MaterialApp.router(
      title: 'JetourGPS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}

/// Left-to-right swipe returns to the previous (or the home) screen.
class _SwipeBackGesture extends StatelessWidget {
  final Widget child;

  const _SwipeBackGesture({required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity > 350) {
          goBackOrHome(context);
        }
      },
      child: child,
    );
  }
}

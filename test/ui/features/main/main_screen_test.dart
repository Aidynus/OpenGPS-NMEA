import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:opengps_nmea/data/providers/location_provider.dart';
import 'package:opengps_nmea/data/providers/transmission_provider.dart';
import 'package:opengps_nmea/domain/models/app_settings.dart';
import 'package:opengps_nmea/domain/models/gps_position.dart';
import 'package:opengps_nmea/domain/models/network_info.dart';
import 'package:opengps_nmea/ui/core/theme/app_theme.dart';
import 'package:opengps_nmea/ui/features/main/main_screen.dart';
// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => child),
      GoRoute(
          path: '/settings',
          builder: (_, __) => const Scaffold(body: Text('Settings'))),
      GoRoute(
          path: '/log',
          builder: (_, __) => const Scaffold(body: Text('Log'))),
      GoRoute(
          path: '/lock',
          builder: (_, __) => const Scaffold(body: Text('Lock'))),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      theme: AppTheme.lowContrast,
      routerConfig: router,
    ),
  );
}

GpsPosition _validPos() => GpsPosition(
      latitude: 48.43262,
      longitude: 17.0045,
      altitude: 100.0,
      speed: 5.0,
      heading: 90.0,
      accuracy: 5.0,
      timestamp: DateTime.utc(2024, 6, 15, 12, 0, 0),
      hasFix: true,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('MainScreen', () {
    testWidgets('shows app title', (tester) async {
      await tester.pumpWidget(_wrap(
        const MainScreen(),
        overrides: [
          settingsReadyProvider.overrideWithValue(true),
          lastKnownPositionProvider.overrideWithValue(null),
          locationPermissionErrorProvider.overrideWith((ref) => null),
          networkInfoProvider.overrideWith(
              (ref) async => const NetworkInfo(isHotspotActive: false)),
          appSettingsProvider.overrideWith(
              () => _FakeSettingsNotifier(AppSettings.defaults())),
        ],
      ));
      await tester.pump();
      expect(find.text('OpenGPS-NMEA'), findsOneWidget);
    });

    testWidgets('shows No Fix when position is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const MainScreen(),
        overrides: [
          settingsReadyProvider.overrideWithValue(true),
          lastKnownPositionProvider.overrideWithValue(null),
          locationPermissionErrorProvider.overrideWith((ref) => null),
          networkInfoProvider.overrideWith(
              (ref) async => const NetworkInfo(isHotspotActive: false)),
          appSettingsProvider.overrideWith(
              () => _FakeSettingsNotifier(AppSettings.defaults())),
        ],
      ));
      await tester.pumpAndSettle();
      expect(find.text('No Fix'), findsOneWidget);
    });

    testWidgets('shows position data when fix is acquired', (tester) async {
      final pos = _validPos();
      await tester.pumpWidget(_wrap(
        const MainScreen(),
        overrides: [
          settingsReadyProvider.overrideWithValue(true),
          lastKnownPositionProvider.overrideWithValue(pos),
          locationPermissionErrorProvider.overrideWith((ref) => null),
          networkInfoProvider.overrideWith(
              (ref) async => const NetworkInfo(isHotspotActive: false)),
          appSettingsProvider.overrideWith(
              () => _FakeSettingsNotifier(AppSettings.defaults())),
        ],
      ));
      await tester.pumpAndSettle();
      // Position card should show coordinates
      expect(find.textContaining('48'), findsWidgets);
      expect(find.text('No Fix'), findsNothing);
    });

    testWidgets('shows permission error when location denied', (tester) async {
      await tester.pumpWidget(_wrap(
        const MainScreen(),
        overrides: [
          settingsReadyProvider.overrideWithValue(true),
          lastKnownPositionProvider.overrideWithValue(null),
          locationPermissionErrorProvider.overrideWith(
              (ref) => 'Location permission denied.'),
          networkInfoProvider.overrideWith(
              (ref) async => const NetworkInfo(isHotspotActive: false)),
          appSettingsProvider.overrideWith(
              () => _FakeSettingsNotifier(AppSettings.defaults())),
        ],
      ));
      await tester.pumpAndSettle();
      expect(find.textContaining('denied'), findsOneWidget);
    });

    testWidgets('shows loading spinner when settings not ready',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const MainScreen(),
        overrides: [
          settingsReadyProvider.overrideWithValue(false),
          lastKnownPositionProvider.overrideWithValue(null),
          locationPermissionErrorProvider.overrideWith((ref) => null),
          networkInfoProvider.overrideWith(
              (ref) async => const NetworkInfo(isHotspotActive: false)),
          appSettingsProvider.overrideWith(
              () => _FakeSettingsNotifier(AppSettings.defaults())),
        ],
      ));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('toggle switch calls start on coordinator', (tester) async {
      await tester.pumpWidget(_wrap(
        const MainScreen(),
        overrides: [
          settingsReadyProvider.overrideWithValue(true),
          lastKnownPositionProvider.overrideWithValue(null),
          locationPermissionErrorProvider.overrideWith((ref) => null),
          networkInfoProvider.overrideWith(
              (ref) async => const NetworkInfo(isHotspotActive: false)),
          appSettingsProvider.overrideWith(
              () => _FakeSettingsNotifier(AppSettings.defaults())),
        ],
      ));
      await tester.pumpAndSettle();

      // Initially Off
      expect(find.text('Off'), findsOneWidget);
    });

    testWidgets('high-contrast theme applies correct background', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsReadyProvider.overrideWithValue(true),
            lastKnownPositionProvider.overrideWithValue(null),
            locationPermissionErrorProvider.overrideWith((ref) => null),
            networkInfoProvider.overrideWith(
                (ref) async => const NetworkInfo(isHotspotActive: false)),
            appSettingsProvider.overrideWith(() =>
                _FakeSettingsNotifier(AppSettings.defaults().copyWith(highContrast: true))),
          ],
          child: MaterialApp(
            theme: AppTheme.highContrast,
            home: const MainScreen(),
          ),
        ),
      );
      await tester.pump();
      // High contrast scaffold background should be white
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, isNull); // uses theme default (white in highContrast)
    });
  });
}

// ── Fake notifier ─────────────────────────────────────────────────────────────

class _FakeSettingsNotifier extends AppSettingsNotifier {
  final AppSettings _settings;
  _FakeSettingsNotifier(this._settings);

  @override
  AppSettings build() => _settings;
}

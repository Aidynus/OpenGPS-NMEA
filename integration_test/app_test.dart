import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:opengps_nmea/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Navigation', () {
    testWidgets('app launches and shows main screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('JetourGPS'), findsOneWidget);
    });

    testWidgets('settings button navigates to settings screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('Main Screen Elements', () {
    testWidgets('displays OFF state by default', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Off'), findsOneWidget);
    });

    testWidgets('displays position card', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Position'), findsOneWidget);
    });

    testWidgets('displays status card', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Tx'), findsOneWidget);
      expect(find.text('Rx'), findsOneWidget);
      expect(find.text('Clients'), findsOneWidget);
    });

    testWidgets('ON/OFF toggle present and functions', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(Switch), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(find.text('Active'), findsOneWidget);
    });
  });

  group('Settings Screen Elements', () {
    testWidgets('renders all section tiles', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('General'), findsOneWidget);
      expect(find.text('NMEA'), findsOneWidget);
      expect(find.text('TAIP'), findsOneWidget);
      expect(find.text('Connection'), findsOneWidget);
      expect(find.text('Network'), findsOneWidget);
    });
  });
}

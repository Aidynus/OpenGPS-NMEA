import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:opengps_nmea/ui/app.dart';

void main() {
  testWidgets('App renders main screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: OpenGpsNmeaApp(),
      ),
    );
    expect(find.text('JetourGPS'), findsOneWidget);
  });
}

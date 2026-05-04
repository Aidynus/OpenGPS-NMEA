import 'package:flutter_test/flutter_test.dart';
import 'package:opengps_nmea/core/utils/coordinate_formatter.dart';

void main() {
  group('decimalToDmsLatitude', () {
    test('converts positive latitude correctly', () {
      // 48.4326° = 48°25'57.36"N
      final result = decimalToDmsLatitude(48.4326, 2);
      expect(result, "48° 25' 57.36\" N");
    });

    test('converts negative latitude correctly', () {
      final result = decimalToDmsLatitude(-33.8688, 2);
      expect(result, "33° 52' 07.68\" S");
    });

    test('handles zero latitude', () {
      final result = decimalToDmsLatitude(0.0, 2);
      expect(result, "0° 00' 00.00\" N");
    });
  });

  group('decimalToDmsLongitude', () {
    test('converts positive longitude correctly', () {
      final result = decimalToDmsLongitude(151.2093, 2);
      expect(result, "151° 12' 33.48\" E");
    });

    test('converts negative longitude correctly', () {
      final result = decimalToDmsLongitude(-73.935242, 2);
      expect(result, "73° 56' 06.87\" W");
    });
  });

  group('decimalToDecimalMinutesLatitude', () {
    test('formats with decimal minutes', () {
      final result = decimalToDecimalMinutesLatitude(48.4326, 4);
      expect(result, "48° 25.9560' N");
    });
  });

  group('decimalToDecimalMinutesLongitude', () {
    test('formats with decimal minutes', () {
      final result = decimalToDecimalMinutesLongitude(151.2093, 4);
      expect(result, "151° 12.5580' E");
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:opengps_nmea/core/utils/nmea_formatter.dart';

void main() {
  group('nmeaLatToField', () {
    test('formats positive latitude as NMEA field', () {
      // 48.4326 => 4825.95600,N
      final field = nmeaLatToField(48.4326);
      expect(field, '4825.95600,N');
    });

    test('formats negative latitude as NMEA field', () {
      final field = nmeaLatToField(-33.8688);
      expect(field, '3352.12800,S');
    });
  });

  group('nmeaLonToField', () {
    test('formats positive longitude as NMEA field', () {
      final field = nmeaLonToField(151.2093);
      expect(field, '15112.55800,E');
    });

    test('formats negative longitude as NMEA field', () {
      final field = nmeaLonToField(-73.9352);
      expect(field, '07356.11200,W');
    });
  });

  group('nmeaTimeField', () {
    test('formats UTC time without milliseconds', () {
      final dt = DateTime.utc(2024, 6, 15, 12, 34, 56);
      expect(nmeaTimeField(dt), '123456');
    });

    test('formats UTC time with milliseconds', () {
      final dt = DateTime.utc(2024, 6, 15, 19, 49, 0, 882);
      expect(nmeaTimeField(dt, withMilliseconds: true), '194900.882');
    });
  });

  group('nmeaDateField', () {
    test('formats date as ddmmyy', () {
      final dt = DateTime.utc(2024, 6, 15);
      expect(nmeaDateField(dt), '150624');
    });
  });

  group('speed conversion', () {
    test('knotsToNmeaSpeed converts m/s to knots string', () {
      final result = knotsToNmeaSpeed(5.14444);
      expect(result, '10.00');
    });

    test('kmPerHourToNmeaSpeed converts m/s to km/h string', () {
      final result = kmPerHourToNmeaSpeed(10.0);
      expect(result, '36.00');
    });
  });
}

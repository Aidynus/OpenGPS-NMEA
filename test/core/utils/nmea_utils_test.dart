import 'package:flutter_test/flutter_test.dart';
import 'package:opengps_nmea/core/utils/nmea_utils.dart';

void main() {
  group('nmeaChecksum', () {
    test('calculates XOR checksum correctly for known sentence', () {
      final body = 'GPGGA,115922,4825.95722,N,01700.27029,E,1,8,0.9,159.4,M,46.9,M,0,2';
      final checksum = nmeaChecksum(body);
      expect(checksum, 0x77);
    });

    test('calculates checksum for simple string', () {
      final checksum = nmeaChecksum('GPRMC,123519');
      final expected = 'GPRMC,123519'.codeUnits.fold(0, (a, b) => a ^ b);
      expect(checksum, expected);
    });

    test('empty string returns 0', () {
      expect(nmeaChecksum(''), 0);
    });
  });

  group('formatNmeaChecksum', () {
    test('formats single digit hex with leading zero', () {
      expect(formatNmeaChecksum(0x0A), '0A');
    });

    test('formats double digit hex', () {
      expect(formatNmeaChecksum(0xFF), 'FF');
    });

    test('lowercase digits become uppercase', () {
      expect(formatNmeaChecksum(0x7f), '7F');
    });
  });

  group('buildNmeaSentence', () {
    test('builds valid NMEA sentence with correct format', () {
      final sentence = buildNmeaSentence(
        'GP', 'RMC', '123519,A,4807.038,N,01131.000,E,022.4,084.4,230394,003.1,W',
      );
      expect(sentence, startsWith('\$'));
      expect(sentence, contains('*'));
      expect(sentence, endsWith('\r\n'));
    });

    test('checksum matches XOR validation', () {
      final sentence = buildNmeaSentence('GP', 'GGA', '115922,4825.95722,N,01700.27029,E,1,8,0.9,159.4,M,46.9,M,0,2');
      expect(sentence, '\$GPGGA,115922,4825.95722,N,01700.27029,E,1,8,0.9,159.4,M,46.9,M,0,2*77\r\n');
    });
  });
}

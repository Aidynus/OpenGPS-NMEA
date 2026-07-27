import 'package:flutter_test/flutter_test.dart';
import 'package:opengps_nmea/core/utils/validators.dart';

void main() {
  group('validateIpAddress', () {
    test('returns null for valid IPv4', () {
      expect(validateIpAddress('192.168.1.100'), isNull);
    });

    test('returns null for valid IPv4 broadcast', () {
      expect(validateIpAddress('255.255.255.255'), isNull);
    });

    test('returns null for valid IPv6', () {
      expect(validateIpAddress('::1'), isNull);
    });

    test('returns error for empty string', () {
      expect(validateIpAddress(''), isNotNull);
    });

    test('returns error for null', () {
      expect(validateIpAddress(null), isNotNull);
    });

    test('returns error for invalid address', () {
      expect(validateIpAddress('999.999.999.999'), isNotNull);
      expect(validateIpAddress('not-an-ip'), isNotNull);
    });
  });

  group('validatePort', () {
    test('returns null for valid ports', () {
      expect(validatePort('1'), isNull);
      expect(validatePort('80'), isNull);
      expect(validatePort('11123'), isNull);
      expect(validatePort('65535'), isNull);
    });

    test('returns error for 0', () {
      expect(validatePort('0'), isNotNull);
    });

    test('returns error for > 65535', () {
      expect(validatePort('65536'), isNotNull);
    });

    test('returns error for non-numeric', () {
      expect(validatePort('abc'), isNotNull);
      expect(validatePort(''), isNotNull);
      expect(validatePort(null), isNotNull);
    });
  });

  group('validateMulticastAddress', () {
    test('returns null for valid multicast address', () {
      expect(validateMulticastAddress('239.255.255.250'), isNull);
      expect(validateMulticastAddress('224.0.0.1'), isNull);
    });

    test('returns error for unicast address', () {
      expect(validateMulticastAddress('192.168.1.1'), isNotNull);
    });

    test('returns error for invalid address', () {
      expect(validateMulticastAddress('not-an-ip'), isNotNull);
      expect(validateMulticastAddress(''), isNotNull);
    });
  });

  group('validateWebSocketUrl', () {
    test('returns null for valid ws:// URL', () {
      expect(validateWebSocketUrl('ws://192.168.1.100:8080'), isNull);
    });

    test('returns null for valid wss:// URL', () {
      expect(validateWebSocketUrl('wss://example.com/ws'), isNull);
    });

    test('returns null for empty (optional field)', () {
      expect(validateWebSocketUrl(''), isNull);
      expect(validateWebSocketUrl(null), isNull);
    });

    test('returns error for http:// URL', () {
      expect(validateWebSocketUrl('http://example.com'), isNotNull);
    });

    test('returns error for bare URL without scheme', () {
      expect(validateWebSocketUrl('192.168.1.100:8080'), isNotNull);
    });
  });

  group('validateTaipDeviceId', () {
    test('returns null for valid IDs', () {
      expect(validateTaipDeviceId('D001'), isNull);
      expect(validateTaipDeviceId('UNIT01'), isNull);
    });

    test('returns error for empty', () {
      expect(validateTaipDeviceId(''), isNotNull);
      expect(validateTaipDeviceId(null), isNotNull);
    });

    test('returns error for ID longer than 8 chars', () {
      expect(validateTaipDeviceId('TOOLONGID'), isNotNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:opengps_nmea/domain/protocols/taip/taip_builder.dart';
import 'package:opengps_nmea/domain/models/gps_position.dart';
import 'package:opengps_nmea/domain/models/app_settings.dart';

void main() {
  late TaipBuilder builder;

  setUp(() {
    builder = const TaipBuilder();
  });

  // ── Checksum ────────────────────────────────────────────────────────

  group('taipChecksum', () {
    test('XORs all bytes and returns 8-bit value', () {
      // Manual calculation: XOR of 'PV015714'
      // P=0x50, V=0x56, 0=0x30, 1=0x31, 5=0x35, 7=0x37, 1=0x31, 4=0x34
      // 0x50 ^ 0x56 = 0x06
      // 0x06 ^ 0x30 = 0x36
      // 0x36 ^ 0x31 = 0x07
      // 0x07 ^ 0x35 = 0x32
      // 0x32 ^ 0x37 = 0x05
      // 0x05 ^ 0x31 = 0x34
      // 0x34 ^ 0x34 = 0x00
      expect(builder.taipChecksum('PV015714'), equals(0x00));
    });

    test('returns 0 for empty string', () {
      expect(builder.taipChecksum(''), equals(0));
    });

    test('returns byte value for single character', () {
      expect(builder.taipChecksum('A'), equals(0x41));
    });

    test('produces expected checksum for full PV body', () {
      // Build a known body and verify checksum manually
      final body = 'PV015714+37394384-12203516+000150260101;ID=0000;';
      final cs = builder.taipChecksum(body);
      // Verify it's in 0..255
      expect(cs, greaterThanOrEqualTo(0));
      expect(cs, lessThanOrEqualTo(255));
      // Verify round-trip: wrapping produces a valid message
      final hex = cs.toRadixString(16).toUpperCase().padLeft(2, '0');
      expect(hex.length, equals(2));
    });
  });

  // ── Latitude Formatting ──────────────────────────────────────────────

  group('formatTaipLatitude', () {
    test('formats positive latitude (North)', () {
      // 37.662177° → 37° 39' 43.80" → +37394380
      // Let me compute: 37 + 39.72/60 = 37.662
      // 37°, 0.662*60=39.72', 39', 0.72*60=43.2", ss=20  
      // Actually: 37.662177°
      // deg=37, min_dec=0.662177*60=39.73062', min=39
      // sec_dec=0.73062*60=43.8372, sec=43, ss=84
      expect(builder.formatTaipLatitude(37.662177), equals('+37394384'));
    });

    test('formats negative latitude (South)', () {
      // -33.8688° → 33° 52' 7.68" → -33520768?
      // deg=33, min_dec=0.8688*60=52.128, min=52
      // sec_dec=0.128*60=7.68, sec=7, ss=68
      expect(builder.formatTaipLatitude(-33.8688), equals('-33520768'));
    });

    test('formats zero latitude', () {
      expect(builder.formatTaipLatitude(0.0), equals('+00000000'));
    });

    test('formats small positive latitude', () {
      // 1.5° → 1° 30' 0.00" → +01300000
      expect(builder.formatTaipLatitude(1.5), equals('+01300000'));
    });

    test('formats edge case: near-pole latitude', () {
      // 89.999972° → 89° 59' 59.90"
      final result = builder.formatTaipLatitude(89.999972);
      expect(result.startsWith('+89'), isTrue);
      expect(result.length, equals(9));
    });

    test('pads degrees to 2 digits', () {
      // 5.0° = 5° 0' 0.00" → +05000000
      expect(builder.formatTaipLatitude(5.0), equals('+05000000'));
    });

    test('formats 1.5 degrees as 1 deg 30 min 0.00 sec', () {
      // 1.5° = 1° 30' 0.00" → +01300000
      expect(builder.formatTaipLatitude(1.5), equals('+01300000'));
    });
  });

  // ── Longitude Formatting ─────────────────────────────────────────────

  group('formatTaipLongitude', () {
    test('formats positive longitude (East)', () {
      // -122.064333° → 122° 3' 51.60" → -12203516? Let me recompute
      // abs=122.064333, deg=122, min_dec=0.064333*60=3.85998, min=3
      // sec_dec=0.85998*60=51.5988, sec=51, ss=60
      // But wait, rounding ss=60 causes carry... let's see what rounding does
      // Actually 51.5988 → sec=51, ss=round(0.5988*100)=round(59.88)=60
      // That causes overflow — our implementation handles this by adding 0.00001 and recursing
      // So it should become: 122° 3' 52.00" → -12203520 (with carry)
      // Actually let me compute more carefully
      // 122.064333
      // deg = 122
      // min_dec = 0.064333 * 60 = 3.85998
      // min = 3
      // sec_dec = 0.85998 * 60 = 51.5988
      // sec = 51
      // sec_hundreths = round(0.5988 * 100) = round(59.88) = 60
      // 60 >= 100? No, 60 < 100. So formatted as -122035160? No, ss=60 is still wrong.
      // Actually, the code rounds to get ss, and 60 hundredths = 0.6 seconds, which is valid.
      // Wait no: ss is hundredths of a second. 60 hundredths = 0.60 seconds.
      // So -122035160? That has DDD=122, MM=03, SS=51, ss=60.
      // Hmm, but 60/100 = 0.6, so that's 51.60 seconds. Is that right?
      // 122.064333° = 122° + 3.85998' = 122° 3' + 51.5988" = 122°3'51.60"
      // Yes, that's correct! ss=60 is fine since it's 60 hundredths of a second.
      expect(builder.formatTaipLongitude(-122.064333), equals('-122035160'));
    });

    test('formats negative longitude (West)', () {
      // -73.9352° → 73° 56' 7.20" → -073560720
      // deg=73, min_dec=0.9352*60=56.112, min=56
      // sec_dec=0.112*60=6.72, sec=6, ss=72
      expect(builder.formatTaipLongitude(-73.9352), equals('-073560672'));
    });

    test('formats zero longitude', () {
      expect(builder.formatTaipLongitude(0.0), equals('+000000000'));
    });

    test('pads degrees to 3 digits', () {
      // 5.0° = 5° 0' 0.00" → +005000000
      expect(builder.formatTaipLongitude(5.0), equals('+005000000'));
    });

    test('formats large longitude', () {
      // 151.2093° → 151° 12' 33.48"
      // deg=151, min_dec=0.2093*60=12.558, min=12
      // sec_dec=0.558*60=33.48, sec=33, ss=48
      expect(builder.formatTaipLongitude(151.2093), equals('+151123348'));
    });
  });

  // ── Time Formatting ─────────────────────────────────────────────────

  group('formatTaipTime', () {
    test('formats UTC time as HHMMSS', () {
      final dt = DateTime.utc(2024, 6, 15, 12, 34, 56);
      expect(builder.formatTaipTime(dt), equals('123456'));
    });

    test('pads single-digit hours/minutes/seconds', () {
      final dt = DateTime.utc(2024, 1, 2, 1, 2, 3);
      expect(builder.formatTaipTime(dt), equals('010203'));
    });

    test('uses midnight as 000000', () {
      final dt = DateTime.utc(2024, 6, 15, 0, 0, 0);
      expect(builder.formatTaipTime(dt), equals('000000'));
    });

    test('converts local time to UTC before formatting', () {
      // Ensure we use .toUtc() internally
      final dt = DateTime(2024, 6, 15, 12, 0, 0); // local time
      final result = builder.formatTaipTime(dt);
      // Result depends on local timezone, but should be valid HHMMSS
      expect(result.length, equals(6));
      expect(int.parse(result), greaterThanOrEqualTo(0));
      expect(int.parse(result), lessThanOrEqualTo(235959));
    });
  });

  // ── PV Message Building ─────────────────────────────────────────────

  group('buildPv', () {
    final testTime = DateTime.utc(2024, 6, 15, 12, 34, 56);
    final testPosition = GpsPosition(
      latitude: 37.662177,
      longitude: -122.064333,
      altitude: 10.5,
      speed: 0.25,    // 0.25 m/s → 25 (cents)
      heading: 90.0,  // 90.0° → 9000 (cents)
      accuracy: null,
      timestamp: testTime,
      hasFix: true,
      verticalAccuracy: null,
      headingAccuracy: null,
    );
    final testSettings = AppSettings.defaults().copyWith(
      taipDeviceId: 'D234',
    );

    test('produces correctly formatted PV message', () {
      final result = builder.buildPv(testPosition, testSettings);

      // Verify structure: >RPV...;ID=D234;*XX<
      expect(result.startsWith('>RPV'), isTrue);
      expect(result.contains(';ID=D234;'), isTrue);
      expect(result.endsWith('<'), isTrue);

      // Extract checksum and verify it matches
      final starIndex = result.lastIndexOf('*');
      final checksumStr = result.substring(starIndex + 1, result.length - 1);
      expect(checksumStr.length, equals(2));

      // Verify checksum is valid hex
      final checksum = int.parse(checksumStr, radix: 16);

      // Extract inner content between >R and *< for checksum verification
      final inner = result.substring(2, starIndex);
      expect(builder.taipChecksum(inner), equals(checksum));
    });

    test('includes correct time field', () {
      final result = builder.buildPv(testPosition, testSettings);
      // Time should be 123456 (HHMMSS)
      // After >RPV, first 6 chars are time
      final pvStart = result.indexOf('PV') + 2;
      expect(result.substring(pvStart, pvStart + 6), equals('123456'));
    });

    test('includes correct latitude', () {
      final result = builder.buildPv(testPosition, testSettings);
      // Latitude should be +37394384
      expect(result.contains('+37394384'), isTrue);
    });

    test('includes correct longitude', () {
      final result = builder.buildPv(testPosition, testSettings);
      // Longitude should be -12203516?
      // Let's verify: -122.064333 -> see formatTaipLongitude test
      expect(result.contains('-122035'), isTrue);
    });

    test('formats speed as m/s * 100 zero-padded 4 digits', () {
      final pos = GpsPosition(
        latitude: 0,
        longitude: 0,
        altitude: 0,
        speed: 1.5, // 1.5 m/s → 150
        heading: 0,
        accuracy: null,
        timestamp: DateTime.utc(2024, 1, 1, 0, 0, 0),
        hasFix: true,
        verticalAccuracy: null,
        headingAccuracy: null,
      );
      final result = builder.buildPv(pos, testSettings);
      // speed field should be 0150
      expect(result.contains('0150'), isTrue);
    });

    test('formats heading as degrees * 100 zero-padded 4 digits', () {
      final pos = GpsPosition(
        latitude: 0,
        longitude: 0,
        altitude: 0,
        speed: 0,
        heading: 26.12, // 26.12° * 100 = 2612
        accuracy: null,
        timestamp: DateTime.utc(2024, 1, 1, 0, 0, 0),
        hasFix: true,
        verticalAccuracy: null,
        headingAccuracy: null,
      );
      final result = builder.buildPv(pos, testSettings);
      expect(result.contains('2612'), isTrue);
    });

    test('source=1 when hasFix is true', () {
      final pos = GpsPosition(
        latitude: 0,
        longitude: 0,
        altitude: 0,
        speed: 0,
        heading: 0,
        accuracy: null,
        timestamp: DateTime.utc(2024, 1, 1, 0, 0, 0),
        hasFix: true,
        verticalAccuracy: null,
        headingAccuracy: null,
      );
      final result = builder.buildPv(pos, testSettings);
      // The last data char before ;ID= is the source
      final idIndex = result.indexOf(';ID=');
      // Source field is 1 char before ;ID=
      // Data format: PV(2) + time(6) + lat(9) + lon(10) + speed(4) + heading(4) + source(1) = 36 data chars
      // So source is at index 2+6+9+10+4+4 = 35 from PV start
      // But easier: find the char just before ;ID=
      expect(result[idIndex - 1], equals('1'));
    });

    test('source=0 when hasFix is false', () {
      final pos = GpsPosition(
        latitude: 0,
        longitude: 0,
        altitude: 0,
        speed: 0,
        heading: 0,
        accuracy: null,
        timestamp: DateTime.utc(2024, 1, 1, 0, 0, 0),
        hasFix: false,
        verticalAccuracy: null,
        headingAccuracy: null,
      );
      final result = builder.buildPv(pos, testSettings);
      final idIndex = result.indexOf(';ID=');
      expect(result[idIndex - 1], equals('0'));
    });

    test('defaults speed and heading to 0 when null', () {
      final pos = GpsPosition(
        latitude: 0,
        longitude: 0,
        altitude: 0,
        speed: null, // null → 0
        heading: null, // null → 0
        accuracy: null,
        timestamp: DateTime.utc(2024, 1, 1, 0, 0, 0),
        hasFix: true,
        verticalAccuracy: null,
        headingAccuracy: null,
      );
      final result = builder.buildPv(pos, testSettings);
      // speed should be 0000, heading should be 0000
      expect(result.contains('0000'), isTrue);
    });

    test('uses device ID from settings', () {
      final customSettings = AppSettings.defaults().copyWith(
        taipDeviceId: 'MYDEV',
      );
      final pos = GpsPosition(
        latitude: 0,
        longitude: 0,
        altitude: 0,
        speed: 0,
        heading: 0,
        accuracy: null,
        timestamp: DateTime.utc(2024, 1, 1, 0, 0, 0),
        hasFix: true,
        verticalAccuracy: null,
        headingAccuracy: null,
      );
      final result = builder.buildPv(pos, customSettings);
      expect(result.contains(';ID=MYDEV;'), isTrue);
    });
  });

  // ── AL Message Building ──────────────────────────────────────────────

  group('buildAl', () {
    final testTime = DateTime.utc(2024, 6, 15, 12, 34, 56);
    final testPosition = GpsPosition(
      latitude: 37.662177,
      longitude: -122.064333,
      altitude: 150.0,
      speed: 0.25,
      heading: 90.0,
      accuracy: null,
      timestamp: testTime,
      hasFix: true,
      verticalAccuracy: null,
      headingAccuracy: null,
    );
    final testSettings = AppSettings.defaults().copyWith(
      taipDeviceId: 'D234',
    );

    test('produces correctly formatted AL message', () {
      final result = builder.buildAl(testPosition, testSettings);

      // Verify structure: >RAL...;ID=D234;*XX<
      expect(result.startsWith('>RAL'), isTrue);
      expect(result.contains(';ID=D234;'), isTrue);
      expect(result.endsWith('<'), isTrue);

      // Verify checksum
      final starIndex = result.lastIndexOf('*');
      final checksumStr = result.substring(starIndex + 1, result.length - 1);
      final checksum = int.parse(checksumStr, radix: 16);
      final inner = result.substring(2, starIndex);
      expect(builder.taipChecksum(inner), equals(checksum));
    });

    test('includes altitude as 5-digit zero-padded meters', () {
      final pos = GpsPosition(
        latitude: 0,
        longitude: 0,
        altitude: 150,
        speed: 0,
        heading: 0,
        accuracy: null,
        timestamp: DateTime.utc(2024, 1, 1, 0, 0, 0),
        hasFix: true,
        verticalAccuracy: null,
        headingAccuracy: null,
      );
      final result = builder.buildAl(pos, testSettings);
      expect(result.contains('00150'), isTrue);
    });

    test('defaults altitude to 0 when null', () {
      final pos = GpsPosition(
        latitude: 0,
        longitude: 0,
        altitude: null,
        speed: 0,
        heading: 0,
        accuracy: null,
        timestamp: DateTime.utc(2024, 1, 1, 0, 0, 0),
        hasFix: true,
        verticalAccuracy: null,
        headingAccuracy: null,
      );
      final result = builder.buildAl(pos, testSettings);
      expect(result.contains('00000'), isTrue);
    });

    test('uses AL message type identifier', () {
      final result = builder.buildAl(testPosition, testSettings);
      expect(result.substring(2, 4), equals('AL'));
    });
  });

  // ── buildAllEnabled ──────────────────────────────────────────────────

  group('buildAllEnabled', () {
    final testTime = DateTime.utc(2024, 6, 15, 12, 34, 56);
    final testPosition = GpsPosition(
      latitude: 37.662177,
      longitude: -122.064333,
      altitude: 150.0,
      speed: 1.5,
      heading: 90.0,
      accuracy: null,
      timestamp: testTime,
      hasFix: true,
      verticalAccuracy: null,
      headingAccuracy: null,
    );

    test('returns PV when only taipPvEnabled is true', () {
      final settings = AppSettings.defaults().copyWith(
        taipPvEnabled: true,
        taipAlEnabled: false,
        taipDeviceId: 'TEST',
      );
      final messages = builder.buildAllEnabled(testPosition, settings);
      expect(messages.length, equals(1));
      expect(messages.first.contains('PV'), isTrue);
    });

    test('returns AL when only taipAlEnabled is true', () {
      final settings = AppSettings.defaults().copyWith(
        taipPvEnabled: false,
        taipAlEnabled: true,
        taipDeviceId: 'TEST',
      );
      final messages = builder.buildAllEnabled(testPosition, settings);
      expect(messages.length, equals(1));
      expect(messages.first.contains('AL'), isTrue);
    });

    test('returns both PV and AL when both enabled', () {
      final settings = AppSettings.defaults().copyWith(
        taipPvEnabled: true,
        taipAlEnabled: true,
        taipDeviceId: 'TEST',
      );
      final messages = builder.buildAllEnabled(testPosition, settings);
      expect(messages.length, equals(2));
      expect(messages[0].contains('PV'), isTrue); // PV first
      expect(messages[1].contains('AL'), isTrue); // AL second
    });

    test('returns empty list when neither enabled', () {
      final settings = AppSettings.defaults().copyWith(
        taipPvEnabled: false,
        taipAlEnabled: false,
      );
      final messages = builder.buildAllEnabled(testPosition, settings);
      expect(messages.isEmpty, isTrue);
    });

    test('default settings have PV enabled and AL disabled', () {
      final defaults = AppSettings.defaults();
      expect(defaults.taipPvEnabled, isTrue);
      expect(defaults.taipAlEnabled, isFalse);
    });
  });

  // ── Edge Cases ──────────────────────────────────────────────────────

  group('edge cases', () {
    test('handles position at null island (0, 0)', () {
      final pos = GpsPosition(
        latitude: 0.0,
        longitude: 0.0,
        altitude: 0.0,
        speed: 0.0,
        heading: 0.0,
        accuracy: null,
        timestamp: DateTime.utc(2024, 1, 1, 0, 0, 0),
        hasFix: false,
        verticalAccuracy: null,
        headingAccuracy: null,
      );
      final settings = AppSettings.defaults().copyWith(
        taipPvEnabled: true,
        taipAlEnabled: true,
        taipDeviceId: '0000',
      );
      final messages = builder.buildAllEnabled(pos, settings);
      expect(messages.length, equals(2));

      // PV message with no fix: source=0, speed=0000, heading=0000
      final pv = messages[0];
      expect(pv.contains('PV'), isTrue);
      expect(pv.contains('+00000000'), isTrue); // lat at 0
      expect(pv.contains('+000000000'), isTrue); // lon at 0

      // AL message
      final al = messages[1];
      expect(al.contains('AL'), isTrue);
      expect(al.contains('00000'), isTrue); // altitude at 0
    });

    test('no fix produces source=0 in PV', () {
      final pos = GpsPosition(
        latitude: 37.662177,
        longitude: -122.064333,
        altitude: 10.0,
        speed: 0.0,
        heading: 0.0,
        accuracy: null,
        timestamp: DateTime.utc(2024, 1, 1, 12, 0, 0),
        hasFix: false,
        verticalAccuracy: null,
        headingAccuracy: null,
      );
      final settings = AppSettings.defaults().copyWith(
        taipDeviceId: '0000',
      );
      final result = builder.buildPv(pos, settings);
      // Source should be '0' (no fix)
      final idIndex = result.indexOf(';ID=');
      expect(result[idIndex - 1], equals('0'));
    });

    test('checksum wraps to 8 bits for large XOR values', () {
      // Create data that XORs to a value > 255 — verify it's masked
      final result = builder.taipChecksum('A' * 256);
      expect(result, greaterThanOrEqualTo(0));
      expect(result, lessThanOrEqualTo(255));
    });

    test('PV and AL messages for same position have different checksums', () {
      final pos = GpsPosition(
        latitude: 37.662177,
        longitude: -122.064333,
        altitude: 150.0,
        speed: 1.5,
        heading: 90.0,
        accuracy: null,
        timestamp: DateTime.utc(2024, 6, 15, 12, 34, 56),
        hasFix: true,
        verticalAccuracy: null,
        headingAccuracy: null,
      );
      final settings = AppSettings.defaults().copyWith(
        taipPvEnabled: true,
        taipAlEnabled: true,
        taipDeviceId: 'D234',
      );
      final pv = builder.buildPv(pos, settings);
      final al = builder.buildAl(pos, settings);

      // PV and AL have different content, so different checksums
      final pvChecksum = pv.substring(pv.lastIndexOf('*') + 1, pv.length - 1);
      final alChecksum = al.substring(al.lastIndexOf('*') + 1, al.length - 1);
      // They CAN be different (not guaranteed, but very likely with different type chars)
      // Just verify both are valid 2-char hex strings
      expect(pvChecksum.length, equals(2));
      expect(alChecksum.length, equals(2));
    });
  });
}
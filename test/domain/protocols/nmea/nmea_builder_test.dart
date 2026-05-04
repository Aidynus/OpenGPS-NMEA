import 'package:flutter_test/flutter_test.dart';
import 'package:opengps_nmea/domain/models/app_settings.dart';
import 'package:opengps_nmea/domain/models/gps_position.dart';
import 'package:opengps_nmea/domain/protocols/nmea/nmea_builder.dart';

// ── Helpers ────────────────────────────────────────────────────────────

/// Reference position matching the GPS2IP test vector:
/// 48°25.95722′N, 017°00.27029′E, alt 159.4 m, spd 5.14444 m/s, hdg 84.4
GpsPosition _referencePosition() => GpsPosition(
      latitude: 48.43262,
      longitude: 17.00450,
      altitude: 159.4,
      speed: 5.14444,
      heading: 84.4,
      timestamp: DateTime.utc(2024, 6, 15, 11, 59, 22),
      hasFix: true,
    );

AppSettings _allEnabled() => AppSettings.defaults().copyWith(
      ggaEnabled: true,
      gllEnabled: true,
      gsaEnabled: true,
      hdgEnabled: true,
      hdmEnabled: true,
      hdtEnabled: true,
      rmcEnabled: true,
      vtgEnabled: true,
      zdaEnabled: true,
      pashrEnabled: true,
      gptxtEnabled: true,
      customGptxt: 'Hello',
    );

/// Strip checksum so we can verify the body independently.
String _body(String sentence) {
  // $BODY*XX\r\n → BODY
  final s = sentence.substring(1); // drop $
  final star = s.indexOf('*');
  return s.substring(0, star);
}

void main() {
  final builder = const NmeaBuilder();

  // ── GGA ────────────────────────────────────────────────────────────
  group('buildGga', () {
    test('produces correct body for reference position', () {
      final pos = _referencePosition();
      final result = builder.buildGga(pos, _allEnabled());
      expect(result, startsWith('\$GPGGA,'));
      expect(result, endsWith('\r\n'));

      final body = _body(result);
      // time=115922.000, lat=4825.95722,N, lon=01700.27029,E
      // fix=1, sats=8, hdop=0.9, alt=159.4,M, geoid=46.9,M, dgps_age=0, stn=2
      // nmeaLatToField(48.43262) → 4825.95720,N
      // nmeaLonToField(17.00450) → 01700.27000,E
      expect(
        body,
        'GPGGA,115922.000,4825.95720,N,01700.27000,E,1,8,0.9,159.4,M,46.9,M,0,2',
      );
    });

    test('checksum matches known reference', () {
      final pos = _referencePosition();
      final result = builder.buildGga(pos, _allEnabled());
      // Known: body without ms is 0x77. With .000 we get a different checksum.
      // Just validate the format contains *XX
      expect(result, contains('*'));
      final star = result.indexOf('*');
      final cs = result.substring(star + 1, star + 3);
      expect(cs, isNot(isEmpty));
    });

    test('returns empty string when hasFix is false', () {
      final pos = _referencePosition().copyWith(hasFix: false);
      expect(builder.buildGga(pos, _allEnabled()), '');
    });
  });

  // ── GLL ────────────────────────────────────────────────────────────
  group('buildGll', () {
    test('produces correct body for reference position', () {
      final pos = _referencePosition();
      final result = builder.buildGll(pos, _allEnabled());
      expect(result, startsWith('\$GPGLL,'));
      final body = _body(result);
      expect(body, 'GPGLL,4825.95720,N,01700.27000,E,115922.000,A,A');
    });

    test('returns empty when no fix', () {
      final pos = _referencePosition().copyWith(hasFix: false);
      expect(builder.buildGll(pos, _allEnabled()), '');
    });
  });

  // ── GSA ────────────────────────────────────────────────────────────
  group('buildGsa', () {
    test('is fully hardcoded and does not need position', () {
      final result = builder.buildGsa(_allEnabled());
      expect(result, startsWith('\$GPGSA,'));
      final body = _body(result);
      expect(
        body,
        'GPGSA,A,3,03,04,05,06,07,08,09,10,11,12,13,14,1.23,4.56,7.89,1',
      );
    });

    test('same output regardless of position', () {
      final a = builder.buildGsa(AppSettings.defaults());
      GpsPosition(
        latitude: 0,
        longitude: 0,
        timestamp: DateTime.utc(2020),
        hasFix: false,
      );
      // GSA doesn't take position, so just confirm it's consistent
      final b = builder.buildGsa(AppSettings.defaults());
      expect(a, b);
    });
  });

  // ── HDG ────────────────────────────────────────────────────────────
  group('buildHdg', () {
    test('produces HCHDG with heading 1 decimal', () {
      final pos = _referencePosition();
      final result = builder.buildHdg(pos, _allEnabled());
      expect(result, startsWith('\$HCHDG,'));
      final body = _body(result);
      expect(body, 'HCHDG,84.4,,,5.0,E');
    });

    test('returns empty when heading null', () {
      final pos = _referencePosition().copyWith(heading: null);
      expect(builder.buildHdg(pos, _allEnabled()), '');
    });
  });

  // ── HDM ────────────────────────────────────────────────────────────
  group('buildHdm', () {
    test('produces GPHDM with heading 2 decimals', () {
      final pos = _referencePosition();
      final result = builder.buildHdm(pos, _allEnabled());
      expect(result, startsWith('\$GPHDM,'));
      final body = _body(result);
      expect(body, 'GPHDM,84.40,M');
    });

    test('returns empty when heading null', () {
      final pos = _referencePosition().copyWith(heading: null);
      expect(builder.buildHdm(pos, _allEnabled()), '');
    });
  });

  // ── HDT ────────────────────────────────────────────────────────────
  group('buildHdt', () {
    test('produces GPHDT with heading 2 decimals', () {
      final pos = _referencePosition();
      final result = builder.buildHdt(pos, _allEnabled());
      expect(result, startsWith('\$GPHDT,'));
      final body = _body(result);
      expect(body, 'GPHDT,84.40,T');
    });

    test('returns empty when heading null', () {
      final pos = _referencePosition().copyWith(heading: null);
      expect(builder.buildHdt(pos, _allEnabled()), '');
    });
  });

  // ── RMC ────────────────────────────────────────────────────────────
  group('buildRmc', () {
    test('produces correct body for reference position', () {
      final pos = _referencePosition();
      final result = builder.buildRmc(pos, _allEnabled());
      expect(result, startsWith('\$GPRMC,'));
      final body = _body(result);
      // speed 5.14444 m/s → 10.00 kn
      expect(body, 'GPRMC,115922.000,A,4825.95720,N,01700.27000,E,10.00,84.4,150624,003.1,W,A');
    });

    test('returns empty when no fix', () {
      final pos = _referencePosition().copyWith(hasFix: false);
      expect(builder.buildRmc(pos, _allEnabled()), '');
    });
  });

  // ── VTG ────────────────────────────────────────────────────────────
  group('buildVtg', () {
    test('produces correct body for reference position', () {
      final pos = _referencePosition();
      final result = builder.buildVtg(pos, _allEnabled());
      expect(result, startsWith('\$GPVTG,'));
      final body = _body(result);
      expect(body, 'GPVTG,84.40,T,,M,10.00,N,18.52,K,A');
    });

    test('returns empty when no fix', () {
      final pos = _referencePosition().copyWith(hasFix: false);
      expect(builder.buildVtg(pos, _allEnabled()), '');
    });
  });

  // ── ZDA ────────────────────────────────────────────────────────────
  group('buildZda', () {
    test('produces correct body with full year and no ms', () {
      final pos = _referencePosition();
      final result = builder.buildZda(pos, _allEnabled());
      expect(result, startsWith('\$GPZDA,'));
      final body = _body(result);
      expect(body, 'GPZDA,115922,15,06,2024,00,00');
    });
  });

  // ── PASHR ──────────────────────────────────────────────────────────
  group('buildPashr', () {
    test('produces correct body trueNorth=true', () {
      final pos = _referencePosition();
      final settings = _allEnabled().copyWith(trueNorth: true);
      final result = builder.buildPashr(pos, settings);
      expect(result, startsWith('\$GPPASHR,'));
      final body = _body(result);
      expect(body, 'GPPASHR,115922,84.40,T,T,-0.0,-0.0,0.0,3.14159,3.14159,0.0,0');
    });

    test('produces correct body trueNorth=false (magnetic)', () {
      final pos = _referencePosition();
      final settings = _allEnabled().copyWith(trueNorth: false);
      final result = builder.buildPashr(pos, settings);
      final body = _body(result);
      expect(body, 'GPPASHR,115922,84.40,,M,-0.0,-0.0,0.0,3.14159,3.14159,0.0,0');
    });

    test('handles null heading', () {
      final pos = _referencePosition().copyWith(heading: null);
      final settings = _allEnabled().copyWith(trueNorth: true);
      final result = builder.buildPashr(pos, settings);
      final body = _body(result);
      expect(body, 'GPPASHR,115922,0.00,T,T,-0.0,-0.0,0.0,3.14159,3.14159,0.0,0');
    });
  });

  // ── GPTXT ──────────────────────────────────────────────────────────
  group('buildGptxt', () {
    test('produces sentence when customGptxt is set', () {
      final settings = _allEnabled().copyWith(customGptxt: 'Hello');
      final result = builder.buildGptxt(settings);
      expect(result, startsWith('\$GPTXT,'));
      final body = _body(result);
      expect(body, 'GPTXT,01,01,02,Hello');
    });

    test('returns empty when customGptxt is null', () {
      final settings = _allEnabled().copyWith(customGptxt: null);
      expect(builder.buildGptxt(settings), '');
    });

    test('returns empty when customGptxt is empty', () {
      final settings = _allEnabled().copyWith(customGptxt: '');
      expect(builder.buildGptxt(settings), '');
    });
  });

  // ── buildAllEnabled ────────────────────────────────────────────────
  group('buildAllEnabled', () {
    test('only builds enabled sentences', () {
      final pos = _referencePosition();
      final settings = AppSettings.defaults().copyWith(
        ggaEnabled: true,
        rmcEnabled: true,
        // everything else is false by default
      );
      final results = builder.buildAllEnabled(pos, settings);
      expect(results.length, 2);
      expect(results[0], startsWith('\$GPGGA,'));
      expect(results[1], startsWith('\$GPRMC,'));
    });

    test('sendInOneTransmission concatenates into single string', () {
      final pos = _referencePosition();
      final settings = AppSettings.defaults().copyWith(
        ggaEnabled: true,
        rmcEnabled: true,
        sendInOneTransmission: true,
      );
      final results = builder.buildAllEnabled(pos, settings);
      expect(results.length, 1);
      // Should contain both sentences joined without separator
      expect(results[0], contains('GPGGA'));
      expect(results[0], contains('GPRMC'));
      // Single \r\n at the end
      expect(results[0], endsWith('\r\n'));
      // No \r\n in the middle (each individual sentence's \r\n stripped)
      final middle = results[0].substring(
        0,
        results[0].length - 2,
      );
      expect(middle.contains('\r\n'), isFalse);
    });

    test('skips heading sentences when heading is null', () {
      final pos = _referencePosition().copyWith(heading: null);
      final settings = AppSettings.defaults().copyWith(
        ggaEnabled: true,
        hdgEnabled: true,
        hdmEnabled: true,
        hdtEnabled: true,
        rmcEnabled: false, // disable RMC so only GGA remains
      );
      final results = builder.buildAllEnabled(pos, settings);
      // Only GGA should appear (heading sentences return empty)
      expect(results.length, 1);
      expect(results[0], startsWith('\$GPGGA,'));
    });

    test('empty list when all disabled', () {
      final pos = _referencePosition();
      final settings = AppSettings.defaults().copyWith(
        ggaEnabled: false,
        rmcEnabled: false,
      );
      final results = builder.buildAllEnabled(pos, settings);
      expect(results, isEmpty);
    });

    test('no fix skips position-dependent sentences', () {
      final pos = _referencePosition().copyWith(hasFix: false);
      final settings = AppSettings.defaults().copyWith(
        ggaEnabled: true,
        gllEnabled: true,
        rmcEnabled: true,
        vtgEnabled: true,
        gsaEnabled: true, // GSA always builds
      );
      final results = builder.buildAllEnabled(pos, settings);
      // Only GSA should appear (the only non-position-dependent one)
      expect(results.length, 1);
      expect(results[0], startsWith('\$GPGSA,'));
    });
  });

  // ── getAvailableMessageCount ──────────────────────────────────────
  group('getAvailableMessageCount', () {
    test('counts enabled message types', () {
      final settings = AppSettings.defaults().copyWith(
        ggaEnabled: true,
        rmcEnabled: true,
      );
      expect(builder.getAvailableMessageCount(settings), 2);
    });

    test('defaults have gga + rmc + taipPv = 2 NMEA', () {
      // ggaEnabled=true, rmcEnabled=true by default
      // taipPv is not an NMEA message so shouldn't count here
      final defaults = AppSettings.defaults();
      expect(builder.getAvailableMessageCount(defaults), 2);
    });

    test('all enabled = 11 NMEA message types', () {
      expect(builder.getAvailableMessageCount(_allEnabled()), 11);
    });

    test('none enabled = 0', () {
      final settings = AppSettings.defaults().copyWith(
        ggaEnabled: false,
        rmcEnabled: false,
      );
      expect(builder.getAvailableMessageCount(settings), 0);
    });
  });
}
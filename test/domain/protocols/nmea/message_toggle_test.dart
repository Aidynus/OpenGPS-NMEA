import 'package:flutter_test/flutter_test.dart';
import 'package:opengps_nmea/domain/models/app_settings.dart';
import 'package:opengps_nmea/domain/models/gps_position.dart';
import 'package:opengps_nmea/domain/protocols/nmea/nmea_builder.dart';

/// Reference position with fix and heading for testing enabled messages.
GpsPosition _pos() => GpsPosition(
      latitude: 48.43262,
      longitude: 17.00450,
      altitude: 159.4,
      speed: 5.14444,
      heading: 84.4,
      timestamp: DateTime.utc(2024, 6, 15, 11, 59, 22),
      hasFix: true,
    );

/// Position without fix — position-dependent messages should be skipped.
GpsPosition _noFixPos() => GpsPosition(
      latitude: 48.43262,
      longitude: 17.00450,
      altitude: 159.4,
      speed: 5.14444,
      heading: 84.4,
      timestamp: DateTime.utc(2024, 6, 15, 11, 59, 22),
      hasFix: false,
    );

/// Position with fix but null heading — heading sentences should be skipped.
GpsPosition _noHeadingPos() => GpsPosition(
      latitude: 48.43262,
      longitude: 17.00450,
      altitude: 159.4,
      speed: 5.14444,
      heading: null,
      timestamp: DateTime.utc(2024, 6, 15, 11, 59, 22),
      hasFix: true,
    );

/// All NMEA toggles in AppSettings for reference.
const _nmeaToggleFieldNames = [
  'ggaEnabled',
  'gllEnabled',
  'gsaEnabled',
  'hdgEnabled',
  'hdmEnabled',
  'hdtEnabled',
  'rmcEnabled',
  'vtgEnabled',
  'zdaEnabled',
  'pashrEnabled',
  'gptxtEnabled',
];

void main() {
  final builder = const NmeaBuilder();

  // ── Individual toggle enable/disable ──────────────────────────────────

  group('individual toggle enables its message', () {
    for (final field in _nmeaToggleFieldNames) {
      test('$field toggle enables its message', () {
        // Start from all-disabled and enable just this one toggle.
        final settings = AppSettings.defaults().copyWith(
          ggaEnabled: false,
          gllEnabled: false,
          gsaEnabled: false,
          hdgEnabled: false,
          hdmEnabled: false,
          hdtEnabled: false,
          rmcEnabled: false,
          vtgEnabled: false,
          zdaEnabled: false,
          pashrEnabled: false,
          gptxtEnabled: false,
          customGptxt: field == 'gptxtEnabled' ? 'test' : null,
        );

        // Enable only the one under test.
        final singleEnabled = _enableOnly(settings, field);

        final results = builder.buildAllEnabled(_pos(), singleEnabled);
        // GPTXT returns empty when customGptxt is null (default).
        // For the gptxtEnabled test, we set customGptxt above.
        if (field == 'gptxtEnabled') {
          expect(results.length, 1, reason: '$field should produce exactly 1 message');
          expect(results.first, startsWith('\$GPTXT,'));
        } else if (field == 'gsaEnabled') {
          // GSA doesn't require position, so it always builds if enabled.
          expect(results.length, 1, reason: '$field should produce exactly 1 message');
          expect(results.first, startsWith('\$GPGSA,'));
        } else {
          // All others require position fix.
          expect(results.length, 1, reason: '$field should produce exactly 1 message');
          expect(results.first, isNotEmpty);
        }
      });
    }
  });

  group('individual toggle disables its message', () {
    for (final field in _nmeaToggleFieldNames) {
      test('$field toggle disabled skips its message', () {
        // Enable all, then disable just one.
        final allOn = AppSettings.defaults().copyWith(
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
          customGptxt: 'test',
        );

        final singleOff = _disableOnly(allOn, field);
        final results = builder.buildAllEnabled(_pos(), singleOff);

        // With 11 toggles total, disabling one should yield 10.
        expect(results.length, 10, reason: 'Disabling $field should yield 10 messages');
      });
    }
  });

  // ── Default settings produce expected messages ─────────────────────────

  group('default settings', () {
    test('defaults produce GGA and RMC only', () {
      final defaults = AppSettings.defaults();
      final results = builder.buildAllEnabled(_pos(), defaults);
      // Defaults: ggaEnabled=true, rmcEnabled=true, everything else false.
      expect(results.length, 2);
      expect(results[0], startsWith('\$GPGGA,'));
      expect(results[1], startsWith('\$GPRMC,'));
    });

    test('default message count is 2 (GGA + RMC)', () {
      final defaults = AppSettings.defaults();
      expect(builder.getAvailableMessageCount(defaults), 2);
    });

    test('gptxtEnabled with null customGptxt produces no GPTXT', () {
      final settings = AppSettings.defaults().copyWith(
        gptxtEnabled: true,
        // customGptxt is null by default
      );
      final results = builder.buildAllEnabled(_pos(), settings);
      // GGA + RMC + no GPTXT (null text) = 2
      expect(results.length, 2);
      for (final r in results) {
        expect(r, isNot(startsWith('\$GPTXT,')));
      }
    });

    test('gptxtEnabled with empty customGptxt produces no GPTXT', () {
      final settings = AppSettings.defaults().copyWith(
        gptxtEnabled: true,
        customGptxt: '',
      );
      final results = builder.buildAllEnabled(_pos(), settings);
      expect(results.length, 2);
      for (final r in results) {
        expect(r, isNot(startsWith('\$GPTXT,')));
      }
    });

    test('gptxtEnabled with customGptxt produces GPTXT', () {
      final settings = AppSettings.defaults().copyWith(
        gptxtEnabled: true,
        customGptxt: 'Hello',
      );
      final results = builder.buildAllEnabled(_pos(), settings);
      // GGA + RMC + GPTXT = 3
      expect(results.length, 3);
      expect(results[2], startsWith('\$GPTXT,'));
    });
  });

  // ── Toggle combinations ───────────────────────────────────────────────

  group('toggle combinations', () {
    test('enabling all heading toggles produces 3 heading messages', () {
      final settings = AppSettings.defaults().copyWith(
        hdgEnabled: true,
        hdmEnabled: true,
        hdtEnabled: true,
      );
      final results = builder.buildAllEnabled(_pos(), settings);
      // GGA + RMC + HDG + HDM + HDT = 5
      expect(results.length, 5);
      expect(results.where((s) => s.contains('HCHDG')).length, 1);
      expect(results.where((s) => s.contains('GPHDM')).length, 1);
      expect(results.where((s) => s.contains('GPHDT')).length, 1);
    });

    test('null heading disables all heading sentences', () {
      final settings = AppSettings.defaults().copyWith(
        hdgEnabled: true,
        hdmEnabled: true,
        hdtEnabled: true,
      );
      final results = builder.buildAllEnabled(_noHeadingPos(), settings);
      // Only GGA + RMC survive (heading sentences return '')
      expect(results.length, 2);
    });

    test('no fix disables position-dependent sentences but not GSA', () {
      final settings = AppSettings.defaults().copyWith(
        ggaEnabled: true,
        gllEnabled: true,
        gsaEnabled: true,
        rmcEnabled: true,
        vtgEnabled: true,
      );
      final results = builder.buildAllEnabled(_noFixPos(), settings);
      // Only GSA survives (doesn't need position)
      expect(results.length, 1);
      expect(results.first, startsWith('\$GPGSA,'));
    });

    test('all 11 NMEA toggles enabled with fix yields 11 messages', () {
      final settings = AppSettings.defaults().copyWith(
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
        customGptxt: 'test',
      );
      final results = builder.buildAllEnabled(_pos(), settings);
      expect(results.length, 11);
    });

    test('all toggles off yields empty list', () {
      final settings = AppSettings.defaults().copyWith(
        ggaEnabled: false,
        gllEnabled: false,
        gsaEnabled: false,
        hdgEnabled: false,
        hdmEnabled: false,
        hdtEnabled: false,
        rmcEnabled: false,
        vtgEnabled: false,
        zdaEnabled: false,
        pashrEnabled: false,
        gptxtEnabled: false,
      );
      final results = builder.buildAllEnabled(_pos(), settings);
      expect(results, isEmpty);
    });

    test('ZDA produces message even without fix (only needs timestamp)', () {
      final settings = AppSettings.defaults().copyWith(
        zdaEnabled: true,
        ggaEnabled: false,
        rmcEnabled: false,
      );
      final results = builder.buildAllEnabled(_noFixPos(), settings);
      expect(results.length, 1);
      expect(results.first, startsWith('\$GPZDA,'));
    });

    test('PASHR produces message even without fix (heading defaults to 0)', () {
      final settings = AppSettings.defaults().copyWith(
        pashrEnabled: true,
        ggaEnabled: false,
        rmcEnabled: false,
      );
      // PASHR with null heading uses '0.00' — always non-empty
      final results = builder.buildAllEnabled(_noHeadingPos(), settings);
      expect(results.length, 1);
      expect(results.first, startsWith('\$GPPASHR,'));
    });
  });

  // ── getAvailableMessageCount ───────────────────────────────────────────

  group('getAvailableMessageCount', () {
    test('counts only NMEA messages, not TAIP', () {
      final defaults = AppSettings.defaults();
      // taipPvEnabled is true by default but shouldn't count here
      expect(builder.getAvailableMessageCount(defaults), 2);
    });

    test('each toggle adds exactly 1 to count', () {
      var settings = AppSettings.defaults().copyWith(
        ggaEnabled: false,
        gllEnabled: false,
        gsaEnabled: false,
        hdgEnabled: false,
        hdmEnabled: false,
        hdtEnabled: false,
        rmcEnabled: false,
        vtgEnabled: false,
        zdaEnabled: false,
        pashrEnabled: false,
        gptxtEnabled: false,
      );
      expect(builder.getAvailableMessageCount(settings), 0);

      final toggles = <String, bool Function(AppSettings)>{
        'gga': (s) => s.ggaEnabled,
        'gll': (s) => s.gllEnabled,
        'gsa': (s) => s.gsaEnabled,
        'hdg': (s) => s.hdgEnabled,
        'hdm': (s) => s.hdmEnabled,
        'hdt': (s) => s.hdtEnabled,
        'rmc': (s) => s.rmcEnabled,
        'vtg': (s) => s.vtgEnabled,
        'zda': (s) => s.zdaEnabled,
        'pashr': (s) => s.pashrEnabled,
        'gptxt': (s) => s.gptxtEnabled,
      };

      var count = 0;
      for (final entry in toggles.entries) {
        count++;
        settings = settings.copyWith(
          ggaEnabled: toggles['gga']!(settings) || entry.key == 'gga',
          gllEnabled: toggles['gll']!(settings) || entry.key == 'gll',
          gsaEnabled: toggles['gsa']!(settings) || entry.key == 'gsa',
          hdgEnabled: toggles['hdg']!(settings) || entry.key == 'hdg',
          hdmEnabled: toggles['hdm']!(settings) || entry.key == 'hdm',
          hdtEnabled: toggles['hdt']!(settings) || entry.key == 'hdt',
          rmcEnabled: toggles['rmc']!(settings) || entry.key == 'rmc',
          vtgEnabled: toggles['vtg']!(settings) || entry.key == 'vtg',
          zdaEnabled: toggles['zda']!(settings) || entry.key == 'zda',
          pashrEnabled: toggles['pashr']!(settings) || entry.key == 'pashr',
          gptxtEnabled: toggles['gptxt']!(settings) || entry.key == 'gptxt',
        );
        // Re-enable the current toggle in settings
        settings = _enableToggle(settings, entry.key);
        expect(
          builder.getAvailableMessageCount(settings),
          count,
          reason: 'After enabling ${entry.key}, count should be $count',
        );
      }
    });
  });

  // ── sendInOneTransmission ──────────────────────────────────────────────

  group('sendInOneTransmission', () {
    test('concatenates all messages into single string', () {
      final settings = AppSettings.defaults().copyWith(
        ggaEnabled: true,
        rmcEnabled: true,
        sendInOneTransmission: true,
      );
      final results = builder.buildAllEnabled(_pos(), settings);
      expect(results.length, 1);
      expect(results.first, contains('GPGGA'));
      expect(results.first, contains('GPRMC'));
      expect(results.first, endsWith('\r\n'));
    });

    test('separated mode returns individual strings', () {
      final settings = AppSettings.defaults().copyWith(
        ggaEnabled: true,
        rmcEnabled: true,
        sendInOneTransmission: false,
      );
      final results = builder.buildAllEnabled(_pos(), settings);
      expect(results.length, 2);
      for (final r in results) {
        expect(r, endsWith('\r\n'));
      }
    });
  });
}

/// Enable only a single NMEA toggle, keeping all others disabled.
AppSettings _enableOnly(AppSettings base, String field) {
  return base.copyWith(
    ggaEnabled: field == 'ggaEnabled',
    gllEnabled: field == 'gllEnabled',
    gsaEnabled: field == 'gsaEnabled',
    hdgEnabled: field == 'hdgEnabled',
    hdmEnabled: field == 'hdmEnabled',
    hdtEnabled: field == 'hdtEnabled',
    rmcEnabled: field == 'rmcEnabled',
    vtgEnabled: field == 'vtgEnabled',
    zdaEnabled: field == 'zdaEnabled',
    pashrEnabled: field == 'pashrEnabled',
    gptxtEnabled: field == 'gptxtEnabled',
    customGptxt: field == 'gptxtEnabled' ? 'test' : null,
  );
}

/// Disable a single NMEA toggle, keeping all others enabled.
AppSettings _disableOnly(AppSettings base, String field) {
  return base.copyWith(
    ggaEnabled: field != 'ggaEnabled',
    gllEnabled: field != 'gllEnabled',
    gsaEnabled: field != 'gsaEnabled',
    hdgEnabled: field != 'hdgEnabled',
    hdmEnabled: field != 'hdmEnabled',
    hdtEnabled: field != 'hdtEnabled',
    rmcEnabled: field != 'rmcEnabled',
    vtgEnabled: field != 'vtgEnabled',
    zdaEnabled: field != 'zdaEnabled',
    pashrEnabled: field != 'pashrEnabled',
    gptxtEnabled: field != 'gptxtEnabled',
  );
}

/// Enable a single toggle by name.
AppSettings _enableToggle(AppSettings s, String name) {
  return s.copyWith(
    ggaEnabled: s.ggaEnabled || name == 'gga',
    gllEnabled: s.gllEnabled || name == 'gll',
    gsaEnabled: s.gsaEnabled || name == 'gsa',
    hdgEnabled: s.hdgEnabled || name == 'hdg',
    hdmEnabled: s.hdmEnabled || name == 'hdm',
    hdtEnabled: s.hdtEnabled || name == 'hdt',
    rmcEnabled: s.rmcEnabled || name == 'rmc',
    vtgEnabled: s.vtgEnabled || name == 'vtg',
    zdaEnabled: s.zdaEnabled || name == 'zda',
    pashrEnabled: s.pashrEnabled || name == 'pashr',
    gptxtEnabled: s.gptxtEnabled || name == 'gptxt',
  );
}
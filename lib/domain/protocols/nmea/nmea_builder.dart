import 'package:opengps_nmea/core/utils/nmea_formatter.dart';
import 'package:opengps_nmea/core/utils/nmea_utils.dart';
import 'package:opengps_nmea/domain/models/app_settings.dart';
import 'package:opengps_nmea/domain/models/gps_position.dart';

/// Builds NMEA 0183 sentences from a [GpsPosition] and [AppSettings].
///
/// Some fields that iOS Core Location cannot provide (satellite IDs, HDOP,
/// geoid separation) are hardcoded to realistic values so downstream
/// navigation software receives structurally valid NMEA sentences.
///
/// Ownership of the "send in one transmission" bundling lives entirely here
/// — [TransmissionCoordinator] must not re-bundle the result.
class NmeaBuilder {
  const NmeaBuilder();

  // ── Position sentences ──────────────────────────────────────────────────

  /// $GPGGA — Global Positioning System Fix Data.
  ///
  /// Hardcoded: fix quality=1, satellites=8, HDOP=0.9, geoid sep=46.9 M,
  /// DGPS age=0, DGPS station=2.
  String buildGga(GpsPosition pos, AppSettings settings) {
    if (!pos.hasFix) return '';
    final time = nmeaTimeField(pos.timestamp, withMilliseconds: true);
    final lat = nmeaLatToField(pos.latitude);
    final lon = nmeaLonToField(pos.longitude);
    final alt = pos.altitude?.toStringAsFixed(1) ?? '';
    return buildNmeaSentence(
      'GP',
      'GGA',
      '$time,$lat,$lon,1,8,0.9,$alt,M,46.9,M,0,2',
    );
  }

  /// $GPGLL — Geographic Position – Latitude/Longitude.
  String buildGll(GpsPosition pos, AppSettings settings) {
    if (!pos.hasFix) return '';
    final time = nmeaTimeField(pos.timestamp, withMilliseconds: true);
    final lat = nmeaLatToField(pos.latitude);
    final lon = nmeaLonToField(pos.longitude);
    return buildNmeaSentence('GP', 'GLL', '$lat,$lon,$time,A,A');
  }

  /// $GPGSA — DOP and Active Satellites.
  ///
  /// Entirely hardcoded (iOS cannot provide individual satellite data).
  /// Does NOT depend on [GpsPosition]; the parameter was removed to make
  /// the signature honest.
  String buildGsa(AppSettings settings) {
    const sats = '03,04,05,06,07,08,09,10,11,12,13,14';
    return buildNmeaSentence('GP', 'GSA', 'A,3,$sats,1.23,4.56,7.89,1');
  }

  // ── Heading sentences ───────────────────────────────────────────────────

  /// $HCHDG — Heading – Magnetic + Deviation + Variation.
  ///
  /// Talker is HC (not GP). Returns empty string when heading is null.
  String buildHdg(GpsPosition pos, AppSettings settings) {
    final heading = pos.heading;
    if (heading == null) return '';
    final headingStr = heading.toStringAsFixed(1);
    final varDir = heading >= 0 ? 'E' : 'W';
    return buildNmeaSentence('HC', 'HDG', '$headingStr,,,5.0,$varDir');
  }

  /// $GPHDM — Heading – Magnetic.
  String buildHdm(GpsPosition pos, AppSettings settings) {
    final heading = pos.heading;
    if (heading == null) return '';
    return buildNmeaSentence('GP', 'HDM', '${heading.toStringAsFixed(2)},M');
  }

  /// $GPHDT — Heading – True.
  String buildHdt(GpsPosition pos, AppSettings settings) {
    final heading = pos.heading;
    if (heading == null) return '';
    return buildNmeaSentence('GP', 'HDT', '${heading.toStringAsFixed(2)},T');
  }

  // ── Recommended Minimum & Track ─────────────────────────────────────────

  /// $GPRMC — Recommended Minimum Specific GNSS Data.
  String buildRmc(GpsPosition pos, AppSettings settings) {
    if (!pos.hasFix) return '';
    final time = nmeaTimeField(pos.timestamp, withMilliseconds: true);
    final lat = nmeaLatToField(pos.latitude);
    final lon = nmeaLonToField(pos.longitude);
    final speed = knotsToNmeaSpeed(pos.speed ?? 0.0);
    final track = pos.heading?.toStringAsFixed(1) ?? '0.0';
    final date = nmeaDateField(pos.timestamp);
    return buildNmeaSentence(
      'GP',
      'RMC',
      '$time,A,$lat,$lon,$speed,$track,$date,003.1,W,A',
    );
  }

  /// $GPVTG — Track Made Good and Ground Speed.
  String buildVtg(GpsPosition pos, AppSettings settings) {
    if (!pos.hasFix) return '';
    final track = pos.heading?.toStringAsFixed(2) ?? '0.00';
    final speedKnots = knotsToNmeaSpeed(pos.speed ?? 0.0);
    final speedKm = kmPerHourToNmeaSpeed(pos.speed ?? 0.0);
    return buildNmeaSentence(
      'GP',
      'VTG',
      '$track,T,,M,$speedKnots,N,$speedKm,K,A',
    );
  }

  // ── Time & date ─────────────────────────────────────────────────────────

  /// $GPZDA — Time & Date.
  String buildZda(GpsPosition pos, AppSettings settings) {
    final time = nmeaTimeField(pos.timestamp);
    final day = pos.timestamp.day.toString().padLeft(2, '0');
    final month = pos.timestamp.month.toString().padLeft(2, '0');
    final year = pos.timestamp.year.toString();
    return buildNmeaSentence('GP', 'ZDA', '$time,$day,$month,$year,00,00');
  }

  // ── Proprietary / extended ──────────────────────────────────────────────

  /// $PASHR — Attitude Data (Ashtech-compatible).
  String buildPashr(GpsPosition pos, AppSettings settings) {
    final time = nmeaTimeField(pos.timestamp);
    final heading = pos.heading?.toStringAsFixed(2) ?? '0.00';
    final trueOrMag = settings.trueNorth ? 'T' : '';
    final tOrM = settings.trueNorth ? 'T' : 'M';
    return buildNmeaSentence(
      'GP',
      'PASHR',
      '$time,$heading,$trueOrMag,$tOrM,-0.0,-0.0,0.0,3.14159,3.14159,0.0,0',
    );
  }

  /// $GPTXT — Text Transmission.
  ///
  /// Returns empty string when [AppSettings.customGptxt] is null or empty.
  String buildGptxt(AppSettings settings) {
    final text = settings.customGptxt;
    if (text == null || text.isEmpty) return '';
    return buildNmeaSentence('GP', 'TXT', '01,01,02,$text');
  }

  // ── Orchestration ────────────────────────────────────────────────────────

  /// Builds all enabled NMEA sentences based on [settings] toggles.
  ///
  /// When [AppSettings.sendInOneTransmission] is true, returns a
  /// single-element list with all sentences concatenated, terminated by a
  /// single `\r\n`. Otherwise each sentence is a separate list element.
  ///
  /// This method is the single owner of the bundling logic — callers must
  /// NOT re-bundle the result.
  List<String> buildAllEnabled(GpsPosition pos, AppSettings settings) {
    final sentences = <String>[];

    if (settings.ggaEnabled) {
      final s = buildGga(pos, settings);
      if (s.isNotEmpty) sentences.add(s);
    }
    if (settings.gllEnabled) {
      final s = buildGll(pos, settings);
      if (s.isNotEmpty) sentences.add(s);
    }
    if (settings.gsaEnabled) {
      final s = buildGsa(settings);
      if (s.isNotEmpty) sentences.add(s);
    }
    if (settings.hdgEnabled) {
      final s = buildHdg(pos, settings);
      if (s.isNotEmpty) sentences.add(s);
    }
    if (settings.hdmEnabled) {
      final s = buildHdm(pos, settings);
      if (s.isNotEmpty) sentences.add(s);
    }
    if (settings.hdtEnabled) {
      final s = buildHdt(pos, settings);
      if (s.isNotEmpty) sentences.add(s);
    }
    if (settings.rmcEnabled) {
      final s = buildRmc(pos, settings);
      if (s.isNotEmpty) sentences.add(s);
    }
    if (settings.vtgEnabled) {
      final s = buildVtg(pos, settings);
      if (s.isNotEmpty) sentences.add(s);
    }
    if (settings.zdaEnabled) {
      final s = buildZda(pos, settings);
      if (s.isNotEmpty) sentences.add(s);
    }
    if (settings.pashrEnabled) {
      final s = buildPashr(pos, settings);
      if (s.isNotEmpty) sentences.add(s);
    }
    if (settings.gptxtEnabled) {
      final s = buildGptxt(settings);
      if (s.isNotEmpty) sentences.add(s);
    }

    if (sentences.isEmpty) return [];

    if (settings.sendInOneTransmission) {
      // Strip trailing \r\n from each sentence then join, appending a single \r\n.
      final joined = sentences.map((s) {
        return s.endsWith('\r\n') ? s.substring(0, s.length - 2) : s;
      }).join('');
      return ['$joined\r\n'];
    }

    return sentences;
  }

  /// Returns the number of NMEA message types currently enabled.
  int getAvailableMessageCount(AppSettings settings) {
    var count = 0;
    if (settings.ggaEnabled) count++;
    if (settings.gllEnabled) count++;
    if (settings.gsaEnabled) count++;
    if (settings.hdgEnabled) count++;
    if (settings.hdmEnabled) count++;
    if (settings.hdtEnabled) count++;
    if (settings.rmcEnabled) count++;
    if (settings.vtgEnabled) count++;
    if (settings.zdaEnabled) count++;
    if (settings.pashrEnabled) count++;
    if (settings.gptxtEnabled) count++;
    return count;
  }
}

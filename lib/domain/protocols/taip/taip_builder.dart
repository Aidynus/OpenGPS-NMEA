import '../../models/gps_position.dart';
import '../../models/app_settings.dart';

/// TAIP protocol message builder.
///
/// TAIP (Trimble ASCII Interface Protocol) is a lightweight ASCII protocol.
/// Message format: `>R{message_type}{data};ID={device_id};*{checksum}<`
/// Checksum: 8-bit XOR of all bytes between `>` and `*` (exclusive),
/// formatted as 2 uppercase hex digits.
class TaipBuilder {
  const TaipBuilder();

  // ── Public API ──────────────────────────────────────────────────────

  /// Builds a PV (Position/Velocity) TAIP message.
  ///
  /// Data fields: time(HHMMSS) + lat(±DDMMSSss) + lon(±DDDMMSSss)
  ///              + speed(m/s×100, 4 digits) + heading(°×100, 4 digits)
  ///              + source(0=2D GPS, 1=3D GPS)
  String buildPv(GpsPosition pos, AppSettings settings) {
    final time = formatTaipTime(pos.timestamp);
    final lat = formatTaipLatitude(pos.latitude);
    final lon = formatTaipLongitude(pos.longitude);
    final speed = _pad4(((pos.speed ?? 0.0) * 100).round());
    final heading = _pad4(((pos.heading ?? 0.0) * 100).round());
    final source = pos.hasFix ? '1' : '0';

    return _wrapMessage(
      'PV$time$lat$lon$speed$heading$source',
      settings.taipDeviceId,
    );
  }

  /// Builds an AL (Altitude) TAIP message.
  ///
  /// Data fields: time(HHMMSS) + lat(±DDMMSSss) + lon(±DDDMMSSss)
  ///              + altitude(meters, 5 digits) + vertical velocity(cm/s, signed)
  String buildAl(GpsPosition pos, AppSettings settings) {
    final time = formatTaipTime(pos.timestamp);
    final lat = formatTaipLatitude(pos.latitude);
    final lon = formatTaipLongitude(pos.longitude);
    final alt = _pad5((pos.altitude ?? 0.0).round());
    // GpsPosition has no vertical velocity; default to 0.
    final vertVel = _signedVerticalVelocity(0);

    return _wrapMessage(
      'AL$time$lat$lon$alt$vertVel',
      settings.taipDeviceId,
    );
  }

  /// Builds all enabled TAIP messages based on [AppSettings] toggles.
  List<String> buildAllEnabled(GpsPosition pos, AppSettings settings) {
    final messages = <String>[];
    if (settings.taipPvEnabled) {
      messages.add(buildPv(pos, settings));
    }
    if (settings.taipAlEnabled) {
      messages.add(buildAl(pos, settings));
    }
    return messages;
  }

  // ── Formatters ──────────────────────────────────────────────────────

  /// Formats a [DateTime] as HHMMSS (UTC-based time of day).
  String formatTaipTime(DateTime dt) {
    final utc = dt.toUtc();
    return '${_pad2(utc.hour)}${_pad2(utc.minute)}${_pad2(utc.second)}';
  }

  /// Formats latitude as ±DDMMSSss.
  /// Positive (North) → `+`, Negative (South) → `-`.
  /// DD = degrees, MM = minutes, SS = seconds, ss = hundredths of seconds.
  String formatTaipLatitude(double lat) {
    final sign = lat >= 0 ? '+' : '-';
    return sign + _dmsString(lat.abs(), degDigits: 2);
  }

  /// Formats longitude as ±DDDMMSSss.
  /// Positive (East) → `+`, Negative (West) → `-`.
  /// DDD = degrees, MM = minutes, SS = seconds, ss = hundredths of seconds.
  String formatTaipLongitude(double lon) {
    final sign = lon >= 0 ? '+' : '-';
    return sign + _dmsString(lon.abs(), degDigits: 3);
  }

  /// Calculates 8-bit XOR checksum of all bytes in [data].
  int taipChecksum(String data) {
    var checksum = 0;
    for (var i = 0; i < data.length; i++) {
      checksum ^= data.codeUnitAt(i);
    }
    return checksum & 0xFF;
  }

  // ── Internals ───────────────────────────────────────────────────────

  /// Wraps a TAIP message body: `>R{body};ID={deviceId};*{checksum}<`
  String _wrapMessage(String body, String deviceId) {
    final inner = '$body;ID=$deviceId;';
    final checksum = taipChecksum(inner).toRadixString(16).toUpperCase();
    return '>R$inner*${checksum.padLeft(2, '0')}<';
  }

  /// Converts decimal degrees to DMS string with hundredths of seconds.
  /// Returns DDMMSSss or DDDMMSSss depending on [degDigits].
  String _dmsString(double decimalDegrees, {required int degDigits}) {
    final deg = decimalDegrees.floor();
    final minDecimal = (decimalDegrees - deg) * 60;
    final min = minDecimal.floor();
    final secDecimal = (minDecimal - min) * 60;
    final sec = secDecimal.floor();
    final secHundredths = ((secDecimal - sec) * 100).round();
    // Handle rounding overflow (e.g. 59.996 → 60.00 → carry)
    if (secHundredths >= 100) {
      return _dmsString(decimalDegrees + 0.00001, degDigits: degDigits);
    }
    return '${deg.toString().padLeft(degDigits, '0')}'
        '${min.toString().padLeft(2, '0')}'
        '${sec.toString().padLeft(2, '0')}'
        '${secHundredths.toString().padLeft(2, '0')}';
  }

  /// Formats signed vertical velocity as sign + 5 zero-padded digits (cm/s).
  String _signedVerticalVelocity(int cmPerSec) {
    final sign = cmPerSec >= 0 ? '+' : '-';
    return '$sign${cmPerSec.abs().toString().padLeft(5, '0')}';
  }

  // ── Padding helpers ─────────────────────────────────────────────────

  static String _pad2(int n) => n.toString().padLeft(2, '0');
  static String _pad4(int n) => n.toString().padLeft(4, '0');
  static String _pad5(int n) => n.toString().padLeft(5, '0');
}
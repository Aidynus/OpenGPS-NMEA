import 'dart:typed_data';

import 'package:opengps_nmea/domain/models/gps_position.dart';

/// Encoder for the Bluetooth SIG Location and Navigation Service (0x1819),
/// "Location and Speed" characteristic (0x2A67).
///
/// This is the standard profile the Jetour head unit application already
/// reads (the same one GPS2IP in Bluetooth mode advertises).
///
/// Packet layout (all little-endian):
///   flags  uint16   bit0 = speed present, bit2 = location present,
///                   bit4 = heading present
///   speed  uint16   0.01 m/s                      (if bit0)
///   lat    sint32   1e-7 degrees                  (bit2)
///   lon    sint32   1e-7 degrees                  (bit2)
///   head   uint16   0.01 degrees                  (if bit4)
class LnsEncoder {
  LnsEncoder._();

  static const int flagSpeed = 0x0001;
  static const int flagLocation = 0x0004;
  static const int flagHeading = 0x0010;

  /// Returns null when there is no usable fix.
  static Uint8List? encodeLocationAndSpeed(GpsPosition pos) {
    if (!pos.hasFix) return null;

    final speed = pos.speed;
    final heading = pos.heading;
    final hasSpeed = speed != null && speed >= 0;
    final hasHeading = heading != null && heading >= 0;

    var flags = flagLocation;
    if (hasSpeed) flags |= flagSpeed;
    if (hasHeading) flags |= flagHeading;

    final length = 2 + (hasSpeed ? 2 : 0) + 8 + (hasHeading ? 2 : 0);
    final data = ByteData(length);
    var offset = 0;

    data.setUint16(offset, flags, Endian.little);
    offset += 2;

    if (hasSpeed) {
      final centimetresPerSecond =
          (speed! * 100).round().clamp(0, 0xFFFF).toInt();
      data.setUint16(offset, centimetresPerSecond, Endian.little);
      offset += 2;
    }

    final lat = (pos.latitude * 1e7).round().clamp(-900000000, 900000000).toInt();
    final lon =
        (pos.longitude * 1e7).round().clamp(-1800000000, 1800000000).toInt();
    data.setInt32(offset, lat, Endian.little);
    offset += 4;
    data.setInt32(offset, lon, Endian.little);
    offset += 4;

    if (hasHeading) {
      final hundredthsOfDegree =
          ((heading! % 360) * 100).round().clamp(0, 35999).toInt();
      data.setUint16(offset, hundredthsOfDegree, Endian.little);
      offset += 2;
    }

    return data.buffer.asUint8List();
  }
}

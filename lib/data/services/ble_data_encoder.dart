import 'dart:typed_data';

import 'package:opengps_nmea/domain/models/gps_position.dart';

/// Encodes GpsPosition data into BLE Location and Navigation Service
/// binary formats per Bluetooth SIG LNS_v1.0.1 specification.
class BleDataEncoder {
  BleDataEncoder._();

  // --- LN Feature flags (Read characteristic) ---
  static const int _lnFeatureInstantaneousSpeed = 1 << 0;
  static const int _lnFeatureLocation = 1 << 2;
  static const int _lnFeatureElevation = 1 << 3;
  static const int _lnFeatureHeading = 1 << 4;
  static const int _lnFeatureUtcTime = 1 << 6;

  // --- Location and Speed flags (Notify) ---
  static const int _lasFlagInstantaneousSpeed = 1 << 0;
  static const int _lasFlagLocation = 1 << 2;
  static const int _lasFlagElevation = 1 << 3;
  static const int _lasFlagHeading = 1 << 4;
  static const int _lasFlagUtcTime = 1 << 6;

  // --- Navigation flags (Notify) ---
  static const int _navFlagBearing = 1 << 0;
  static const int _navFlagHeading = 1 << 1;
  static const int _navFlagEta = 1 << 4;

  /// Encodes the LN Feature characteristic value as 4-byte UInt32 LE.
  /// Bits set: InstantaneousSpeed, Location, Elevation, Heading, UTC Time.
  static Uint8List encodeLnFeature() {
    const int features = _lnFeatureInstantaneousSpeed |
        _lnFeatureLocation |
        _lnFeatureElevation |
        _lnFeatureHeading |
        _lnFeatureUtcTime;

    final data = ByteData(4);
    data.setUint32(0, features, Endian.little);
    return data.buffer.asUint8List();
  }

  /// Encodes [pos] into Location and Speed characteristic value.
  ///
  /// Fields present based on available GpsPosition data:
  /// - InstantaneousSpeed: from pos.speed (0.01 m/s, UInt16 LE)
  /// - Location: lat/lon as SInt32 LE (1e-7 degrees)
  /// - Elevation: from pos.altitude (0.01 m, SInt24 LE)
  /// - Heading: from pos.heading (0.01 degrees, UInt16 LE)
  /// - UTC Time: from pos.timestamp (7-byte DT)
  static Uint8List encodeLocationAndSpeed(GpsPosition pos) {
    int flags = 0;

    final hasSpeed = pos.speed != null;
    final hasLocation = true; // lat/lon are required
    final hasElevation = pos.altitude != null;
    final hasHeading = pos.heading != null;
    final hasUtcTime = true; // timestamp is required

    if (hasSpeed) flags |= _lasFlagInstantaneousSpeed;
    if (hasLocation) flags |= _lasFlagLocation;
    if (hasElevation) flags |= _lasFlagElevation;
    if (hasHeading) flags |= _lasFlagHeading;
    if (hasUtcTime) flags |= _lasFlagUtcTime;

    // Calculate total byte length
    int len = 2; // flags UInt16
    if (hasSpeed) len += 2;
    if (hasLocation) len += 8; // SInt32 lat + SInt32 lon
    if (hasElevation) len += 3; // SInt24
    if (hasHeading) len += 2;
    if (hasUtcTime) len += 7;

    final bytes = ByteData(len);
    int offset = 0;

    // Flags
    bytes.setUint16(offset, flags, Endian.little);
    offset += 2;

    // Instantaneous Speed (0.01 m/s)
    if (hasSpeed) {
      bytes.setUint16(offset, (pos.speed! * 100).round().clamp(0, 0xFFFF),
          Endian.little);
      offset += 2;
    }

    // Latitude (1e-7 degrees, SInt32)
    if (hasLocation) {
      bytes.setInt32(offset, (pos.latitude * 1e7).round(), Endian.little);
      offset += 4;

      // Longitude (1e-7 degrees, SInt32)
      bytes.setInt32(offset, (pos.longitude * 1e7).round(), Endian.little);
      offset += 4;
    }

    // Elevation (0.01 m, SInt24)
    if (hasElevation) {
      final elevCm = (pos.altitude! * 100).round();
      _writeSInt24(bytes, offset, elevCm);
      offset += 3;
    }

    // Heading (0.01 degrees, UInt16)
    if (hasHeading) {
      bytes.setUint16(
          offset, (pos.heading! * 100).round().clamp(0, 36000) % 36000,
          Endian.little);
      offset += 2;
    }

    // UTC Time (7 bytes: year UInt16 LE, month, day, hour, min, sec)
    if (hasUtcTime) {
      final dt = pos.timestamp.toUtc();
      bytes.setUint16(offset, dt.year, Endian.little);
      offset += 2;
      bytes.setUint8(offset, dt.month);
      offset += 1;
      bytes.setUint8(offset, dt.day);
      offset += 1;
      bytes.setUint8(offset, dt.hour);
      offset += 1;
      bytes.setUint8(offset, dt.minute);
      offset += 1;
      bytes.setUint8(offset, dt.second);
      offset += 1;
    }

    return bytes.buffer.asUint8List(0, offset);
  }

  /// Encodes [pos] into Navigation characteristic value.
  ///
  /// Fields:
  /// - Bearing: from pos.heading as bearing (0.01 deg, UInt16 LE)
  /// - Heading: from pos.heading (0.01 deg, UInt16 LE)
  /// - Remaining distance: omitted (0, UInt24)
  /// - Remaining vertical distance: omitted (0, SInt24)
  /// - ETA: from pos.timestamp (7-byte DT)
  static Uint8List encodeNavigation(GpsPosition pos) {
    int flags = 0;

    final hasBearing = pos.heading != null;
    final hasHeading = pos.heading != null;
    final hasEta = true;

    if (hasBearing) flags |= _navFlagBearing;
    if (hasHeading) flags |= _navFlagHeading;
    if (hasEta) flags |= _navFlagEta;

    int len = 2; // flags
    if (hasBearing) len += 2;
    if (hasHeading) len += 2;
    if (hasEta) len += 7;

    final bytes = ByteData(len);
    int offset = 0;

    // Flags
    bytes.setUint16(offset, flags, Endian.little);
    offset += 2;

    // Bearing (0.01 degrees, UInt16)
    if (hasBearing) {
      bytes.setUint16(
          offset, (pos.heading! * 100).round().clamp(0, 36000) % 36000,
          Endian.little);
      offset += 2;
    }

    // Heading (0.01 degrees, UInt16)
    if (hasHeading) {
      bytes.setUint16(
          offset, (pos.heading! * 100).round().clamp(0, 36000) % 36000,
          Endian.little);
      offset += 2;
    }

    // ETA (7-byte DateTime)
    if (hasEta) {
      final dt = pos.timestamp.toUtc();
      bytes.setUint16(offset, dt.year, Endian.little);
      offset += 2;
      bytes.setUint8(offset, dt.month);
      offset += 1;
      bytes.setUint8(offset, dt.day);
      offset += 1;
      bytes.setUint8(offset, dt.hour);
      offset += 1;
      bytes.setUint8(offset, dt.minute);
      offset += 1;
      bytes.setUint8(offset, dt.second);
      offset += 1;
    }

    return bytes.buffer.asUint8List(0, offset);
  }

  /// Writes a 24-bit signed integer at [offset] in little-endian.
  static void _writeSInt24(ByteData bytes, int offset, int value) {
    // Two's complement for 24-bit
    if (value < 0) {
      value = (1 << 24) + value;
    }
    bytes.setUint8(offset, value & 0xFF);
    bytes.setUint8(offset + 1, (value >> 8) & 0xFF);
    bytes.setUint8(offset + 2, (value >> 16) & 0xFF);
  }
}
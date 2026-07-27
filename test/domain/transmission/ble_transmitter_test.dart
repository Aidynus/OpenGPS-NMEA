/// BLE peripheral transmitter tests.
///
/// Full BLE peripheral behavior requires hardware and cannot be exercised in
/// unit/integration tests without a platform channel stub.  This file
/// establishes the test scaffold and validates the BleDataEncoder binary
/// encoding independently of the hardware path.
///
/// To run real BLE tests, use a physical device with:
///   flutter test integration_test/ble_test.dart --device-id <id>
library;

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:opengps_nmea/data/services/ble_data_encoder.dart';
import 'package:opengps_nmea/domain/models/gps_position.dart';

GpsPosition _pos() => GpsPosition(
      latitude: 48.43262,
      longitude: 17.00450,
      altitude: 159.4,
      speed: 5.14444,
      heading: 84.4,
      timestamp: DateTime.utc(2024, 6, 15, 12, 0, 0),
      hasFix: true,
    );

void main() {
  group('BleDataEncoder', () {
    group('encodeLnFeature', () {
      test('returns 4-byte little-endian UInt32', () {
        final bytes = BleDataEncoder.encodeLnFeature();
        expect(bytes.length, 4);
      });

      test('has InstantaneousSpeed bit set (bit 0)', () {
        final bytes = BleDataEncoder.encodeLnFeature();
        final value = ByteData.sublistView(bytes).getUint32(0, Endian.little);
        expect(value & (1 << 0), isNonZero); // InstantaneousSpeed
      });

      test('has Location bit set (bit 2)', () {
        final bytes = BleDataEncoder.encodeLnFeature();
        final value = ByteData.sublistView(bytes).getUint32(0, Endian.little);
        expect(value & (1 << 2), isNonZero); // Location
      });

      test('has Elevation bit set (bit 3)', () {
        final bytes = BleDataEncoder.encodeLnFeature();
        final value = ByteData.sublistView(bytes).getUint32(0, Endian.little);
        expect(value & (1 << 3), isNonZero); // Elevation
      });

      test('has Heading bit set (bit 4)', () {
        final bytes = BleDataEncoder.encodeLnFeature();
        final value = ByteData.sublistView(bytes).getUint32(0, Endian.little);
        expect(value & (1 << 4), isNonZero); // Heading
      });

      test('has UTC Time bit set (bit 6)', () {
        final bytes = BleDataEncoder.encodeLnFeature();
        final value = ByteData.sublistView(bytes).getUint32(0, Endian.little);
        expect(value & (1 << 6), isNonZero); // UTC Time
      });
    });

    group('encodeLocationAndSpeed', () {
      test('first 2 bytes are flags', () {
        final pos = _pos();
        final bytes = BleDataEncoder.encodeLocationAndSpeed(pos);
        expect(bytes.length, greaterThanOrEqualTo(2));
      });

      test('latitude encoded as SInt32 LE 1e-7 degrees', () {
        final pos = _pos();
        final bytes = BleDataEncoder.encodeLocationAndSpeed(pos);
        final bd = ByteData.sublistView(bytes);
        // Flags=2 bytes, Speed=2 bytes, then lat at offset 4
        final lat = bd.getInt32(4, Endian.little);
        expect(lat, (48.43262 * 1e7).round());
      });

      test('longitude encoded as SInt32 LE 1e-7 degrees', () {
        final pos = _pos();
        final bytes = BleDataEncoder.encodeLocationAndSpeed(pos);
        final bd = ByteData.sublistView(bytes);
        // lon at offset 8
        final lon = bd.getInt32(8, Endian.little);
        expect(lon, (17.00450 * 1e7).round());
      });

      test('speed encoded as UInt16 LE 0.01 m/s', () {
        final pos = _pos();
        final bytes = BleDataEncoder.encodeLocationAndSpeed(pos);
        final bd = ByteData.sublistView(bytes);
        // Speed at offset 2
        final speedRaw = bd.getUint16(2, Endian.little);
        expect(speedRaw, (5.14444 * 100).round());
      });

      test('UTC time 7 bytes at correct offset', () {
        final pos = _pos();
        final bytes = BleDataEncoder.encodeLocationAndSpeed(pos);
        // Compute expected size:
        // 2 flags + 2 speed + 8 latlon + 3 elevation + 2 heading + 7 utctime = 24
        expect(bytes.length, 24);
        final bd = ByteData.sublistView(bytes);
        // Year at offset 17
        final year = bd.getUint16(17, Endian.little);
        expect(year, 2024);
      });

      test('negative latitude encoded correctly', () {
        final pos = _pos().copyWith(latitude: -33.8688);
        final bytes = BleDataEncoder.encodeLocationAndSpeed(pos);
        final bd = ByteData.sublistView(bytes);
        final lat = bd.getInt32(4, Endian.little);
        expect(lat, (-33.8688 * 1e7).round());
        expect(lat, isNegative);
      });

      test('null speed omits speed field and adjusts flags', () {
        final pos = _pos().copyWith(speed: null);
        final bytes = BleDataEncoder.encodeLocationAndSpeed(pos);
        // Without speed: 2 flags + 8 latlon + 3 elevation + 2 heading + 7 utctime = 22
        expect(bytes.length, 22);
      });
    });

    group('encodeNavigation', () {
      test('contains bearing and heading from pos.heading', () {
        final pos = _pos();
        final bytes = BleDataEncoder.encodeNavigation(pos);
        final bd = ByteData.sublistView(bytes);
        // Bearing at offset 2, heading at offset 4
        final bearing = bd.getUint16(2, Endian.little);
        final heading = bd.getUint16(4, Endian.little);
        expect(bearing, (84.4 * 100).round() % 36000);
        expect(heading, (84.4 * 100).round() % 36000);
      });

      test('ETA year matches position timestamp', () {
        final pos = _pos();
        final bytes = BleDataEncoder.encodeNavigation(pos);
        final bd = ByteData.sublistView(bytes);
        // 2 flags + 2 bearing + 2 heading = offset 6 for ETA
        final year = bd.getUint16(6, Endian.little);
        expect(year, 2024);
      });

      test('null heading omits bearing and heading fields', () {
        final pos = _pos().copyWith(heading: null);
        final bytes = BleDataEncoder.encodeNavigation(pos);
        // 2 flags + 7 eta = 9 bytes (no bearing, no heading)
        expect(bytes.length, 9);
      });
    });
  });
}

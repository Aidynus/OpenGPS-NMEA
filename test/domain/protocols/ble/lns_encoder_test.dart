import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:opengps_nmea/domain/models/gps_position.dart';
import 'package:opengps_nmea/domain/protocols/ble/lns_encoder.dart';

GpsPosition _pos({
  bool hasFix = true,
  double? speed,
  double? heading,
}) {
  return GpsPosition(
    latitude: 51.1,
    longitude: 71.4,
    speed: speed,
    heading: heading,
    timestamp: DateTime.utc(2026, 11, 20),
    hasFix: hasFix,
  );
}

void main() {
  group('LnsEncoder.encodeLocationAndSpeed', () {
    test('returns null without a fix', () {
      expect(LnsEncoder.encodeLocationAndSpeed(_pos(hasFix: false)), isNull);
    });

    test('encodes speed, location and heading (little-endian)', () {
      final bytes =
          LnsEncoder.encodeLocationAndSpeed(_pos(speed: 10.0, heading: 90.0))!;
      expect(bytes.length, 14);

      final data = ByteData.sublistView(bytes);
      expect(data.getUint16(0, Endian.little), 0x0015);
      expect(data.getUint16(2, Endian.little), 1000); // 10 m/s in 0.01 m/s
      expect(data.getInt32(4, Endian.little), 511000000);
      expect(data.getInt32(8, Endian.little), 714000000);
      expect(data.getUint16(12, Endian.little), 9000); // 90 degrees in 0.01
    });

    test('omits speed and heading when unknown', () {
      final bytes = LnsEncoder.encodeLocationAndSpeed(_pos())!;
      expect(bytes.length, 10);

      final data = ByteData.sublistView(bytes);
      expect(data.getUint16(0, Endian.little), 0x0004);
      expect(data.getInt32(2, Endian.little), 511000000);
      expect(data.getInt32(6, Endian.little), 714000000);
    });

    test('treats a negative (invalid) speed as unknown', () {
      final bytes = LnsEncoder.encodeLocationAndSpeed(_pos(speed: -1.0))!;
      final data = ByteData.sublistView(bytes);
      expect(data.getUint16(0, Endian.little) & LnsEncoder.flagSpeed, 0);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:opengps_nmea/core/utils/nmea_utils.dart';
import 'package:opengps_nmea/domain/models/gps_position.dart';
import 'package:opengps_nmea/domain/protocols/nmea/jetour_nmea_builder.dart';

void main() {
  const builder = JetourNmeaBuilder();
  final reference = GpsPosition(
    latitude: 48.43262,
    longitude: 17.00450,
    altitude: 159.4,
    speed: 5.14444,
    heading: 84.4,
    timestamp: DateTime.utc(2024, 6, 15, 11, 59, 22),
    hasFix: true,
  );

  test('builds RMC and GGA with real position fields only', () {
    final sentences = builder.build(reference);
    expect(sentences, hasLength(2));
    expect(
      sentences[0],
      startsWith(
        r'$GPRMC,115922.000,A,4825.95720,N,01700.27000,E,10.00,84.4,150624,,,A*',
      ),
    );
    expect(
      sentences[1],
      startsWith(
        r'$GPGGA,115922.000,4825.95720,N,01700.27000,E,1,,,159.4,M,,M,,*',
      ),
    );
    for (final sentence in sentences) {
      expect(sentence, endsWith('\r\n'));
      final star = sentence.indexOf('*');
      final body = sentence.substring(1, star);
      final checksum = int.parse(sentence.substring(star + 1, star + 3), radix: 16);
      expect(checksum, nmeaChecksum(body));
    }
  });

  test('leaves unavailable altitude, speed and course empty', () {
    final sentences = builder.build(
      reference.copyWith(altitude: null, speed: null, heading: null),
    );
    expect(sentences[0], contains(',E,,,150624,,,A*'));
    expect(sentences[1], contains(',1,,,,M,,M,,*'));
  });

  test('does not emit data without a location fix', () {
    expect(builder.build(reference.copyWith(hasFix: false)), isEmpty);
  });
}
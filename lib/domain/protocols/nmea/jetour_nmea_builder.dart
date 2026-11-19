import 'package:opengps_nmea/core/utils/nmea_formatter.dart';
import 'package:opengps_nmea/core/utils/nmea_utils.dart';
import 'package:opengps_nmea/domain/models/gps_position.dart';

/// Conservative NMEA output for the JetourGPS BLE link.
/// Only fields backed by iOS Core Location are populated.
class JetourNmeaBuilder {
  const JetourNmeaBuilder();

  List<String> build(GpsPosition position) {
    if (!position.hasFix) return const [];

    final utc = position.timestamp.toUtc();
    final time = nmeaTimeField(utc, withMilliseconds: true);
    final latitude = nmeaLatToField(position.latitude);
    final longitude = nmeaLonToField(position.longitude);
    final altitude = position.altitude?.toStringAsFixed(1) ?? '';
    final speed = position.speed == null
        ? ''
        : knotsToNmeaSpeed(position.speed!.clamp(0.0, 1000.0).toDouble());
    final course = position.heading == null
        ? ''
        : position.heading!.clamp(0, 359.999).toStringAsFixed(1);
    final date = nmeaDateField(utc);

    final rmc = buildNmeaSentence(
      'GP',
      'RMC',
      '$time,A,$latitude,$longitude,$speed,$course,$date,,,A',
    );
    final gga = buildNmeaSentence(
      'GP',
      'GGA',
      '$time,$latitude,$longitude,1,,,$altitude,M,,M,,',
    );

    return [rmc, gga];
  }
}

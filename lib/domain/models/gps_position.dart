import 'package:freezed_annotation/freezed_annotation.dart';

part 'gps_position.freezed.dart';
part 'gps_position.g.dart';

@freezed
class GpsPosition with _$GpsPosition {
  const factory GpsPosition({
    required double latitude,
    required double longitude,
    double? altitude,
    double? speed,
    double? heading,
    double? accuracy,
    required DateTime timestamp,
    required bool hasFix,
    double? verticalAccuracy,
    double? headingAccuracy,
  }) = _GpsPosition;

  factory GpsPosition.fromJson(Map<String, dynamic> json) =>
      _$GpsPositionFromJson(json);
}
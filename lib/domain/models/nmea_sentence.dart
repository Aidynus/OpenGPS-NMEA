import 'package:freezed_annotation/freezed_annotation.dart';

part 'nmea_sentence.freezed.dart';
part 'nmea_sentence.g.dart';

enum NmeaSentenceType {
  gga,
  gll,
  gsa,
  hdg,
  hdm,
  hdt,
  rmc,
  vtg,
  zda,
  pashr,
  gptxt,
}

@freezed
class NmeaSentence with _$NmeaSentence {
  const factory NmeaSentence({
    required NmeaSentenceType type,
    required String rawSentence,
    required DateTime generatedAt,
  }) = _NmeaSentence;

  factory NmeaSentence.fromJson(Map<String, dynamic> json) =>
      _$NmeaSentenceFromJson(json);
}
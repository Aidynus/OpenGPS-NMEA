import 'package:freezed_annotation/freezed_annotation.dart';

part 'taip_message.freezed.dart';
part 'taip_message.g.dart';

enum TaipMessageType {
  pv,
  al,
}

@freezed
class TaipMessage with _$TaipMessage {
  const factory TaipMessage({
    required TaipMessageType type,
    required String deviceId,
    required String rawMessage,
    required DateTime generatedAt,
  }) = _TaipMessage;

  factory TaipMessage.fromJson(Map<String, dynamic> json) =>
      _$TaipMessageFromJson(json);
}
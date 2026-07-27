import 'package:freezed_annotation/freezed_annotation.dart';

part 'connection_status.freezed.dart';
part 'connection_status.g.dart';

/// Fine-grained transmission lifecycle state — replaces the dual
/// isActive/isConnected boolean pair that could become inconsistent.
enum TransmissionStatus {
  idle,
  connecting,
  connected,
  reconnecting,
  error;

  bool get isActive =>
      this == TransmissionStatus.connecting ||
      this == TransmissionStatus.connected ||
      this == TransmissionStatus.reconnecting;

  bool get isConnected => this == TransmissionStatus.connected;
}

@freezed
class ConnectionStatus with _$ConnectionStatus {
  const factory ConnectionStatus({
    @Default(TransmissionStatus.idle) TransmissionStatus status,
    @Default(false) bool isActive,
    @Default(false) bool isConnected,
    @Default(0) int connectedClientCount,
    @Default(0) int totalTxCount,
    @Default(0) int totalRxCount,
    String? localIpAddress,
    String? bleStatus,
    DateTime? lastTxTime,
    String? activeProtocol,
    String? errorMessage,
  }) = _ConnectionStatus;

  factory ConnectionStatus.fromJson(Map<String, dynamic> json) =>
      _$ConnectionStatusFromJson(json);
}

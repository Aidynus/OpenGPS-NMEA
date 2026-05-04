import 'package:freezed_annotation/freezed_annotation.dart';

part 'connection_status.freezed.dart';
part 'connection_status.g.dart';

@freezed
class ConnectionStatus with _$ConnectionStatus {
  const factory ConnectionStatus({
    required bool isActive,
    required bool isConnected,
    required int connectedClientCount,
    required int totalTxCount,
    required int totalRxCount,
    String? localIpAddress,
    String? bleStatus,
    DateTime? lastTxTime,
    String? activeProtocol,
  }) = _ConnectionStatus;

  factory ConnectionStatus.fromJson(Map<String, dynamic> json) =>
      _$ConnectionStatusFromJson(json);
}
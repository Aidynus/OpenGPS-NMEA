import 'package:opengps_nmea/core/constants/app_constants.dart';
import 'package:opengps_nmea/domain/transmission/abstract_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/socket_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/tcp_client_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/udp_client_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/udp_broadcast_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/udp_multicast_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/taip_udp_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/websocket_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/jetour_ble_transmitter.dart';

/// Factory interface — allows injection of a custom factory in tests.
typedef TransmitterFactory = BaseTransmitter Function(int connectionMethodIndex);

/// Default production factory. Exposed as a named function so it can be
/// passed as a [TransmitterFactory] callback.
BaseTransmitter createTransmitter(int connectionMethodIndex) {
  switch (connectionMethodIndex) {
    case ConnectionMethodPreset.socket:
      return SocketTransmitter();
    case ConnectionMethodPreset.tcpClient:
      return TcpClientTransmitter();
    case ConnectionMethodPreset.udpClient:
      return UdpClientTransmitter();
    case ConnectionMethodPreset.udpMulticast:
      return UdpMulticastTransmitter();
    case ConnectionMethodPreset.udpBroadcast:
      return UdpBroadcastTransmitter();
    case ConnectionMethodPreset.taipUdp:
      return TaipUdpTransmitter();
    case ConnectionMethodPreset.webSocket:
      return WebSocketTransmitter();
    case ConnectionMethodPreset.jetourBle:
      return JetourBleTransmitter();
    default:
      return SocketTransmitter();
  }
}

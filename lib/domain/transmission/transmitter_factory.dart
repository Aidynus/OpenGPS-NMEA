import 'package:opengps_nmea/core/constants/app_constants.dart';
import 'package:opengps_nmea/domain/transmission/abstract_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/socket_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/tcp_client_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/udp_client_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/udp_broadcast_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/udp_multicast_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/taip_udp_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/websocket_transmitter.dart';

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
    default:
      return SocketTransmitter();
  }
}
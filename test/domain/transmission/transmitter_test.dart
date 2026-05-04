import 'package:flutter_test/flutter_test.dart';
import 'package:opengps_nmea/core/constants/app_constants.dart';
import 'package:opengps_nmea/domain/transmission/socket_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/tcp_client_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/udp_client_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/udp_multicast_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/udp_broadcast_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/taip_udp_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/websocket_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/transmitter_factory.dart';

void main() {
  group('SocketTransmitter', () {
    test('instantiates with correct initial state', () {
      final tx = SocketTransmitter();
      expect(tx.isRunning, isFalse);
      expect(tx.connectedClientCount, equals(0));
      tx.dispose();
    });

    test('stop without start is safe', () async {
      final tx = SocketTransmitter();
      await tx.stop();
      expect(tx.isRunning, isFalse);
      tx.dispose();
    });
  });

  group('TcpClientTransmitter', () {
    test('instantiates with correct initial state', () {
      final tx = TcpClientTransmitter();
      expect(tx.isRunning, isFalse);
      expect(tx.connectedClientCount, equals(0));
      tx.dispose();
    });

    test('stop without start is safe', () async {
      final tx = TcpClientTransmitter();
      await tx.stop();
      expect(tx.isRunning, isFalse);
      tx.dispose();
    });
  });

  group('UdpClientTransmitter', () {
    test('instantiates with correct initial state', () {
      final tx = UdpClientTransmitter();
      expect(tx.isRunning, isFalse);
      expect(tx.connectedClientCount, equals(0));
      tx.dispose();
    });

    test('stop without start is safe', () async {
      final tx = UdpClientTransmitter();
      await tx.stop();
      expect(tx.isRunning, isFalse);
      tx.dispose();
    });
  });

  group('UdpMulticastTransmitter', () {
    test('instantiates with correct initial state', () {
      final tx = UdpMulticastTransmitter();
      expect(tx.isRunning, isFalse);
      expect(tx.connectedClientCount, equals(0));
      tx.dispose();
    });

    test('stop without start is safe', () async {
      final tx = UdpMulticastTransmitter();
      await tx.stop();
      expect(tx.isRunning, isFalse);
      tx.dispose();
    });
  });

  group('UdpBroadcastTransmitter', () {
    test('instantiates with correct initial state', () {
      final tx = UdpBroadcastTransmitter();
      expect(tx.isRunning, isFalse);
      expect(tx.connectedClientCount, equals(0));
      tx.dispose();
    });

    test('stop without start is safe', () async {
      final tx = UdpBroadcastTransmitter();
      await tx.stop();
      expect(tx.isRunning, isFalse);
      tx.dispose();
    });
  });

  group('TaipUdpTransmitter', () {
    test('instantiates with correct initial state', () {
      final tx = TaipUdpTransmitter();
      expect(tx.isRunning, isFalse);
      expect(tx.connectedClientCount, equals(0));
      tx.dispose();
    });

    test('stop without start is safe', () async {
      final tx = TaipUdpTransmitter();
      await tx.stop();
      expect(tx.isRunning, isFalse);
      tx.dispose();
    });
  });

  group('WebSocketTransmitter', () {
    test('instantiates with correct initial state', () {
      final tx = WebSocketTransmitter();
      expect(tx.isRunning, isFalse);
      expect(tx.connectedClientCount, equals(0));
      tx.dispose();
    });

    test('stop without start is safe', () async {
      final tx = WebSocketTransmitter();
      await tx.stop();
      expect(tx.isRunning, isFalse);
      tx.dispose();
    });
  });

  group('createTransmitter factory', () {
    test('creates SocketTransmitter for socket preset', () {
      final tx = createTransmitter(ConnectionMethodPreset.socket);
      expect(tx, isA<SocketTransmitter>());
      tx.dispose();
    });

    test('creates TcpClientTransmitter for tcpClient preset', () {
      final tx = createTransmitter(ConnectionMethodPreset.tcpClient);
      expect(tx, isA<TcpClientTransmitter>());
      tx.dispose();
    });

    test('creates UdpClientTransmitter for udpClient preset', () {
      final tx = createTransmitter(ConnectionMethodPreset.udpClient);
      expect(tx, isA<UdpClientTransmitter>());
      tx.dispose();
    });

    test('creates UdpMulticastTransmitter for udpMulticast preset', () {
      final tx = createTransmitter(ConnectionMethodPreset.udpMulticast);
      expect(tx, isA<UdpMulticastTransmitter>());
      tx.dispose();
    });

    test('creates UdpBroadcastTransmitter for udpBroadcast preset', () {
      final tx = createTransmitter(ConnectionMethodPreset.udpBroadcast);
      expect(tx, isA<UdpBroadcastTransmitter>());
      tx.dispose();
    });

    test('creates TaipUdpTransmitter for taipUdp preset', () {
      final tx = createTransmitter(ConnectionMethodPreset.taipUdp);
      expect(tx, isA<TaipUdpTransmitter>());
      tx.dispose();
    });

    test('creates WebSocketTransmitter for webSocket preset', () {
      final tx = createTransmitter(ConnectionMethodPreset.webSocket);
      expect(tx, isA<WebSocketTransmitter>());
      tx.dispose();
    });

    test('defaults to SocketTransmitter for unknown preset', () {
      final tx = createTransmitter(999);
      expect(tx, isA<SocketTransmitter>());
      tx.dispose();
    });
  });

  group('BaseTransmitter', () {
    test('send without start is a no-op', () async {
      final tx = SocketTransmitter();
      await tx.send('test');
      expect(tx.isRunning, isFalse);
      tx.dispose();
    });

    test('sendMultiple delegates to send', () async {
      final tx = SocketTransmitter();
      await tx.sendMultiple(['a', 'b', 'c']);
      expect(tx.isRunning, isFalse);
      tx.dispose();
    });

    test('clientCountStream emits values', () async {
      final tx = SocketTransmitter();
      final counts = <int>[];
      tx.clientCountStream.listen(counts.add);
      tx.setClientCount(3);
      tx.setClientCount(5);
      await Future.delayed(Duration.zero);
      expect(counts, [3, 5]);
      tx.dispose();
    });

    test('connectionStateStream emits values', () async {
      final tx = SocketTransmitter();
      final states = <bool>[];
      tx.connectionStateStream.listen(states.add);
      tx.setRunning(true);
      tx.setRunning(false);
      await Future.delayed(Duration.zero);
      expect(states, [true, false]);
      tx.dispose();
    });

    test('incrementClientCount works', () {
      final tx = SocketTransmitter();
      tx.setClientCount(0);
      tx.incrementClientCount();
      expect(tx.connectedClientCount, equals(1));
      tx.dispose();
    });

    test('decrementClientCount does not go below zero', () {
      final tx = SocketTransmitter();
      tx.setClientCount(0);
      tx.decrementClientCount();
      expect(tx.connectedClientCount, equals(0));
      tx.dispose();
    });
  });
}
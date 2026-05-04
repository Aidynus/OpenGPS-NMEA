import 'dart:async';
import 'dart:io';

import 'package:opengps_nmea/domain/models/app_settings.dart';
import 'package:opengps_nmea/domain/transmission/abstract_transmitter.dart';

class SocketTransmitter extends BaseTransmitter {
  ServerSocket? _serverSocket;
  final List<Socket> _clients = [];
  StreamSubscription<Socket>? _acceptSubscription;

  @override
  Future<void> start(AppSettings settings) async {
    if (isRunning) return;

    final port = settings.socketPort;

    try {
      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      _acceptSubscription = _serverSocket!.listen(
        _handleClient,
        onError: (error) {
          setRunning(false);
        },
        onDone: () {
          setRunning(false);
        },
      );
      setRunning(true);
    } catch (e) {
      setRunning(false);
      rethrow;
    }
  }

  void _handleClient(Socket client) {
    _clients.add(client);
    incrementClientCount();

    client.listen(
      (_) {},
      onError: (_) => _removeClient(client),
      onDone: () => _removeClient(client),
    );
  }

  void _removeClient(Socket client) {
    _clients.remove(client);
    decrementClientCount();
    try {
      client.destroy();
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    await _acceptSubscription?.cancel();
    _acceptSubscription = null;

    for (final client in _clients) {
      try {
        client.destroy();
      } catch (_) {}
    }
    _clients.clear();
    setClientCount(0);

    await _serverSocket?.close();
    _serverSocket = null;
    setRunning(false);
  }

  @override
  Future<void> send(String data) async {
    if (!isRunning || _clients.isEmpty) return;

    final bytes = data.codeUnits;
    final deadClients = <Socket>[];

    for (final client in _clients) {
      try {
        client.add(bytes);
        await client.flush();
      } catch (_) {
        deadClients.add(client);
      }
    }

    for (final client in deadClients) {
      _removeClient(client);
    }
  }
}
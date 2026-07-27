import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:opengps_nmea/core/constants/app_constants.dart';
import 'package:opengps_nmea/core/errors/app_errors.dart';
import 'package:opengps_nmea/domain/models/app_settings.dart';
import 'package:opengps_nmea/domain/transmission/abstract_transmitter.dart';

class SocketTransmitter extends BaseTransmitter {
  ServerSocket? _serverSocket;
  final List<_ClientHandle> _clients = [];
  StreamSubscription<Socket>? _acceptSubscription;
  Timer? _keepaliveTimer;

  static const Duration _keepaliveInterval =
      Duration(seconds: DefaultSettings.tcpKeepaliveSeconds);
  static const Duration _idleTimeout =
      Duration(seconds: DefaultSettings.tcpIdleTimeoutSeconds);

  @override
  Future<void> start(AppSettings settings) async {
    if (isRunning) return;
    setStatus(TransmitterStatus.connecting);

    final port = settings.socketPort;

    try {
      _serverSocket =
          await ServerSocket.bind(InternetAddress.anyIPv4, port, shared: true);
      _acceptSubscription = _serverSocket!.listen(
        _handleClient,
        onError: (error) {
          debugPrint('[SocketTransmitter] server error: $error');
          setRunning(false);
          setStatus(TransmitterStatus.error);
        },
        onDone: () {
          setRunning(false);
          setStatus(TransmitterStatus.idle);
        },
      );
      _startKeepalive();
      setRunning(true);
      setStatus(TransmitterStatus.connected);
    } on SocketException catch (e) {
      setStatus(TransmitterStatus.error);
      setRunning(false);
      if (e.osError?.errorCode == 48 /* EADDRINUSE macOS */ ||
          e.osError?.errorCode == 98 /* EADDRINUSE Linux */ ||
          e.osError?.errorCode == 10048 /* WSAEADDRINUSE Windows */) {
        throw PortInUseError(port, cause: e);
      }
      rethrow;
    }
  }

  void _handleClient(Socket client) {
    final handle = _ClientHandle(client, DateTime.now());
    _clients.add(handle);
    incrementClientCount();

    client.listen(
      (_) => handle.lastActivity = DateTime.now(),
      onError: (_) => _removeClient(handle),
      onDone: () => _removeClient(handle),
    );
  }

  void _removeClient(_ClientHandle handle) {
    _clients.remove(handle);
    decrementClientCount();
    try {
      handle.socket.destroy();
    } catch (e) {
      debugPrint('[SocketTransmitter] error destroying client: $e');
    }
  }

  void _startKeepalive() {
    _keepaliveTimer?.cancel();
    _keepaliveTimer = Timer.periodic(_keepaliveInterval, (_) {
      _evictIdleClients();
    });
  }

  void _evictIdleClients() {
    final now = DateTime.now();
    final stale = _clients
        .where((h) => now.difference(h.lastActivity) > _idleTimeout)
        .toList();
    for (final h in stale) {
      debugPrint('[SocketTransmitter] evicting idle client after '
          '${now.difference(h.lastActivity).inSeconds}s');
      _removeClient(h);
    }
  }

  @override
  Future<void> stop() async {
    _keepaliveTimer?.cancel();
    _keepaliveTimer = null;

    await _acceptSubscription?.cancel();
    _acceptSubscription = null;

    for (final handle in List.of(_clients)) {
      try {
        handle.socket.destroy();
      } catch (e) {
        debugPrint('[SocketTransmitter] error destroying client on stop: $e');
      }
    }
    _clients.clear();
    setClientCount(0);

    await _serverSocket?.close();
    _serverSocket = null;
    setRunning(false);
    setStatus(TransmitterStatus.idle);
  }

  @override
  Future<void> send(String data) async {
    if (!isRunning || _clients.isEmpty) return;

    final bytes = utf8.encode(data);
    final deadHandles = <_ClientHandle>[];

    for (final handle in _clients) {
      try {
        handle.socket.add(bytes);
        await handle.socket.flush();
        handle.lastActivity = DateTime.now();
      } catch (e) {
        debugPrint('[SocketTransmitter] error sending to client: $e');
        deadHandles.add(handle);
      }
    }

    for (final handle in deadHandles) {
      _removeClient(handle);
    }

    if (deadHandles.length < _clients.length + deadHandles.length) {
      recordSuccessfulSend();
    }
  }

  /// Overridden for efficiency: write all messages before flushing each socket.
  @override
  Future<void> sendMultiple(List<String> dataList) async {
    if (!isRunning || _clients.isEmpty || dataList.isEmpty) return;

    final bytesList = dataList.map(utf8.encode).toList();
    final deadHandles = <_ClientHandle>[];

    for (final handle in _clients) {
      try {
        for (final bytes in bytesList) {
          handle.socket.add(bytes);
        }
        await handle.socket.flush();
        handle.lastActivity = DateTime.now();
      } catch (e) {
        debugPrint('[SocketTransmitter] error in sendMultiple: $e');
        deadHandles.add(handle);
      }
    }

    for (final handle in deadHandles) {
      _removeClient(handle);
    }

    if (deadHandles.length < _clients.length + deadHandles.length) {
      recordSuccessfulSend();
    }
  }
}

class _ClientHandle {
  final Socket socket;
  DateTime lastActivity;

  _ClientHandle(this.socket, this.lastActivity);
}

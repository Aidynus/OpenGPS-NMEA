import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:opengps_nmea/domain/models/app_settings.dart';
import 'package:opengps_nmea/domain/transmission/abstract_transmitter.dart';

class WebSocketTransmitter extends BaseTransmitter {
  WebSocketChannel? _channel;
  AppSettings? _currentSettings;
  bool _intentionalStop = false;
  Timer? _reconnectTimer;
  // Clamp to [0, 5] → max delay = 1s * 2^5 = 32s, comfortably over the 30s cap.
  int _reconnectAttempts = 0;

  static const Duration _initialReconnectDelay = Duration(seconds: 1);
  static const Duration _maxReconnectDelay = Duration(seconds: 30);

  @override
  Future<void> start(AppSettings settings) async {
    if (isRunning) return;

    _currentSettings = settings;
    _intentionalStop = false;
    _reconnectAttempts = 0;
    await _connect(settings);
  }

  Future<void> _connect(AppSettings settings) async {
    if (_intentionalStop) return;
    setStatus(TransmitterStatus.connecting);

    final url = _buildWebSocketUrl(settings);

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      setRunning(true);
      setClientCount(1);
      _reconnectAttempts = 0;
      setStatus(TransmitterStatus.connected);

      _channel!.stream.listen(
        (_) {},
        onError: (_) => _handleDisconnect(),
        onDone: () => _handleDisconnect(),
        cancelOnError: true,
      );
    } catch (_) {
      setRunning(false);
      setClientCount(0);
      setStatus(TransmitterStatus.reconnecting);
      _scheduleReconnect();
    }
  }

  String _buildWebSocketUrl(AppSettings settings) {
    final urlString = settings.websocketUrl;
    if (urlString != null && urlString.isNotEmpty) {
      if (!urlString.startsWith('ws://') && !urlString.startsWith('wss://')) {
        return 'ws://$urlString';
      }
      return urlString;
    }
    return 'ws://${settings.targetIpAddress}:${settings.websocketPort}';
  }

  void _handleDisconnect() {
    if (_intentionalStop) return;

    _channel = null;
    setRunning(false);
    setClientCount(0);
    setStatus(TransmitterStatus.reconnecting);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_intentionalStop || _currentSettings == null) return;

    _reconnectTimer?.cancel();
    final delayMs = _initialReconnectDelay.inMilliseconds *
        (1 << _reconnectAttempts.clamp(0, 5));
    final delay = Duration(milliseconds: delayMs);
    final cappedDelay = delay > _maxReconnectDelay ? _maxReconnectDelay : delay;

    _reconnectTimer = Timer(cappedDelay, () {
      if (!_intentionalStop && _currentSettings != null) {
        _reconnectAttempts++;
        _connect(_currentSettings!);
      }
    });
  }

  @override
  Future<void> stop() async {
    _intentionalStop = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    await _channel?.sink.close();
    _channel = null;

    setClientCount(0);
    setRunning(false);
    setStatus(TransmitterStatus.idle);
  }

  @override
  Future<void> send(String data) async {
    if (!isRunning || _channel == null) return;

    try {
      _channel!.sink.add(data);
      recordSuccessfulSend();
    } catch (_) {
      _handleDisconnect();
    }
  }
}

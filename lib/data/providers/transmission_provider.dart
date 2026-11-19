import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/gps_position.dart';
import '../../domain/transmission/abstract_transmitter.dart';
import '../../domain/transmission/transmitter_factory.dart';
import 'location_provider.dart';

/// Injectable factory provider. Override in tests with a mock factory.
final transmitterFactoryProvider =
    Provider<TransmitterFactory>((ref) => createTransmitter);

// ── Transmission state ────────────────────────────────────────────────────────

class TransmissionState {
  final bool isActive;
  final TransmitterStatus transmitterStatus;

  /// Number of head units/phones currently receiving data (0..2).
  final int clientCount;

  /// Number of position packets delivered to at least one device.
  final int totalTxCount;
  final String? error;
  final DateTime? lastTxTime;

  const TransmissionState({
    this.isActive = false,
    this.transmitterStatus = TransmitterStatus.idle,
    this.clientCount = 0,
    this.totalTxCount = 0,
    this.error,
    this.lastTxTime,
  });

  bool get isConnected => transmitterStatus == TransmitterStatus.connected;

  TransmissionState copyWith({
    bool? isActive,
    TransmitterStatus? transmitterStatus,
    int? clientCount,
    int? totalTxCount,
    String? error,
    bool clearError = false,
    DateTime? lastTxTime,
  }) {
    return TransmissionState(
      isActive: isActive ?? this.isActive,
      transmitterStatus: transmitterStatus ?? this.transmitterStatus,
      clientCount: clientCount ?? this.clientCount,
      totalTxCount: totalTxCount ?? this.totalTxCount,
      error: clearError ? null : (error ?? this.error),
      lastTxTime: lastTxTime ?? this.lastTxTime,
    );
  }
}

// ── Transmission coordinator ──────────────────────────────────────────────────

class TransmissionCoordinator extends Notifier<TransmissionState> {
  BaseTransmitter? _transmitter;
  StreamSubscription<int>? _clientCountSubscription;
  StreamSubscription<TransmitterStatus>? _statusSubscription;

  @override
  TransmissionState build() {
    // Listen to the throttled position stream.
    ref.listen(positionStreamProvider, (previous, next) {
      if (!state.isActive) return;
      next.whenData((pos) {
        _handlePosition(pos);
      });
    });

    ref.onDispose(_cleanup);

    return const TransmissionState();
  }

  Future<void> start() async {
    if (state.isActive) return;

    final settings = ref.read(appSettingsProvider);
    final transmitter = ref.read(transmitterFactoryProvider)();
    _transmitter = transmitter;

    state = state.copyWith(
      isActive: true,
      transmitterStatus: TransmitterStatus.connecting,
      clearError: true,
    );

    // Subscribe before start so early events are not lost.
    _clientCountSubscription = transmitter.clientCountStream.listen((count) {
      state = state.copyWith(clientCount: count);
    });
    _statusSubscription = transmitter.statusStream.listen((s) {
      state = state.copyWith(transmitterStatus: s);
    });

    try {
      await transmitter.start(settings);
    } catch (e) {
      _cleanup();
      state = state.copyWith(
        isActive: false,
        transmitterStatus: TransmitterStatus.error,
        clientCount: 0,
        error: e.toString(),
      );
    }
  }

  Future<void> _handlePosition(GpsPosition pos) async {
    final transmitter = _transmitter;
    if (transmitter == null) return;
    try {
      final delivered = await transmitter.sendPosition(pos);
      if (delivered && state.isActive) {
        state = state.copyWith(
          totalTxCount: state.totalTxCount + 1,
          lastTxTime: DateTime.now(),
          clearError: true,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> stop() async {
    _cleanup();
    state = const TransmissionState();
  }

  void _cleanup() {
    _clientCountSubscription?.cancel();
    _clientCountSubscription = null;
    _statusSubscription?.cancel();
    _statusSubscription = null;
    _transmitter?.stop();
    _transmitter?.dispose();
    _transmitter = null;
  }

  /// Called from [AppLifecycleState.resumed] — verifies the transmitter is
  /// still healthy and restarts it if not.
  Future<void> verifyHealth() async {
    if (!state.isActive) return;
    final tx = _transmitter;
    if (tx == null || !tx.isRunning) {
      await stop();
      await start();
    }
  }
}

final transmissionCoordinatorProvider =
    NotifierProvider<TransmissionCoordinator, TransmissionState>(
  TransmissionCoordinator.new,
);

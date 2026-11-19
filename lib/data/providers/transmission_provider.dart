import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/gps_position.dart';
import '../../domain/models/sentence_log_entry.dart';
import '../../domain/protocols/nmea/nmea_builder.dart';
import '../../domain/protocols/taip/taip_builder.dart';
import '../../domain/transmission/abstract_transmitter.dart';
import '../../domain/transmission/transmitter_factory.dart';
import 'location_provider.dart';
import '../../domain/protocols/nmea/jetour_nmea_builder.dart';

// ── Protocol builders ─────────────────────────────────────────────────────────

final nmeaBuilderProvider = Provider<NmeaBuilder>((ref) => const NmeaBuilder());
final taipBuilderProvider = Provider<TaipBuilder>((ref) => const TaipBuilder());
final jetourNmeaBuilderProvider =
    Provider<JetourNmeaBuilder>((ref) => const JetourNmeaBuilder());

/// Injectable factory provider. Override in tests with a mock factory.
final transmitterFactoryProvider =
    Provider<TransmitterFactory>((ref) => createTransmitter);

// ── Transmission state ────────────────────────────────────────────────────────

class TransmissionState {
  final bool isActive;
  final TransmitterStatus transmitterStatus;
  final int clientCount;
  final int totalTxCount;
  final int totalRxCount;
  final String? error;
  final DateTime? lastTxTime;

  const TransmissionState({
    this.isActive = false,
    this.transmitterStatus = TransmitterStatus.idle,
    this.clientCount = 0,
    this.totalTxCount = 0,
    this.totalRxCount = 0,
    this.error,
    this.lastTxTime,
  });

  bool get isConnected =>
      transmitterStatus == TransmitterStatus.connected;

  bool get isReconnecting =>
      transmitterStatus == TransmitterStatus.reconnecting;

  TransmissionState copyWith({
    bool? isActive,
    TransmitterStatus? transmitterStatus,
    int? clientCount,
    int? totalTxCount,
    int? totalRxCount,
    String? error,
    bool clearError = false,
    DateTime? lastTxTime,
  }) {
    return TransmissionState(
      isActive: isActive ?? this.isActive,
      transmitterStatus: transmitterStatus ?? this.transmitterStatus,
      clientCount: clientCount ?? this.clientCount,
      totalTxCount: totalTxCount ?? this.totalTxCount,
      totalRxCount: totalRxCount ?? this.totalRxCount,
      error: clearError ? null : (error ?? this.error),
      lastTxTime: lastTxTime ?? this.lastTxTime,
    );
  }
}

// ── Sentence log ──────────────────────────────────────────────────────────────

const int _maxLogEntries = 50;

/// Live rolling log of the last [_maxLogEntries] transmitted sentences.
class SentenceLogNotifier extends Notifier<List<SentenceLogEntry>> {
  @override
  List<SentenceLogEntry> build() => [];

  void add(String sentence) {
    final queue = Queue<SentenceLogEntry>.from(state);
    queue.addLast(SentenceLogEntry(
      sentence: sentence.trim(),
      timestamp: DateTime.now(),
    ));
    while (queue.length > _maxLogEntries) {
      queue.removeFirst();
    }
    state = queue.toList();
  }

  void clear() => state = [];
}

final sentenceLogProvider =
    NotifierProvider<SentenceLogNotifier, List<SentenceLogEntry>>(
  SentenceLogNotifier.new,
);

// ── Transmission coordinator ──────────────────────────────────────────────────

class TransmissionCoordinator extends Notifier<TransmissionState> {
  BaseTransmitter? _transmitter;
  StreamSubscription<int>? _clientCountSubscription;
  StreamSubscription<TransmitterStatus>? _statusSubscription;
  Timer? _restartDebounce;

  @override
  TransmissionState build() {
    // Listen to the throttled transmission stream.
    ref.listen(positionStreamProvider, (previous, next) {
      if (!state.isActive) return;
      next.whenData((pos) {
        final settings = ref.read(appSettingsProvider);
        final nmeaBuilder = ref.read(nmeaBuilderProvider);
        final taipBuilder = ref.read(taipBuilderProvider);
        final jetourNmeaBuilder = ref.read(jetourNmeaBuilderProvider);
        _handlePosition(pos, settings, nmeaBuilder, taipBuilder, jetourNmeaBuilder);
      });
    });

    // Restart when settings change, capturing isActive at the moment of
    // the change (not from _wasActive which could race).
    ref.listen(appSettingsProvider, (previous, next) {
      if (previous == null || previous == next) return;
      // Capture active state synchronously before any async gap.
      final wasActive = state.isActive;
      if (wasActive) {
        _scheduleRestart();
      }
    });

    ref.onDispose(() {
      _restartDebounce?.cancel();
      _cleanup();
    });

    return const TransmissionState();
  }

  void _scheduleRestart() {
    _restartDebounce?.cancel();
    _restartDebounce = Timer(const Duration(milliseconds: 300), () async {
      await stop();
      await start();
    });
  }

  Future<void> start() async {
    if (state.isActive) return;

    final settings = ref.read(appSettingsProvider);
    final factory = ref.read(transmitterFactoryProvider);
    _transmitter = factory(settings.connectionMethodIndex);

    state = state.copyWith(
      isActive: true,
      transmitterStatus: TransmitterStatus.connecting,
      clearError: true,
    );

    try {
      await _transmitter!.start(settings);

      _clientCountSubscription =
          _transmitter!.clientCountStream.listen((count) {
        state = state.copyWith(clientCount: count);
      });

      _statusSubscription = _transmitter!.statusStream.listen((s) {
        state = state.copyWith(transmitterStatus: s);
      });

      state = state.copyWith(
        transmitterStatus: TransmitterStatus.connected,
      );
    } catch (e) {
      state = state.copyWith(
        isActive: false,
        transmitterStatus: TransmitterStatus.error,
        error: e.toString(),
      );
      _cleanup();
    }
  }

  void _handlePosition(
    GpsPosition pos,
    AppSettings settings,
    NmeaBuilder nmeaBuilder,
    TaipBuilder taipBuilder,
    JetourNmeaBuilder jetourNmeaBuilder,
  ) {
    try {
      final List<String> messages;

      if (settings.connectionMethodIndex == ConnectionMethodPreset.jetourBle) {
        messages = jetourNmeaBuilder.build(pos);
      } else if (settings.protocol == ProtocolType.taip) {
        messages = taipBuilder.buildAllEnabled(pos, settings);
      } else {
        messages = nmeaBuilder.buildAllEnabled(pos, settings);
      }

      if (messages.isEmpty) return;

      // NmeaBuilder.buildAllEnabled owns the bundling logic — just send as-is.
      _transmitter?.sendMultiple(messages);

      // Log sentences for the live preview.
      final log = ref.read(sentenceLogProvider.notifier);
      for (final m in messages) {
        log.add(m);
      }

      state = state.copyWith(
        totalTxCount: state.totalTxCount + messages.length,
        lastTxTime: DateTime.now(),
        clearError: true, // clear any previous error on success
      );
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

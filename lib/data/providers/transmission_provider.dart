import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/gps_position.dart';
import '../../domain/protocols/nmea/nmea_builder.dart';
import '../../domain/protocols/taip/taip_builder.dart';
import '../../domain/transmission/abstract_transmitter.dart';
import '../../domain/transmission/transmitter_factory.dart';
import 'location_provider.dart';

final nmeaBuilderProvider = Provider<NmeaBuilder>((ref) => NmeaBuilder());

final taipBuilderProvider = Provider<TaipBuilder>((ref) => TaipBuilder());

class TransmissionState {
  final bool isActive;
  final bool isConnected;
  final int clientCount;
  final int totalTxCount;
  final int totalRxCount;
  final String? error;

  const TransmissionState({
    this.isActive = false,
    this.isConnected = false,
    this.clientCount = 0,
    this.totalTxCount = 0,
    this.totalRxCount = 0,
    this.error,
  });

  TransmissionState copyWith({
    bool? isActive,
    bool? isConnected,
    int? clientCount,
    int? totalTxCount,
    int? totalRxCount,
    String? error,
    bool clearError = false,
  }) {
    return TransmissionState(
      isActive: isActive ?? this.isActive,
      isConnected: isConnected ?? this.isConnected,
      clientCount: clientCount ?? this.clientCount,
      totalTxCount: totalTxCount ?? this.totalTxCount,
      totalRxCount: totalRxCount ?? this.totalRxCount,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TransmissionCoordinator extends Notifier<TransmissionState> {
  BaseTransmitter? _transmitter;
  StreamSubscription<int>? _clientCountSubscription;
  Timer? _restartDebounce;
  bool _wasActive = false;

  @override
  TransmissionState build() {
    ref.listen(positionStreamProvider, (previous, next) {
      if (!state.isActive) return;
      next.whenData((pos) {
        final settings = ref.read(appSettingsProvider);
        final nmeaBuilder = ref.read(nmeaBuilderProvider);
        final taipBuilder = ref.read(taipBuilderProvider);
        _handlePosition(pos, settings, nmeaBuilder, taipBuilder);
      });
    });

    ref.listen(appSettingsProvider, (previous, next) {
      if (previous != null && previous != next) {
        _scheduleRestart(next);
      }
    });

    ref.onDispose(() {
      _restartDebounce?.cancel();
      _transmitter?.stop();
      _transmitter?.dispose();
      _transmitter = null;
      _clientCountSubscription?.cancel();
    });

    return const TransmissionState();
  }

  void _scheduleRestart(AppSettings newSettings) {
    _restartDebounce?.cancel();
    _restartDebounce = Timer(const Duration(milliseconds: 300), () {
      if (_wasActive) {
        stop();
        start();
      }
    });
  }

  Future<void> start() async {
    final settings = ref.read(appSettingsProvider);
    _transmitter = createTransmitter(settings.connectionMethodIndex);

    try {
      await _transmitter!.start(settings);

      _clientCountSubscription =
          _transmitter!.clientCountStream.listen((count) {
        state = state.copyWith(clientCount: count);
      });

      state = state.copyWith(isActive: true, isConnected: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void _handlePosition(
    GpsPosition pos,
    AppSettings settings,
    NmeaBuilder nmeaBuilder,
    TaipBuilder taipBuilder,
  ) {
    try {
      final List<String> messages;

      if (settings.protocolIndex == ProtocolPreset.taip) {
        messages = taipBuilder.buildAllEnabled(pos, settings);
      } else {
        messages = nmeaBuilder.buildAllEnabled(pos, settings);
      }

      if (messages.isEmpty) return;

      if (settings.sendInOneTransmission) {
        _transmitter?.send(messages.join(''));
        state = state.copyWith(totalTxCount: state.totalTxCount + 1);
      } else {
        _transmitter?.sendMultiple(messages);
        state = state.copyWith(
          totalTxCount: state.totalTxCount + messages.length,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void stop() {
    _wasActive = state.isActive;
    _clientCountSubscription?.cancel();
    _clientCountSubscription = null;
    _transmitter?.stop();
    _transmitter?.dispose();
    _transmitter = null;
    state = const TransmissionState();
  }

  void updateSettingsAndRestart() {
    if (state.isActive) {
      stop();
      start();
    }
  }
}

final transmissionCoordinatorProvider =
    NotifierProvider<TransmissionCoordinator, TransmissionState>(
  TransmissionCoordinator.new,
);

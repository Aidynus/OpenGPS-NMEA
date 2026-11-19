import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/tr.dart';
import '../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/coordinate_formatter.dart';
import '../../../data/providers/location_provider.dart';
import '../../../data/providers/transmission_provider.dart';
import '../../../domain/models/gps_position.dart';
import '../../../domain/models/network_info.dart';
import '../../../domain/transmission/abstract_transmitter.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Verify transmitter is still healthy after returning from background.
      ref.read(transmissionCoordinatorProvider.notifier).verifyHealth();
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionMethodIndex =
        ref.watch(appSettingsProvider.select((s) => s.connectionMethodIndex));
    final socketPort =
        ref.watch(appSettingsProvider.select((s) => s.socketPort));
    final bleEnabled =
        ref.watch(appSettingsProvider.select((s) => s.bleEnabled));
    final networkInfo = ref.watch(networkInfoProvider);
    ref.watch(languageProvider); // rebuild tooltips on language change
    final txState = ref.watch(transmissionCoordinatorProvider);
    final settingsReady = ref.watch(settingsReadyProvider);
    final passwordHash =
        ref.watch(appSettingsProvider.select((s) => s.passwordHash));

    // Show transmission errors as a snackbar.
    ref.listen(transmissionCoordinatorProvider.select((s) => s.error),
        (_, error) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: Tr.s('Dismiss'),
              textColor: Colors.white,
              onPressed: () =>
                  ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: const DecoratedBox(decoration: AppGradients.appBar),
        title: const Text('JetourGPS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.terminal_outlined),
            tooltip: Tr.s('Sentence log'),
            onPressed: () => context.push('/log'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: Tr.s('Settings'),
            onPressed: () {
              if (passwordHash != null && passwordHash.isNotEmpty) {
                context.push('/lock');
              } else {
                context.push('/settings');
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!settingsReady)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            _buildToggleCard(txState.isActive, txState),
            const SizedBox(height: 16),
            const _PositionCardWidget(),
            const SizedBox(height: 16),
            _buildStatusCard(
              txState,
              networkInfo,
              connectionMethodIndex,
              socketPort,
              bleEnabled,
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Разработчик: Маратов Айдын',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildToggleCard(bool isActive, TransmissionState txState) {
    final transmitterStatus = txState.transmitterStatus;
    final statusLabel = switch (transmitterStatus) {
      TransmitterStatus.idle => 'Off',
      TransmitterStatus.connecting => 'Connecting…',
      TransmitterStatus.connected => 'Active',
      TransmitterStatus.reconnecting => 'Reconnecting…',
      TransmitterStatus.error => 'Error',
    };
    final statusColor = switch (transmitterStatus) {
      TransmitterStatus.connected => Colors.green,
      TransmitterStatus.connecting ||
      TransmitterStatus.reconnecting =>
        Colors.orange,
      TransmitterStatus.error => Colors.red,
      TransmitterStatus.idle => Colors.grey,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: AnimatedContainer(
        duration: Durations.medium2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              statusColor.withAlpha(isActive ? 90 : 30),
              statusColor.withAlpha(8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: Durations.short4,
              child: Icon(
                key: ValueKey(transmitterStatus),
                isActive ? Icons.power_settings_new : Icons.power_off,
                color: statusColor,
                size: 40,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: Durations.short4,
                child: Text(
                  key: ValueKey(transmitterStatus),
                  statusLabel,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ),
            Switch(
              value: isActive,
              onChanged: (value) {
                HapticFeedback.mediumImpact();
                if (value) {
                  ref
                      .read(transmissionCoordinatorProvider.notifier)
                      .start();
                } else {
                  ref
                      .read(transmissionCoordinatorProvider.notifier)
                      .stop();
                }
              },
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildStatusCard(
    TransmissionState txState,
    AsyncValue<NetworkInfo> networkInfo,
    int connectionMethodIndex,
    int socketPort,
    bool bleEnabled,
  ) {
    final lastTx = txState.lastTxTime;
    final lastTxStr = lastTx == null
        ? '—'
        : '${lastTx.hour.toString().padLeft(2, '0')}:'
            '${lastTx.minute.toString().padLeft(2, '0')}:'
            '${lastTx.second.toString().padLeft(2, '0')}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const Divider(),
            _StatusRowWidget(
                label: 'Tx', value: txState.totalTxCount.toString()),
            _StatusRowWidget(
                label: 'Rx', value: txState.totalRxCount.toString()),
            _StatusRowWidget(
                label: 'Clients', value: txState.clientCount.toString()),
            _StatusRowWidget(label: 'Last Tx', value: lastTxStr),
            const Divider(),
            networkInfo.when(
              data: (info) {
                if (info == null) return const SizedBox.shrink();
                return Column(
                  children: [
                    if (info.wifiIp != null)
                      _StatusRowWidget(
                          label: 'WiFi IP', value: info.wifiIp!),
                    if (info.cellularIp != null)
                      _StatusRowWidget(
                          label: 'Cellular IP', value: info.cellularIp!),
                    if (info.hotspotIp != null)
                      _StatusRowWidget(
                          label: 'Hotspot IP', value: info.hotspotIp!),
                  ],
                );
              },
              loading: () => const _LoadingRow(),
              error: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber,
                        size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Network info unavailable',
                        style: TextStyle(
                            color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ),
            if (connectionMethodIndex == ConnectionMethodPreset.socket)
              _StatusRowWidget(
                  label: 'Port', value: socketPort.toString()),
            _buildBleStatus(
              bleEnabled || connectionMethodIndex == ConnectionMethodPreset.jetourBle,
              connectionMethodIndex == ConnectionMethodPreset.jetourBle,
              txState.clientCount,
              txState.isActive,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBleStatus(
    bool bleEnabled,
    bool jetourBleActive,
    int clientCount,
    bool isActive,
  ) {
    if (!bleEnabled) return const SizedBox.shrink();

    final status = jetourBleActive
        ? (isActive ? 'Advertising · $clientCount connected' : 'Off')
        : 'BLE LNS mode';
    final color = isActive ? Colors.blue : Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('BLE', style: TextStyle(color: Colors.grey)),
          Row(
            children: [
              Icon(
                !isActive
                    ? Icons.bluetooth_disabled
                    : clientCount > 0
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth_searching,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                status,
                style: TextStyle(color: color, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Position card ─────────────────────────────────────────────────────────────

class _PositionCardWidget extends ConsumerWidget {
  const _PositionCardWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pos = ref.watch(lastKnownPositionProvider);
    final displayDecimalMinutes = ref.watch(
        appSettingsProvider.select((s) => s.displayDecimalMinutes));
    final speedUnitIndex =
        ref.watch(appSettingsProvider.select((s) => s.speedUnitIndex));
    final permissionError = ref.watch(locationPermissionErrorProvider);
    final hasPosition = pos != null && pos.hasFix;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Position',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                _AccuracyDotWidget(pos: pos),
              ],
            ),
            const Divider(),
            AnimatedSwitcher(
              duration: Durations.short4,
              child: permissionError != null
                  ? Padding(
                      key: const ValueKey('permission-error'),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              size: 32, color: Colors.orange),
                          const SizedBox(height: 8),
                          Text(
                            permissionError,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.orange),
                          ),
                        ],
                      ),
                    )
                  : !hasPosition
                      ? const Center(
                          key: ValueKey('no-fix'),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text('No Fix',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey)),
                          ),
                        )
                      : _PositionData(
                          key: const ValueKey('position-data'),
                          pos: pos,
                          displayDecimalMinutes: displayDecimalMinutes,
                          speedUnitIndex: speedUnitIndex,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PositionData extends StatelessWidget {
  final GpsPosition pos;
  final bool displayDecimalMinutes;
  final int speedUnitIndex;

  const _PositionData({
    super.key,
    required this.pos,
    required this.displayDecimalMinutes,
    required this.speedUnitIndex,
  });

  @override
  Widget build(BuildContext context) {
    final speedWidgets = _buildSpeedChips();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          displayDecimalMinutes
              ? '${decimalToDecimalMinutesLatitude(pos.latitude, 4)}\n'
                  '${decimalToDecimalMinutesLongitude(pos.longitude, 4)}'
              : '${decimalToDmsLatitude(pos.latitude, 2)}\n'
                  '${decimalToDmsLongitude(pos.longitude, 2)}',
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (pos.altitude != null)
              _ChipWidget(
                  label: 'Alt',
                  value: '${pos.altitude!.toStringAsFixed(1)} ${Tr.s('m')}'),
            ...speedWidgets,
            if (pos.heading != null)
              _ChipWidget(
                label: 'Course',
                value:
                    '${pos.heading!.toStringAsFixed(1)}° ${_headingToCardinal(pos.heading!)}',
              ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildSpeedChips() {
    final speed = pos.speed;
    if (speed == null) return [];

    switch (speedUnitIndex) {
      case SpeedUnitPreset.knots:
        return [
          _ChipWidget(
              label: 'Speed',
              value: '${(speed * 1.94384).toStringAsFixed(1)} ${Tr.s('kn')}')
        ];
      case SpeedUnitPreset.kmh:
        return [
          _ChipWidget(
              label: 'Speed',
              value: '${(speed * 3.6).toStringAsFixed(1)} ${Tr.s('km/h')}')
        ];
      case SpeedUnitPreset.mph:
        return [
          _ChipWidget(
              label: 'Speed',
              value: '${(speed * 2.23694).toStringAsFixed(1)} ${Tr.s('mph')}')
        ];
      case SpeedUnitPreset.ms:
        return [
          _ChipWidget(
              label: 'Speed', value: '${speed.toStringAsFixed(1)} ${Tr.s('m/s')}')
        ];
      default:
        return [
          _ChipWidget(
              label: 'Speed',
              value: '${(speed * 1.94384).toStringAsFixed(1)} ${Tr.s('kn')}')
        ];
    }
  }

  String _headingToCardinal(double heading) {
    const cardinals = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'
    ];
    final index = ((heading + 11.25) / 22.5).floor() % 16;
    return Tr.s(cardinals[index]);
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _LoadingRow extends StatelessWidget {
  const _LoadingRow();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      child: Center(
        child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
}

class _StatusRowWidget extends StatelessWidget {
  final String label;
  final String value;

  const _StatusRowWidget({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _AccuracyDotWidget extends StatelessWidget {
  final GpsPosition? pos;

  const _AccuracyDotWidget({required this.pos});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final p = pos;
    Color color;
    String label;

    if (p == null || !p.hasFix) {
      color = colorScheme.error;
      label = 'No fix';
    } else if (p.accuracy != null && p.accuracy! <= 10) {
      color = colorScheme.primary;
      label = 'Good';
    } else if (p.accuracy != null && p.accuracy! <= 25) {
      color = colorScheme.tertiary;
      label = 'Moderate';
    } else {
      color = colorScheme.secondary;
      label = 'Low';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}

class _ChipWidget extends StatelessWidget {
  final String label;
  final String value;

  const _ChipWidget({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '${Tr.s(label)}  ',
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withAlpha(128)),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

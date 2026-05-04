import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/coordinate_formatter.dart';
import '../../../data/providers/location_provider.dart';
import '../../../data/providers/transmission_provider.dart';
import '../../../domain/models/gps_position.dart';
import '../../../domain/models/network_info.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final connectionMethodIndex = ref.watch(appSettingsProvider.select((s) => s.connectionMethodIndex));
    final socketPort = ref.watch(appSettingsProvider.select((s) => s.socketPort));
    final bleEnabled = ref.watch(appSettingsProvider.select((s) => s.bleEnabled));
    final networkInfo = ref.watch(networkInfoProvider);
    final isActive = ref.watch(transmissionCoordinatorProvider.select((s) => s.isActive));
    final clientCount = ref.watch(transmissionCoordinatorProvider.select((s) => s.clientCount));
    final totalTxCount = ref.watch(transmissionCoordinatorProvider.select((s) => s.totalTxCount));
    final totalRxCount = ref.watch(transmissionCoordinatorProvider.select((s) => s.totalRxCount));

    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenGPS-NMEA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildToggleCard(isActive),
          const SizedBox(height: 16),
          const _PositionCardWidget(),
          const SizedBox(height: 16),
          _buildStatusCard(isActive, totalTxCount, totalRxCount, clientCount, networkInfo, connectionMethodIndex, socketPort, bleEnabled),
        ],
      ),
    );
  }

  Widget _buildToggleCard(bool isActive) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: Durations.short4,
              child: Icon(
                key: ValueKey(isActive),
                isActive ? Icons.power_settings_new : Icons.power_off,
                color: isActive ? Colors.green : Colors.grey,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: Durations.short4,
                child: Text(
                  key: ValueKey(isActive),
                  isActive ? 'Active' : 'Off',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ),
            Switch(
              value: isActive,
              onChanged: (value) {
                HapticFeedback.mediumImpact();
                if (value) {
                  ref.read(transmissionCoordinatorProvider.notifier).start();
                  ref.read(connectionStatusProvider.notifier).setActive(true);
                } else {
                  ref.read(transmissionCoordinatorProvider.notifier).stop();
                  ref.read(connectionStatusProvider.notifier).setActive(false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    bool isActive,
    int totalTxCount,
    int totalRxCount,
    int clientCount,
    AsyncValue<NetworkInfo?> networkInfo,
    int connectionMethodIndex,
    int socketPort,
    bool bleEnabled,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Divider(),
            _StatusRowWidget(label: 'Tx', value: totalTxCount.toString()),
            _StatusRowWidget(label: 'Rx', value: totalRxCount.toString()),
            _StatusRowWidget(label: 'Clients', value: clientCount.toString()),
            const Divider(),
            networkInfo.when(
              data: (info) {
                if (info == null) return const SizedBox.shrink();
                return Column(
                  children: [
                    if (info.wifiIp != null)
                      _StatusRowWidget(label: 'WiFi IP', value: info.wifiIp!),
                    if (info.cellularIp != null)
                      _StatusRowWidget(label: 'Cellular IP', value: info.cellularIp!),
                    if (info.hotspotIp != null)
                      _StatusRowWidget(label: 'Hotspot IP', value: info.hotspotIp!),
                  ],
                );
              },
              loading: () => const _LoadingRow(),
              error: (_, _) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Network info unavailable', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ),
            if (connectionMethodIndex == ConnectionMethodPreset.socket)
              _StatusRowWidget(label: 'Port', value: socketPort.toString()),
            _buildBleStatus(bleEnabled),
          ],
        ),
      ),
    );
  }

  Widget _buildBleStatus(bool bleEnabled) {
    if (!bleEnabled) return const SizedBox.shrink();

    final bleStatus = ref.watch(connectionStatusProvider).bleStatus;
    final icon = switch (bleStatus) {
      'connected' => Icons.bluetooth_connected,
      'advertising' => Icons.bluetooth_searching,
      _ => Icons.bluetooth_disabled,
    };
    final color = switch (bleStatus) {
      'connected' => Colors.blue,
      'advertising' => Colors.blue.shade300,
      _ => Colors.grey,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('BLE', style: TextStyle(color: Colors.grey)),
          AnimatedSwitcher(
            duration: Durations.short4,
            child: Row(
              key: ValueKey(bleStatus ?? 'disabled'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 4),
                Text(
                  bleStatus ?? 'disabled',
                  style: TextStyle(color: color, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PositionCardWidget extends ConsumerWidget {
  const _PositionCardWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pos = ref.watch(lastKnownPositionProvider);
    final displayDecimalMinutes = ref.watch(appSettingsProvider.select((s) => s.displayDecimalMinutes));
    final hasPosition = pos != null && pos.hasFix;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Position',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                _AccuracyDotWidget(pos: pos),
              ],
            ),
            const Divider(),
            AnimatedSwitcher(
              duration: Durations.short4,
              child: !hasPosition
                  ? const Center(
                      key: ValueKey('no-fix'),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No Fix',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
                    )
                  : Column(
                      key: ValueKey('position-data'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          displayDecimalMinutes
                              ? '${decimalToDecimalMinutesLatitude(pos.latitude, 4)}\n${decimalToDecimalMinutesLongitude(pos.longitude, 4)}'
                              : '${decimalToDmsLatitude(pos.latitude, 2)}\n${decimalToDmsLongitude(pos.longitude, 2)}',
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
                              _ChipWidget(label: 'Alt', value: '${pos.altitude!.toStringAsFixed(1)} m'),
                            if (pos.speed != null) ...[
                              _ChipWidget(label: 'Speed', value: '${(pos.speed! * 1.94384).toStringAsFixed(1)} kn'),
                              _ChipWidget(label: 'Speed', value: '${(pos.speed! * 3.6).toStringAsFixed(1)} km/h'),
                            ],
                            if (pos.heading != null)
                              _ChipWidget(label: 'Course', value: '${pos.heading!.toStringAsFixed(1)}° ${_headingToCardinal(pos.heading!)}'),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _headingToCardinal(double heading) {
    const cardinals = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
        'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
    final index = ((heading + 11.25) / 22.5).floor() % 16;
    return cardinals[index];
  }
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
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
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
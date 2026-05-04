import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/coordinate_formatter.dart';
import '../../../data/providers/location_provider.dart';
import '../../../data/providers/transmission_provider.dart';
import '../../../domain/models/app_settings.dart';
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
    final settings = ref.watch(appSettingsProvider);
    final position = ref.watch(lastKnownPositionProvider);
    final networkInfo = ref.watch(networkInfoProvider);
    final txState = ref.watch(transmissionCoordinatorProvider);

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
          _buildToggleCard(txState.isActive, settings),
          const SizedBox(height: 12),
          _buildPositionCard(position, settings),
          const SizedBox(height: 12),
          _buildStatusCard(txState, networkInfo, settings),
        ],
      ),
    );
  }

  Widget _buildToggleCard(bool isActive, AppSettings settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              isActive ? Icons.power_settings_new : Icons.power_off,
              color: isActive ? Colors.green : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                isActive ? 'Active' : 'Off',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.green : Colors.grey,
                ),
              ),
            ),
            Switch(
              value: isActive,
              onChanged: (value) {
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

  Widget _buildPositionCard(GpsPosition? pos, AppSettings settings) {
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
                _buildAccuracyDot(pos),
              ],
            ),
            const Divider(),
            if (!hasPosition)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No Fix',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              )
            else ...[
              SelectableText(
                settings.displayDecimalMinutes
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
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (pos.altitude != null)
                    _buildChip('Alt', '${pos.altitude!.toStringAsFixed(1)} m'),
                  if (pos.speed != null) ...[
                    _buildChip('Speed', '${(pos.speed! * 1.94384).toStringAsFixed(1)} kn'),
                    _buildChip('Speed', '${(pos.speed! * 3.6).toStringAsFixed(1)} km/h'),
                  ],
                  if (pos.heading != null)
                    _buildChip('Course', '${pos.heading!.toStringAsFixed(1)}° ${_headingToCardinal(pos.heading!)}'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccuracyDot(GpsPosition? pos) {
    Color color;
    String label;

    if (pos == null || !pos.hasFix) {
      color = Colors.red;
      label = 'No fix';
    } else if (pos.accuracy != null && pos.accuracy! <= 10) {
      color = Colors.green;
      label = 'Good';
    } else if (pos.accuracy != null && pos.accuracy! <= 25) {
      color = Colors.orange;
      label = 'Moderate';
    } else {
      color = Colors.amber;
      label = 'Low';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  Widget _buildChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _buildStatusCard(
    TransmissionState txState,
    AsyncValue<NetworkInfo?> networkInfo,
    AppSettings settings,
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
            _buildStatusRow('Tx', txState.totalTxCount.toString()),
            _buildStatusRow('Rx', txState.totalRxCount.toString()),
            _buildStatusRow('Clients', txState.clientCount.toString()),
            const Divider(),
            networkInfo.when(
              data: (info) {
                if (info == null) return const SizedBox.shrink();
                return Column(
                  children: [
                    if (info.wifiIp != null)
                      _buildStatusRow('WiFi IP', info.wifiIp!),
                    if (info.cellularIp != null)
                      _buildStatusRow('Cellular IP', info.cellularIp!),
                    if (info.hotspotIp != null)
                      _buildStatusRow('Hotspot IP', info.hotspotIp!),
                  ],
                );
              },
              loading: () => const _LoadingRow(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            if (settings.connectionMethodIndex == ConnectionMethodPreset.socket)
              _buildStatusRow('Port', settings.socketPort.toString()),
            _buildBleStatus(settings),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildBleStatus(AppSettings settings) {
    if (!settings.bleEnabled) return const SizedBox.shrink();

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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('BLE', style: TextStyle(color: Colors.grey)),
          Row(
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
        ],
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
      child: Center(child: SizedBox.shrink()),
    );
  }
}

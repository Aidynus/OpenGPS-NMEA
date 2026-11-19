import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/coordinate_formatter.dart';
import '../../../data/providers/location_provider.dart';
import '../../../data/providers/transmission_provider.dart';
import '../../../domain/models/gps_position.dart';
import '../../../domain/transmission/abstract_transmitter.dart';
import '../../../domain/transmission/ble_transmitter.dart';
import '../../../l10n/tr.dart';
import '../../core/theme/app_theme.dart';

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
      // Verify the Bluetooth transmitter is still healthy after returning
      // from the background.
      ref.read(transmissionCoordinatorProvider.notifier).verifyHealth();
    }
  }

  void _toggle(bool value) {
    HapticFeedback.mediumImpact();
    final notifier = ref.read(transmissionCoordinatorProvider.notifier);
    if (value) {
      notifier.start();
    } else {
      notifier.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            backgroundColor: AppColors.danger,
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!settingsReady)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  _BluetoothCard(state: txState, onToggle: _toggle),
                  const SizedBox(height: 16),
                  const _PositionCard(),
                ],
              ],
            ),
          ),
          const _AuthorFooter(),
        ],
      ),
    );
  }
}

// ── Author footer ─────────────────────────────────────────────────────────────

class _AuthorFooter extends StatelessWidget {
  const _AuthorFooter();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Center(
          child: Text(
            'Author: Маратов Айдын',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

// ── Bluetooth card ────────────────────────────────────────────────────────────

class _BluetoothCard extends StatelessWidget {
  final TransmissionState state;
  final ValueChanged<bool> onToggle;

  const _BluetoothCard({required this.state, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final String title;
    final Color color;
    final IconData icon;

    if (state.transmitterStatus == TransmitterStatus.error) {
      title = 'Error';
      color = AppColors.danger;
      icon = Icons.bluetooth_disabled;
    } else if (!state.isActive) {
      title = 'Off';
      color = AppColors.textMuted;
      icon = Icons.bluetooth_disabled;
    } else if (state.clientCount > 0) {
      title = 'Connected';
      color = AppColors.success;
      icon = Icons.bluetooth_connected;
    } else {
      title = 'Waiting for connection…';
      color = AppColors.glow;
      icon = Icons.bluetooth_searching;
    }

    final lastTx = state.lastTxTime;
    final lastTxStr = lastTx == null
        ? '—'
        : '${lastTx.hour.toString().padLeft(2, '0')}:'
            '${lastTx.minute.toString().padLeft(2, '0')}:'
            '${lastTx.second.toString().padLeft(2, '0')}';

    return AppPanel(
      accent: state.isActive ? color : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withAlpha(36),
                  border: Border.all(color: color.withAlpha(150)),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'GPS to the car via Bluetooth LE',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Switch(value: state.isActive, onChanged: onToggle),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          _InfoRow(
            label: 'Connected devices',
            value: '${state.clientCount} / ${BleTransmitter.maxClients}',
            leading: _DeviceDots(connected: state.clientCount),
          ),
          _InfoRow(label: 'Tx', value: state.totalTxCount.toString()),
          _InfoRow(label: 'Last Tx', value: lastTxStr),
        ],
      ),
    );
  }
}

/// One dot per allowed device slot (filled = connected).
class _DeviceDots extends StatelessWidget {
  final int connected;

  const _DeviceDots({required this.connected});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < BleTransmitter.maxClients; i++)
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < connected ? AppColors.success : Colors.transparent,
              border: Border.all(
                color: i < connected ? AppColors.success : AppColors.stroke,
                width: 1.5,
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? leading;

  const _InfoRow({required this.label, required this.value, this.leading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) leading!,
              Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Position card ─────────────────────────────────────────────────────────────

class _PositionCard extends ConsumerWidget {
  const _PositionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pos = ref.watch(lastKnownPositionProvider);
    final displayDecimalMinutes = ref.watch(
        appSettingsProvider.select((s) => s.displayDecimalMinutes));
    final speedUnitIndex =
        ref.watch(appSettingsProvider.select((s) => s.speedUnitIndex));
    final permissionError = ref.watch(locationPermissionErrorProvider);
    final hasPosition = pos != null && pos.hasFix;

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.my_location, size: 18, color: AppColors.glow),
              const SizedBox(width: 8),
              const Text('Position',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              _AccuracyDot(pos: pos),
            ],
          ),
          const Divider(height: 24),
          AnimatedSwitcher(
            duration: Durations.short4,
            child: permissionError != null
                ? Padding(
                    key: const ValueKey('permission-error'),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            size: 32, color: AppColors.warning),
                        const SizedBox(height: 8),
                        Text(
                          permissionError,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.warning),
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
                                  fontSize: 18, color: AppColors.textMuted)),
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
            color: AppColors.textPrimary,
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
                  value:
                      '${pos.altitude!.toStringAsFixed(1)} ${Tr.s('m')}'),
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
    if (speed == null || speed < 0) return [];

    final String value;
    switch (speedUnitIndex) {
      case SpeedUnitPreset.kmh:
        value = '${(speed * 3.6).toStringAsFixed(1)} ${Tr.s('km/h')}';
      case SpeedUnitPreset.mph:
        value = '${(speed * 2.23694).toStringAsFixed(1)} ${Tr.s('mph')}';
      case SpeedUnitPreset.ms:
        value = '${speed.toStringAsFixed(1)} ${Tr.s('m/s')}';
      default:
        value = '${(speed * 1.94384).toStringAsFixed(1)} ${Tr.s('kn')}';
    }
    return [_ChipWidget(label: 'Speed', value: value)];
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

class _AccuracyDot extends StatelessWidget {
  final GpsPosition? pos;

  const _AccuracyDot({required this.pos});

  @override
  Widget build(BuildContext context) {
    final p = pos;
    final Color color;
    final String label;

    if (p == null || !p.hasFix) {
      color = AppColors.danger;
      label = 'No fix';
    } else if (p.accuracy != null && p.accuracy! <= 10) {
      color = AppColors.success;
      label = 'Good';
    } else if (p.accuracy != null && p.accuracy! <= 25) {
      color = AppColors.warning;
      label = 'Moderate';
    } else {
      color = AppColors.glow;
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
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
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
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.stroke),
      ),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '${Tr.s(label)}  ',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textMuted),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

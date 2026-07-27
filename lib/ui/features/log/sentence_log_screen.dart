import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/providers/transmission_provider.dart';
import '../../../domain/models/sentence_log_entry.dart';

class SentenceLogScreen extends ConsumerWidget {
  const SentenceLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(sentenceLogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentence Log'),
        actions: [
          if (log.isNotEmpty) ...[
            IconButton(
              tooltip: 'Copy all',
              icon: const Icon(Icons.copy),
              onPressed: () => _copyAll(context, log),
            ),
            IconButton(
              tooltip: 'Share',
              icon: const Icon(Icons.share),
              onPressed: () => _share(log),
            ),
            IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.delete_outline),
              onPressed: () =>
                  ref.read(sentenceLogProvider.notifier).clear(),
            ),
          ],
        ],
      ),
      body: log.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.signal_wifi_off, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No sentences yet.\nStart transmission to see output here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: log.length,
              reverse: true,
              itemBuilder: (context, index) {
                final entry = log[log.length - 1 - index];
                return _SentenceRow(entry: entry);
              },
            ),
    );
  }

  void _copyAll(BuildContext context, List<SentenceLogEntry> log) {
    final text = log.map((e) => e.sentence).join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _share(List<SentenceLogEntry> log) {
    final text = log.map((e) => e.sentence).join('\n');
    Share.share(text, subject: 'NMEA Sentence Log');
  }
}

class _SentenceRow extends StatelessWidget {
  final SentenceLogEntry entry;

  const _SentenceRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr =
        '${entry.timestamp.hour.toString().padLeft(2, '0')}:'
        '${entry.timestamp.minute.toString().padLeft(2, '0')}:'
        '${entry.timestamp.second.toString().padLeft(2, '0')}';

    final isNmea = entry.sentence.startsWith(r'$');
    final isTaip = entry.sentence.startsWith('>');

    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: entry.sentence));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sentence copied'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              timeStr,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withAlpha(128),
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                entry.sentence,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: isNmea
                      ? theme.colorScheme.primary
                      : isTaip
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

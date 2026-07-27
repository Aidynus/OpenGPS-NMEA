/// A single entry in the live NMEA/TAIP sentence log.
class SentenceLogEntry {
  final String sentence;
  final DateTime timestamp;

  const SentenceLogEntry({
    required this.sentence,
    required this.timestamp,
  });
}

int nmeaChecksum(String sentenceWithoutDollar) {
  var checksum = 0;
  for (var i = 0; i < sentenceWithoutDollar.length; i++) {
    checksum ^= sentenceWithoutDollar.codeUnitAt(i);
  }
  return checksum;
}

String formatNmeaChecksum(int checksum) {
  return checksum.toRadixString(16).toUpperCase().padLeft(2, '0');
}

String buildNmeaSentence(String talker, String sentenceType, String fields) {
  final body = '$talker$sentenceType,$fields';
  final checksum = formatNmeaChecksum(nmeaChecksum(body));
  return '\$$body*$checksum\r\n';
}

String decimalToDmsLatitude(double lat, int decimalPlaces) {
  final abs = lat.abs();
  final deg = abs.floor();
  final min = (abs - deg) * 60;
  final sec = (min - min.floor()) * 60;
  final dir = lat >= 0 ? 'N' : 'S';
  final minStr = min.floor().toString().padLeft(2, '0');
  final secStr = sec.toStringAsFixed(decimalPlaces).padLeft(2 + decimalPlaces + 1, '0');
  return '$deg° $minStr\' $secStr" $dir';
}

String decimalToDmsLongitude(double lon, int decimalPlaces) {
  final abs = lon.abs();
  final deg = abs.floor();
  final min = (abs - deg) * 60;
  final sec = (min - min.floor()) * 60;
  final dir = lon >= 0 ? 'E' : 'W';
  final minStr = min.floor().toString().padLeft(2, '0');
  final secStr = sec.toStringAsFixed(decimalPlaces).padLeft(2 + decimalPlaces + 1, '0');
  return '$deg° $minStr\' $secStr" $dir';
}

String decimalToDecimalMinutesLatitude(double lat, int decimalPlaces) {
  final abs = lat.abs();
  final deg = abs.floor();
  final min = (abs - deg) * 60;
  final dir = lat >= 0 ? 'N' : 'S';
  return '$deg° ${min.toStringAsFixed(decimalPlaces)}\' $dir';
}

String decimalToDecimalMinutesLongitude(double lon, int decimalPlaces) {
  final abs = lon.abs();
  final deg = abs.floor();
  final min = (abs - deg) * 60;
  final dir = lon >= 0 ? 'E' : 'W';
  return '$deg° ${min.toStringAsFixed(decimalPlaces)}\' $dir';
}

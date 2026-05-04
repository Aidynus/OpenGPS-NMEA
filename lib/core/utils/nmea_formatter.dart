String nmeaLatToField(double lat) {
  final abs = lat.abs();
  final deg = abs.floor();
  final min = (abs - deg) * 60;
  final dir = lat >= 0 ? 'N' : 'S';
  final degStr = deg.toString().padLeft(2, '0');
  final minStr = min.toStringAsFixed(5).padLeft(8, '0');
  return '$degStr$minStr,$dir';
}

String nmeaLonToField(double lon) {
  final abs = lon.abs();
  final deg = abs.floor();
  final min = (abs - deg) * 60;
  final dir = lon >= 0 ? 'E' : 'W';
  final degStr = deg.toString().padLeft(3, '0');
  final minStr = min.toStringAsFixed(5).padLeft(8, '0');
  return '$degStr$minStr,$dir';
}

String nmeaTimeField(DateTime dt, {bool withMilliseconds = false}) {
  final base = '${dt.hour.toString().padLeft(2, '0')}'
      '${dt.minute.toString().padLeft(2, '0')}'
      '${dt.second.toString().padLeft(2, '0')}';
  if (withMilliseconds) {
    return '$base.${dt.millisecond.toString().padLeft(3, '0')}';
  }
  return base;
}

String nmeaDateField(DateTime dt) {
  return '${dt.day.toString().padLeft(2, '0')}'
      '${dt.month.toString().padLeft(2, '0')}'
      '${(dt.year % 100).toString().padLeft(2, '0')}';
}

String knotsToNmeaSpeed(double mps) {
  return (mps * 1.94384).toStringAsFixed(2);
}

String kmPerHourToNmeaSpeed(double mps) {
  return (mps * 3.6).toStringAsFixed(2);
}

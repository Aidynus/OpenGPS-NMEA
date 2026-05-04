extension DoubleExtensions on double {
  double get knotsToMps => this * 0.514444;
  double get mpsToKnots => this * 1.94384;
  double get metersToFeet => this * 3.28084;
  double get feetToMeters => this * 0.3048;
  double get degreesToRadians => this * 0.0174533;
  double get radiansToDegrees => this * 57.2958;
}

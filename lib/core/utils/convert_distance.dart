double convertDistance(double distanceMeters, String toUnit) {
  switch (toUnit) {
    case 'km':
      return distanceMeters / 1000.0;
    case 'mi':
      return distanceMeters / 1609.34;
    case 'ft':
      return distanceMeters * 3.28084;
    case 'm':
      return distanceMeters;
    default:
      throw ArgumentError('Invalid target unit. Use "km", "mi", or "ft".');
  }
}

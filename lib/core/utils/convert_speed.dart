double convertSpeed(double speedMetersPerSecond, String toUnit) {
  const double metersToFeet = 3.28084;
  const double metersToKilometers = 3.6;
  const double metersToMiles = 2.23694;

  switch (toUnit) {
    case 'ft/s':
      return speedMetersPerSecond * metersToFeet;
    case 'km/h':
      return speedMetersPerSecond * metersToKilometers;
    case 'mph':
      return speedMetersPerSecond * metersToMiles;
    default:
      throw ArgumentError('Invalid target unit. Use "ft/s", "km/h", or "mph".');
  }
}

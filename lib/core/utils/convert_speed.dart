double convertSpeed(double speedMetersPerSecond, String toUnit) {
  const double metersToFeet = 3.28084;
  const double metersToKilometers = 3.6;
  const double metersToMiles = 2.23694;

  switch (toUnit) {
    case 'ftps':
      return speedMetersPerSecond * metersToFeet;
    case 'kmph':
      return speedMetersPerSecond * metersToKilometers;
    case 'mph':
      return speedMetersPerSecond * metersToMiles;
    case 'mps':
      return speedMetersPerSecond;
    default:
      throw ArgumentError('Invalid target unit. Use "ftps", "kmph", or "mph".');
  }
}

class WeatherEntity {
  WeatherEntity({
    this.city,
    this.todayTemperature,
    this.tomorrowTemperature,
    this.dayAfterTomorrowTemperature,
  });
  final String city;
  final double todayTemperature;
  final double tomorrowTemperature;
  final double dayAfterTomorrowTemperature;
}
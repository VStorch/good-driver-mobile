class Place {
  final String displayName;
  final String shortName;
  final double latitude;
  final double longitude;
  final String? city;
  final String? state;
  final String? country;

  const Place({
    required this.displayName,
    required this.shortName,
    required this.latitude,
    required this.longitude,
    this.city,
    this.state,
    this.country,
  });
}
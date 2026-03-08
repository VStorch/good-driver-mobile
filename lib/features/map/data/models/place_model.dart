import '../../domain/entities/place.dart';

/// Parses a single GeoJSON feature returned by the Photon API.
class PlaceModel extends Place {
  const PlaceModel({
    required super.displayName,
    required super.shortName,
    required super.latitude,
    required super.longitude,
    super.city,
    super.state,
    super.country,
  });

  factory PlaceModel.fromPhotonFeature(Map<String, dynamic> feature) {
    final props = feature['properties'] as Map<String, dynamic>? ?? {};
    final geometry = feature['geometry'] as Map<String, dynamic>? ?? {};
    final coords = geometry['coordinates'] as List<dynamic>? ?? [];

    final double lon = (coords.isNotEmpty ? coords[0] : 0).toDouble();
    final double lat = (coords.length > 1 ? coords[1] : 0).toDouble();

    final name = props['name'] as String? ?? '';
    final street = props['street'] as String? ?? '';
    final housenumber = props['housenumber'] as String? ?? '';
    final city = props['city'] as String?;
    final state = props['state'] as String?;
    final country = props['country'] as String?;

    // Build a human-readable short name
    final shortName = name.isNotEmpty
        ? name
        : [street, housenumber].where((s) => s.isNotEmpty).join(' ');

    // Build a full display name
    final parts = [
      if (shortName.isNotEmpty) shortName,
      if (city != null && city.isNotEmpty) city,
      if (state != null && state.isNotEmpty) state,
      if (country != null && country.isNotEmpty) country,
    ];
    final displayName = parts.isNotEmpty ? parts.join(', ') : 'Local desconhecido';

    return PlaceModel(
      displayName: displayName,
      shortName: shortName.isNotEmpty ? shortName : displayName,
      latitude: lat,
      longitude: lon,
      city: city,
      state: state,
      country: country,
    );
  }

  /// Parses a Nominatim reverse-geocode response (used as fallback).
  factory PlaceModel.fromNominatimReverse(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>? ?? {};
    final displayName = json['display_name'] as String? ?? 'Local desconhecido';

    final name = (address['amenity'] ??
        address['building'] ??
        address['road'] ??
        '') as String;

    return PlaceModel(
      displayName: displayName,
      shortName: name.isNotEmpty ? name : displayName,
      latitude: double.tryParse(json['lat']?.toString() ?? '0') ?? 0,
      longitude: double.tryParse(json['lon']?.toString() ?? '0') ?? 0,
      city: address['city'] as String? ?? address['town'] as String?,
      state: address['state'] as String?,
      country: address['country'] as String?,
    );
  }
}
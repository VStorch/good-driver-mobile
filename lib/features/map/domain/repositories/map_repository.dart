import '../entities/place.dart';

abstract class MapRepository {
  Future<List<Place>> searchPlaces(String query);
  Future<Place?> reverseGeocode(double latitude, double longitude);
}
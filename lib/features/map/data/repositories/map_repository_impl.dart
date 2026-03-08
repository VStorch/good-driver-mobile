import '../../domain/entities/place.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/map_remote_datasource.dart';

class MapRepositoryImpl implements MapRepository {
  final MapRemoteDatasource _datasource;

  const MapRepositoryImpl(this._datasource);

  @override
  Future<List<Place>> searchPlaces(String query) async {
    try {
      return await _datasource.searchPlaces(query);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Place?> reverseGeocode(double latitude, double longitude) async {
    try {
      return await _datasource.reverseGeocode(latitude, longitude);
    } catch (_) {
      return null;
    }
  }
}
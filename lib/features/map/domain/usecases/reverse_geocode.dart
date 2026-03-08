import '../entities/place.dart';
import '../repositories/map_repository.dart';

class ReverseGeocode {
  final MapRepository _repository;

  const ReverseGeocode(this._repository);

  Future<Place?> call(double latitude, double longitude) {
    return _repository.reverseGeocode(latitude, longitude);
  }
}
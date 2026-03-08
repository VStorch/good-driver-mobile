import '../entities/place.dart';
import '../repositories/map_repository.dart';

class SearchPlaces {
  final MapRepository _repository;

  const SearchPlaces(this._repository);

  Future<List<Place>> call(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];
    return _repository.searchPlaces(trimmed);
  }
}
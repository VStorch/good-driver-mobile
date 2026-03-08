import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/place.dart';
import '../../domain/usecases/search_places.dart';
import '../../domain/usecases/reverse_geocode.dart';

enum MapState { idle, searching, located, error }

class MapViewModel extends ChangeNotifier {
  final SearchPlaces _searchPlaces;
  final ReverseGeocode _reverseGeocode;

  MapViewModel({
    required SearchPlaces searchPlaces,
    required ReverseGeocode reverseGeocode,
  })  : _searchPlaces = searchPlaces,
        _reverseGeocode = reverseGeocode;

  // State
  MapState _state = MapState.idle;
  MapState get state => _state;

  List<Place> _searchResults = [];
  List<Place> get searchResults => _searchResults;

  Place? _selectedPlace;
  Place? get selectedPlace => _selectedPlace;

  LatLng _mapCenter = const LatLng(-15.7801, -47.9292); // Brasília as default
  LatLng get mapCenter => _mapCenter;

  double _zoom = 13.0;
  double get zoom => _zoom;

  bool _isSearchActive = false;
  bool get isSearchActive => _isSearchActive;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Debounce
  Timer? _debounce;

  // Actions

  void onSearchChanged(String query) {
    _debounce?.cancel();

    if (query.trim().length < 2) {
      _searchResults = [];
      _isSearchActive = false;
      notifyListeners();
      return;
    }

    _isSearchActive = true;
    _state = MapState.searching;
    notifyListeners();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final results = await _searchPlaces(query);
      _searchResults = results;
      _state = MapState.idle;
      _errorMessage = null;
    } catch (e) {
      _state = MapState.error;
      _errorMessage = 'Não foi possível buscar locais.';
      _searchResults = [];
    }
    notifyListeners();
  }

  void selectPlace(Place place) {
    _selectedPlace = place;
    _mapCenter = LatLng(place.latitude, place.longitude);
    _zoom = 16.0;
    _searchResults = [];
    _isSearchActive = false;
    _state = MapState.located;
    notifyListeners();
  }

  void clearSearch() {
    _debounce?.cancel();
    _searchResults = [];
    _isSearchActive = false;
    _selectedPlace = null;
    _state = MapState.idle;
    notifyListeners();
  }

  Future<void> reverseGeocodeAt(LatLng position) async {
    final place = await _reverseGeocode(position.latitude, position.longitude);
    if (place != null) {
      _selectedPlace = place;
      _mapCenter = position;
      _state = MapState.located;
      notifyListeners();
    }
  }

  void updateCenter(LatLng center) {
    _mapCenter = center;
    // No notifyListeners here — called very frequently during map drag
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
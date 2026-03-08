import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place_model.dart';

class MapRemoteDatasource {
  final http.Client _client;

  static const _photonBase = 'https://photon.komoot.io';

  static const _nominatimBase = 'https://nominatim.openstreetmap.org';

  MapRemoteDatasource({http.Client? client}) : _client = client ?? http.Client();

  Future<List<PlaceModel>> searchPlaces(String query) async {
    final uri = Uri.parse('$_photonBase/api').replace(queryParameters: {
      'q': query,
      'limit': '8',
      'lang': 'pt',
    });

    final response = await _client.get(uri, headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode != 200) {
      throw Exception('Photon API error: ${response.statusCode}');
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    final features = body['features'] as List<dynamic>? ?? [];

    return features
        .cast<Map<String, dynamic>>()
        .map(PlaceModel.fromPhotonFeature)
        .toList();
  }

  Future<PlaceModel?> reverseGeocode(double latitude, double longitude) async {
    final uri = Uri.parse('$_nominatimBase/reverse').replace(queryParameters: {
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'format': 'jsonv2',
      'accept-language': 'pt',
    });

    final response = await _client.get(uri, headers: {
      'Accept': 'application/json',
      'User-Agent': 'GoodDriverApp/1.0',
    });

    if (response.statusCode != 200) return null;

    final body = json.decode(response.body) as Map<String, dynamic>;
    if (body.containsKey('error')) return null;

    return PlaceModel.fromNominatimReverse(body);
  }
}
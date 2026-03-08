import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'data/datasources/map_remote_datasource.dart';
import 'data/repositories/map_repository_impl.dart';
import 'domain/usecases/search_places.dart';
import 'domain/usecases/reverse_geocode.dart';
import 'presentation/viewmodels/map_viewmodel.dart';
import 'presentation/pages/map_page.dart';

/// Wraps [MapPage] with all required providers so it can be pushed
/// independently or embedded inside a MultiProvider tree.
///
/// Usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(builder: (_) => const MapFeature()));
/// ```
class MapFeature extends StatelessWidget {
  const MapFeature({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final datasource = MapRemoteDatasource(client: http.Client());
        final repository = MapRepositoryImpl(datasource);
        return MapViewModel(
          searchPlaces: SearchPlaces(repository),
          reverseGeocode: ReverseGeocode(repository),
        );
      },
      builder: (_, __) => const MapPage(),
    );
  }
}
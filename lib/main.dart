import 'package:flutter/material.dart';
import 'package:good_driver/features/map/map_feature.dart';
import 'package:provider/provider.dart';
import 'features/driving/data/datasources/sensor_datasource.dart';
import 'features/driving/domain/services/driving_analyzer.dart';
import 'features/driving/presentation/viewmodels/driving_viewmodel.dart';
import 'features/driving/presentation/pages/driving_debug_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DrivingViewModel(
            SensorDatasource(),
            DrivingAnalyzer(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Good Driver',
      home: MapFeature(), //DrivingDebugPage(),
    );
  }
}
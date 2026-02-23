import 'package:flutter/material.dart';
import '../../data/datasources/sensor_datasource.dart';
import '../../domain/entities/driving_metrics.dart';
import '../../domain/services/driving_analyzer.dart';

class DrivingViewModel extends ChangeNotifier {
  final SensorDatasource datasource;
  final DrivingAnalyzer analyzer;

  DrivingMetrics? metrics;

  DrivingViewModel(this.datasource, this.analyzer) {
    datasource.getSensorStream().listen((raw) {
      metrics = analyzer.analyze(raw);
      notifyListeners();
    });
  }
}
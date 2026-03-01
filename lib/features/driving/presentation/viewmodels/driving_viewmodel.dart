import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/datasources/sensor_datasource.dart';
import '../../domain/entities/driving_metrics.dart';
import '../../domain/services/driving_analyzer.dart';

class DrivingViewModel extends ChangeNotifier {
  final SensorDatasource datasource;
  final DrivingAnalyzer analyzer;

  DrivingMetrics? metrics;
  StreamSubscription? _subscription;

  DrivingViewModel(this.datasource, this.analyzer) {
    _start();
  }

  void _start() {
    _subscription = datasource.getSensorStream().listen((raw) {
      metrics = analyzer.analyze(raw);
      notifyListeners();
    });
  }

  void stop() => _subscription?.cancel();
  void resume() => _start();

  @override
  void dispose() {
    _subscription?.cancel();
    // datasource.dispose();
    super.dispose();
  }
}
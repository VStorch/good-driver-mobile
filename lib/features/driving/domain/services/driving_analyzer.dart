import 'dart:math';

import '../entities/driving_metrics.dart';
import '../../data/models/sensor_raw_model.dart';

class DrivingAnalyzer {
  static const brakeThreshold = 3.0;
  static const accelThreshold = 3.0;

  final List<double> _buffer = [];
  static const int bufferSize = 10;

  DrivingMetrics analyze(SensorRawModel raw) {
    final acceleration = _resultantAcceleration(raw);

    // removes gravity
    final motion = (acceleration - 9.8).abs();

    _addToBuffer(motion);
    final smoothedMotion = _average();

    return DrivingMetrics(
      acceleration: smoothedMotion,
      harshBrake: smoothedMotion > brakeThreshold,
      aggressiveAcceleration: smoothedMotion > accelThreshold,
    );
  }

  void _addToBuffer(double value) {
    _buffer.add(value);
    if (_buffer.length > bufferSize) {
      _buffer.removeAt(0);
    }
  }

  double _average() {
    if (_buffer.isEmpty) return 0;
    return _buffer.reduce((a, b) => a + b) / _buffer.length;
  }

  double _resultantAcceleration(SensorRawModel raw) {
    return sqrt(
      raw.ax * raw.ax +
          raw.ay * raw.ay +
          raw.az * raw.az,
    );
  }
}
import 'dart:math';
import '../entities/driving_metrics.dart';
import '../../data/models/sensor_raw_model.dart';

class DrivingAnalyzer {
  // Thresholds in m/s²
  static const double brakeThreshold = -2.5;
  static const double accelerationThreshold = 2.5;
  static const double corneringThreshold = 2.8;

  // Signal Processing Constants
  static const double noiseFloor = 0.25;
  static const double maxPhysicalAccel = 8.0;
  static const int movingAverageWindow = 10;
  static const double gravityFilterAlpha = 0.05;

  // Estimated gravity vector
  double _gx = 0, _gy = 0, _gz = 9.8;

  // State for software-based yaw estimation (gyroscope fallback)
  double _lastLateralAccel = 0;
  DateTime? _lastTimestamp;

  final List<double> _longitudinalBuffer = [];
  final List<double> _lateralBuffer = [];

  DrivingMetrics analyze(SensorRawModel raw) {
    _updateGravityEstimate(raw);

    // Isolate linear acceleration by removing gravity component
    final linearX = raw.ax - _gx;
    final linearY = raw.ay - _gy;
    final linearZ = raw.az - _gz;

    final (longitudinal, lateral) = _projectToVehicleAxes(linearX, linearY, linearZ);

    _updateBuffers(longitudinal, lateral);

    double smoothLong = _getAverage(_longitudinalBuffer);
    double smoothLat = _getAverage(_lateralBuffer);

    // Signal conditioning: noise removal and physical limits clamping
    smoothLong = _applyThresholds(smoothLong);
    smoothLat = _applyThresholds(smoothLat);

    final hasGyroscope = raw.gx != 0.0 || raw.gy != 0.0 || raw.gz != 0.0;
    final yawRate = hasGyroscope
        ? _getDominantYaw(raw.gx, raw.gy, raw.gz)
        : _calculateYawRateFallback(smoothLat, raw.timestamp);

    return DrivingMetrics(
      longitudinalAccel: smoothLong,
      lateralAccel: smoothLat,
      yawRate: yawRate,
      harshBrake: smoothLong < brakeThreshold,
      aggressiveAcceleration: smoothLong > accelerationThreshold,
      harshCornering: _isHarshCornering(smoothLat, yawRate, hasGyroscope),
    );
  }

  /// Estimates yaw rate using the derivative of lateral acceleration.
  /// Used primarily for devices lacking a physical gyroscope.
  double _calculateYawRateFallback(double currentLateral, DateTime timestamp) {
    double yawRate = 0;

    if (_lastTimestamp != null) {
      final deltaTime = timestamp.difference(_lastTimestamp!).inMilliseconds / 1000.0;

      // Ignore large time gaps to prevent erratic spikes
      if (deltaTime > 0 && deltaTime < 0.5) {
        yawRate = (currentLateral - _lastLateralAccel) / deltaTime;
      }
    }

    _lastLateralAccel = currentLateral;
    _lastTimestamp = timestamp;

    return yawRate;
  }

  void _updateGravityEstimate(SensorRawModel raw) {
    _gx = gravityFilterAlpha * raw.ax + (1 - gravityFilterAlpha) * _gx;
    _gy = gravityFilterAlpha * raw.ay + (1 - gravityFilterAlpha) * _gy;
    _gz = gravityFilterAlpha * raw.az + (1 - gravityFilterAlpha) * _gz;
  }

  (double, double) _projectToVehicleAxes(double lx, double ly, double lz) {
    final gravityMagXY = sqrt(_gx * _gx + _gy * _gy);

    // Device is likely flat or vertical; use simplified projection
    if (gravityMagXY < 2.0) {
      return ly.abs() > lx.abs() ? (lz, lx) : (lz, ly);
    }

    final tiltAngle = atan2(_gy, _gx);
    final cosA = cos(tiltAngle);
    final sinA = sin(tiltAngle);

    return (
    lx * cosA + ly * sinA,
    -lx * sinA + ly * cosA,
    );
  }

  bool _isHarshCornering(double lateral, double yaw, bool highPrecision) {
    if (highPrecision) {
      return lateral.abs() > corneringThreshold && yaw.abs() > 0.2;
    }
    // Without gyro, increase threshold to reduce false positives from vibration
    return lateral.abs() > (corneringThreshold + 0.4);
  }

  double _getDominantYaw(double gx, double gy, double gz) {
    final axes = [_gx.abs(), _gy.abs(), _gz.abs()];
    final primaryAxisIndex = axes.indexOf(axes.reduce(max));
    return switch (primaryAxisIndex) {
      0 => gx,
      1 => gy,
      _ => gz,
    };
  }

  void _updateBuffers(double long, double lat) {
    _addToBuffer(_longitudinalBuffer, long);
    _addToBuffer(_lateralBuffer, lat);
  }

  void _addToBuffer(List<double> buffer, double value) {
    buffer.add(value);
    if (buffer.length > movingAverageWindow) buffer.removeAt(0);
  }

  double _getAverage(List<double> buffer) {
    if (buffer.isEmpty) return 0;
    return buffer.reduce((a, b) => a + b) / buffer.length;
  }

  double _applyThresholds(double value) {
    if (value.abs() < noiseFloor) return 0;
    return value.clamp(-maxPhysicalAccel, maxPhysicalAccel);
  }
}
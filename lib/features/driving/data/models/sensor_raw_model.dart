class SensorRawModel {
  // Accelerometer (m/s²) — includes gravity
  final double ax;
  final double ay;
  final double az;

  // Gyroscope (rad/s) — angular rotation
  final double gx;
  final double gy;
  final double gz;

  final DateTime timestamp;

  SensorRawModel({
    required this.ax,
    required this.ay,
    required this.az,
    required this.gx,
    required this.gy,
    required this.gz,
    required this.timestamp,
  });
}
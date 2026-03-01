class DrivingMetrics {
  final double longitudinalAccel;

  final double lateralAccel;

  final double yawRate;

  final bool harshBrake;
  final bool aggressiveAcceleration;
  final bool harshCornering;

  const DrivingMetrics({
    required this.longitudinalAccel,
    required this.lateralAccel,
    required this.yawRate,
    required this.harshBrake,
    required this.aggressiveAcceleration,
    required this.harshCornering,
  });
}
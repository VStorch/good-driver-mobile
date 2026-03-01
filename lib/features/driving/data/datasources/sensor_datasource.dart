import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/sensor_raw_model.dart';

class SensorDatasource {
  Stream<SensorRawModel> getSensorStream() {
    double gx = 0, gy = 0, gz = 0;

    gyroscopeEventStream(
      samplingPeriod: const Duration(milliseconds: 100),
    ).listen((g) {
      gx = g.x;
      gy = g.y;
      gz = g.z;
    });

    return accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 100),
    ).map((event) {
      return SensorRawModel(
        ax: event.x,
        ay: event.y,
        az: event.z,
        gx: gx,
        gy: gy,
        gz: gz,
        timestamp: DateTime.now(),
      );
    });
  }
}
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

import '../models/sensor_raw_model.dart';

class SensorDatasource {
  Stream<SensorRawModel> getSensorStream() {
    return accelerometerEventStream(samplingPeriod: const Duration(milliseconds: 200))
        .map((event) {
      return SensorRawModel(
        ax: event.x,
        ay: event.y,
        az: event.z,
        timestamp: DateTime.now(),
      );
    });
  }
}
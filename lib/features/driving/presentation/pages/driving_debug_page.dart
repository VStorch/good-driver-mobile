import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/driving_viewmodel.dart';

class DrivingDebugPage extends StatelessWidget {
  const DrivingDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driving Debug')),
      body: Center(
        child: Consumer<DrivingViewModel>(
          builder: (_, vm, __) {
            final m = vm.metrics;

            if (m == null) return const CircularProgressIndicator();

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Aceleração: ${m.acceleration.toStringAsFixed(2)}"),
                Text("Frenagem brusca: ${m.harshBrake}"),
                Text("Aceleração agressiva: ${m.aggressiveAcceleration}"),
              ],
            );
          },
        ),
      ),
    );
  }
}
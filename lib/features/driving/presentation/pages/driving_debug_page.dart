import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/driving_viewmodel.dart';
import '../../domain/entities/driving_metrics.dart';

class DrivingDebugPage extends StatelessWidget {
  const DrivingDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Good Driver — Debug')),
      body: Center(
        child: Consumer<DrivingViewModel>(
          builder: (_, vm, __) {
            final m = vm.metrics;
            if (m == null) return const CircularProgressIndicator();
            return _MetricsPanel(metrics: m);
          },
        ),
      ),
    );
  }
}

class _MetricsPanel extends StatelessWidget {
  final DrivingMetrics metrics;
  const _MetricsPanel({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Section(
            title: 'Longitudinal',
            children: [
              _Tile(
                label: 'Aceleração',
                value: '${metrics.longitudinalAccel.toStringAsFixed(2)} m/s²',
              ),
              _StatusTile(
                label: 'Frenagem brusca',
                active: metrics.harshBrake,
                activeText: '⚠️ FREADA BRUSCA',
                inactiveText: 'Normal',
              ),
              _StatusTile(
                label: 'Aceleração agressiva',
                active: metrics.aggressiveAcceleration,
                activeText: '⚠️ ACELERAÇÃO BRUSCA',
                inactiveText: 'Normal',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Section(
            title: 'Lateral',
            children: [
              _Tile(
                label: 'Força lateral',
                value: '${metrics.lateralAccel.toStringAsFixed(2)} m/s²',
              ),
              _Tile(
                label: 'Yaw rate',
                value: '${metrics.yawRate.toStringAsFixed(3)} rad/s',
              ),
              _StatusTile(
                label: 'Curva brusca',
                active: metrics.harshCornering,
                activeText: '⚠️ CURVA PERIGOSA',
                inactiveText: 'Curva normal',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const Divider(),
        ...children,
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final String value;

  const _Tile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final String label;
  final bool active;
  final String activeText;
  final String inactiveText;

  const _StatusTile({
    required this.label,
    required this.active,
    required this.activeText,
    required this.inactiveText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            active ? activeText : inactiveText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: active ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
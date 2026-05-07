import 'package:flutter/material.dart';

class ProgressChart extends StatelessWidget {
  final double percentage;

  const ProgressChart({
    super.key,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercentage = percentage.clamp(0, 100);

    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: clampedPercentage / 100,
            strokeWidth: 10,
            backgroundColor: Colors.grey.shade200,
            color: Colors.indigo,
          ),
          Text(
            '${clampedPercentage.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class BreakTimerPage extends StatelessWidget {
  final String taskId;
  final int breakMinutes;
  final bool justCompleted;

  const BreakTimerPage({
    super.key,
    required this.taskId,
    required this.breakMinutes,
    required this.justCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Break'));
  }
}

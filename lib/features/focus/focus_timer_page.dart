import 'package:flutter/material.dart';

class FocusTimerPage extends StatelessWidget {
  final String taskId;
  final int preset;

  const FocusTimerPage({
    super.key,
    required this.taskId,
    required this.preset,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Focus'));
  }
}

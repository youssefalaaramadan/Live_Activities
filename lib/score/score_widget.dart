import 'package:flutter/material.dart';

class ScoreWidget extends StatelessWidget {
  final int score;
  final String teamName;
  final ValueChanged<int> onScoreChanged;

  const ScoreWidget({
    super.key,
    required this.score,
    required this.teamName,
    required this.onScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          teamName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          '$score',
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => onScoreChanged(score - 1),
              icon: const Icon(Icons.remove),
            ),
            IconButton(
              onPressed: () => onScoreChanged(score + 1),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}

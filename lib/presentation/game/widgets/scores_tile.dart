import 'package:flutter/material.dart';

class ScoresTile extends StatelessWidget {
  const ScoresTile({
    super.key,
    required this.currentScore,
    required this.bestScore,
  });

  final String currentScore;
  final String bestScore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Text(
              currentScore,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            Text(
              'SCORE',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ],
        ),
        const Spacer(),
        Column(
          children: [
            Text(
              bestScore,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            Text(
              'BEST',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class ScoresTile extends StatelessWidget {
  const ScoresTile({
    super.key,
    required this.currentScore,
    required this.bestScore,
    this.isPortrait = false,
  });

  final String currentScore;
  final String bestScore;
  final bool isPortrait;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: isPortrait ? Axis.horizontal : Axis.vertical,
      mainAxisAlignment:
          isPortrait ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
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
        if (!isPortrait) const SizedBox(height: 16),
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

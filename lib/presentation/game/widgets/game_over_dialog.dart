import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GameOverDialog {
  const GameOverDialog._();

  static Future show(
    BuildContext context, {
    VoidCallback? onCancelPressed,
    VoidCallback? onOkPressed,
  }) {
    return showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Game over?'),
        content: const Text('Start a new game?'),
        actions: [
          _adaptiveAction(
            context: context,
            onPressed: () {
              onCancelPressed?.call();
              Navigator.pop(context, 'Cancel');
            },
            child: const Text('Cancel'),
            isDestructiveAction: true,
          ),
          _adaptiveAction(
            context: context,
            onPressed: () {
              onOkPressed?.call();
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static Widget _adaptiveAction({
    required BuildContext context,
    required VoidCallback onPressed,
    required Widget child,
    bool isDestructiveAction = false,
  }) {
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return TextButton(onPressed: onPressed, child: child);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoDialogAction(
          onPressed: onPressed,
          isDestructiveAction: isDestructiveAction,
          child: child,
        );
    }
  }
}

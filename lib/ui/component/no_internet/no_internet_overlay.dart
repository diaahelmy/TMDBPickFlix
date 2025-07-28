import 'package:flutter/material.dart';
import 'no_internet_widget.dart';

class NoInternetOverlay extends StatelessWidget {
  final VoidCallback? onRetry;
  final bool isVisible;
  final Widget? child;

  const NoInternetOverlay({
    super.key,
    this.onRetry,
    this.isVisible = true,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (child != null) child!,

        if (isVisible)
          Container(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
            child: NoInternetWidget(
              onRetry: onRetry,
            ),
          ),
      ],
    );
  }
}

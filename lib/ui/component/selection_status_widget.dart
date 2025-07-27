import 'package:flutter/material.dart';

class SelectionStatusWidget extends StatelessWidget {
  final int selectedCount;
  final int minimumSelection;

  const SelectionStatusWidget({
    super.key,
    required this.selectedCount,
    required this.minimumSelection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMinimumMet = selectedCount >= minimumSelection;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isMinimumMet
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMinimumMet
              ? theme.colorScheme.primary.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isMinimumMet ? Icons.check_circle : Icons.info_outline,
            color: isMinimumMet
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            selectedCount < minimumSelection
                ? "Pick at least ${minimumSelection - selectedCount} more movies to continue"
                : "Great! You can continue ($selectedCount selected)",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isMinimumMet
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

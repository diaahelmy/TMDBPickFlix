import 'package:flutter/material.dart';

class BottomButtonWidget extends StatelessWidget {
  final bool isEnabled;
  final int selectedCount;
  final int minimumSelection;
  final VoidCallback? onContinue;

  const BottomButtonWidget({
    super.key,
    required this.isEnabled,
    required this.selectedCount,
    required this.minimumSelection,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: isEnabled ? onContinue : null,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: theme.colorScheme.surfaceContainer,
              disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
            ),
            child: Text(
              isEnabled
                  ? 'Continue'
                  : 'Select at least $minimumSelection movies',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

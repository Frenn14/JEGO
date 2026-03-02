import 'package:flutter/material.dart';
import '../theme/color_system.dart';
import '../theme/text_system.dart';
import '../theme/spacing_system.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    final button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
        enabled ? AppColors.primary : Colors.grey.shade400,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: enabled ? 2 : 0,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          color: enabled ? Colors.white : Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
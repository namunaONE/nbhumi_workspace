import 'package:flutter/material.dart';

/// Conversion-focused call-to-action button.
///
/// Wraps [FilledButton] with a guaranteed 48dp minimum touch target and an
/// inline loading spinner. Used for "Post property", "Contact seller",
/// "Apply", and "Submit" — the actions the refresh is measured by.
class PrimaryCTA extends StatelessWidget {
  /// Creates a primary CTA.
  const PrimaryCTA({
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    super.key,
  });

  /// Button label.
  final String label;

  /// Called when tapped. Null disables the button.
  final VoidCallback? onPressed;

  /// Optional leading icon. Replaced by a spinner while [isLoading].
  final IconData? icon;

  /// Whether to show a spinner and ignore taps.
  final bool isLoading;

  /// Whether the button stretches to its parent width.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : (icon != null ? Icon(icon) : const SizedBox.shrink()),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 48),
      ),
    );
    if (!fullWidth) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

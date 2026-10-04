import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared form controls for the wizard steps.
///
/// Every step needs the same handful of inputs with the same validation
/// behaviour, so they live here rather than being re-declared five times. In
/// particular the error-text handling is identical everywhere: an inline
/// message that appears on the field, not a toast the seller can miss.

/// A labelled text field with inline error text.
class WizardField extends StatelessWidget {
  /// Creates a text field.
  const WizardField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.error,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.suffixText,
    super.key,
  });

  /// Field label, shown above the input.
  final String label;

  /// Current value.
  final String value;

  /// Called on every keystroke.
  ///
  /// Fires on change rather than on submit so the wizard state is always the
  /// source of truth. The wizard re-reads it to decide whether the seller may
  /// leave the step.
  final ValueChanged<String> onChanged;

  /// Inline error message, or null when the field is fine.
  final String? error;

  /// Placeholder shown when empty.
  final String? hint;

  /// Keyboard type for this input.
  final TextInputType? keyboardType;

  /// Input formatters, typically to restrict to digits.
  final List<TextInputFormatter>? inputFormatters;

  /// Number of lines for a multiline field.
  final int maxLines;

  /// Unit shown after the value, e.g. `sqm`.
  final String? suffixText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value,
        onChanged: onChanged,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixText: suffixText,
          border: const OutlineInputBorder(),
          errorText: error,
        ),
      ),
    );
  }
}

/// Restricts a numeric input to digits.
///
/// Applied at the input layer rather than only in validation so a seller
/// cannot type a letter and be told afterwards it is not a number.
List<TextInputFormatter> get digitsOnly =>
    <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly];

/// A section heading inside a step.
class WizardSection extends StatelessWidget {
  /// Creates a section heading.
  const WizardSection(this.title, {this.subtitle, super.key});

  /// Heading text.
  final String title;

  /// Optional explanation under the heading.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: theme.textTheme.titleMedium),
          if (subtitle case final text?) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              text,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ],
      ),
    );
  }
}

/// A note explaining why a control is absent or disabled.
///
/// Used where the honest answer is "this cannot be set yet" rather than a
/// silently missing field — for example the contact number, which is released
/// through a rate-limited RPC and so has no listing-level field at all.
class WizardNote extends StatelessWidget {
  /// Creates a note.
  const WizardNote({required this.text, this.icon, super.key});

  /// The explanation.
  final String text;

  /// Optional leading icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon case final glyph?) ...<Widget>[
            Icon(glyph, size: 18, color: theme.colorScheme.outline),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

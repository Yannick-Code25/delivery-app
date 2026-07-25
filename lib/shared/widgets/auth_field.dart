import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Labelled text field used by the auth screens, matching the input treatment in
/// ref/.../connexion_3d_babali and ref/.../inscription_3d_babali: a filled field
/// with a leading icon that tints while focused.
class AuthField extends StatefulWidget {
  const AuthField({
    required this.label,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.validator,
    this.onFieldSubmitted,
    this.suffix,
    this.trailingLabel,
    super.key,
  });

  final String label;
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<String>? autofillHints;
  final bool obscureText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffix;

  /// Optional action rendered at the end of the label row (e.g. "Oublié ?").
  final Widget? trailingLabel;

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: AppTextStyles.labelMd.copyWith(color: colorScheme.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.trailingLabel != null) widget.trailingLabel!,
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          obscureText: widget.obscureText,
          validator: widget.validator,
          onFieldSubmitted: widget.onFieldSubmitted,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.only(left: AppSpacing.gutter, right: AppSpacing.sm),
              child: Icon(
                widget.icon,
                color: _focusNode.hasFocus
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            suffixIcon: widget.suffix,
          ),
        ),
      ],
    );
  }
}

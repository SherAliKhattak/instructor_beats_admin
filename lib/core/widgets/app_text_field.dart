import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instructor_beats_admin/theme/app_colors.dart';
import 'package:instructor_beats_admin/theme/app_text_styles.dart';

/// Custom auth text field with label, leading icon, optional visibility toggle.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.leadingIcon,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.helperText,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  final String label;
  final String placeholder;
  final IconData leadingIcon;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final String? helperText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant AuthTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscureText = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderColor = scheme.outline;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.onboardingDescription.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType ?? TextInputType.text,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          style: TextStyle(color: scheme.onSurface),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: AppTextStyles.onboardingDescription.copyWith(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
            ),
            prefixIcon: Icon(
              widget.leadingIcon,
              size: 22,
              color: scheme.onSurfaceVariant,
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 22,
                      color: scheme.onSurfaceVariant,
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  )
                : null,
            filled: true,
            fillColor: scheme.surfaceContainerHighest,
            border: _inputBorder(borderColor),
            enabledBorder: _inputBorder(borderColor),
            focusedBorder: _inputBorder(
              scheme.brightness == Brightness.dark
                  ? scheme.primary
                  : AppColors.primary.withValues(alpha: 0.5),
              width: 1.5,
            ),
            errorBorder: _inputBorder(Colors.red.shade300),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.helperText!,
            style: AppTextStyles.onboardingDescription.copyWith(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}

/// Backward-compatible wrapper so existing screens can keep using AppLabeledField.
class AppLabeledField extends StatelessWidget {
  const AppLabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.onToggleObscure,
    this.prefixIcon,
    this.suffixIcon,
    this.helperText,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? helperText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      label: label,
      placeholder: hint ?? '',
      leadingIcon: prefixIcon ?? Icons.text_fields_rounded,
      controller: controller,
      obscureText: obscureText,
      helperText: helperText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class AuthTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator; // para validação opcional
  final void Function(String)? onChanged;

  const AuthTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // final isDark = AppTheme.currentMode(context);
    final isDark = context.isDarkMode;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      cursorColor: context.colors.onPrimary,
      style: TextStyle(
        color: context.colors.onSurface,
        // color: AppColors.text(context),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: context.colors.onSurface),
        // labelStyle: TextStyle(color: AppColors.text(context)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark
            ? context.colors.primary.withValues(alpha: 0.9)
            : context.colors.secondary.withValues(alpha: 0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color:context.colors.onPrimary.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color:context.colors.onPrimary.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context.colors.onPrimary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

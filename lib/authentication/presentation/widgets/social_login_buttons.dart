import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/theme/app_theme.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onGoogle;
  final VoidCallback onFacebook;
  final VoidCallback onApple;
  final bool busy;

  const SocialLoginButtons({
    super.key,
    required this.onGoogle,
    required this.onFacebook,
    required this.onApple,
    this.busy = false,
  });

  
  @override
  Widget build(BuildContext context) {
    // final isDark = AppTheme.currentMode(context);
    final googleColor = Colors.redAccent;
    final facebookColor = Colors.blue;
    final appleColor = context.colors.inverseSurface;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circleIconButton(
          context: context,
          icon: FontAwesomeIcons.google,
          iconColor: googleColor,
          tooltip: 'Entrar com Google',
          onPressed: busy ? null : onGoogle,
        ),
        const SizedBox(width: 16),
        _circleIconButton(
          context: context,
          icon: FontAwesomeIcons.facebook,
          iconColor: facebookColor,
          tooltip: 'Entrar com Facebook',
          onPressed: busy ? null : onFacebook,
        ),
        const SizedBox(width: 16),
        _circleIconButton(
          context: context,
          icon: FontAwesomeIcons.apple,
          iconColor: appleColor,
          tooltip: 'Entrar com Apple',
          onPressed: busy ? null : onApple,
        ),
      ],
    );
  }
Widget _circleIconButton({
    required BuildContext context,
    required FaIconData icon,
    required Color iconColor,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    // final isDark = AppTheme.currentMode(context);
    // final borderColor = AppColors.primary(context);
    // final backgroundColor = isDark
    //     ? AppColors.background(context).withOpacity(0.2)
    //     : AppColors.background(context).withOpacity(0.2);
    final borderColor = context.colors.primary;
    final backgroundColor = context.colors.surface.withValues(alpha: 0.2);

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: tooltip,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1),
          color: backgroundColor,
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: FaIcon(icon, color: iconColor),
          tooltip: tooltip,
        ),
      ),
    );
  }

}

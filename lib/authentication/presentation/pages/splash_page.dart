import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injustice_app/core/di/dependency_injection.dart';
import 'package:injustice_app/core/routes/app_routes.dart';
import 'package:injustice_app/core/routes/auth_routes.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/auth_session_viewmodel.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // late final AuthViewModel _authViewModel;

  @override
  void initState() {
    super.initState();

    // Pega a ViewModel diretamente do auto_injector
    final authSession = injector.get<AuthViewModel>();

    // Timer simulando carregamento
    Timer(const Duration(milliseconds: 2400), () async {
      // await _authViewModel.loadCurrentUser(); // carrega usuário
      if (!mounted) return;

      final loggedIn = authSession.session.isAuthenticated;

      // final loggedIn = false;
      if (loggedIn) {
        // final auth = authSession.session.session.value;
        // context.goNamed(AppRouteNames.adventureHome);
        context.goNamed(AppRouteNames.home);
      } else {
        context.goNamed(AuthRouteNames.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // pega cores dinamicamente do tema ativo
    // final isDark = AppTheme.currentMode(context);
    // final backgroundColor = AppColors.background(context);
    // final iconColor = AppColors.primary(context);
    // final textColor = AppColors.text(context);

    final backgroundColor = context.colors.surface;
    final iconColor = context.colors.inversePrimary;
    final textColor = context.colors.onSurface;
    final progressColor = iconColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock, size: 72, color: iconColor),
            const SizedBox(height: 16),
            Text(
              'Autenticação de Usuário',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: textColor),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                color: progressColor,
                strokeWidth: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

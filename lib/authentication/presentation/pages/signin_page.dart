import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injustice_app/core/di/dependency_injection.dart';
import 'package:injustice_app/core/routes/app_routes.dart';
import 'package:injustice_app/core/routes/auth_routes.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/auth_session_viewmodel.dart';
import '../widgets/auth_text_form_field.dart';
import '../widgets/social_login_buttons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthViewModel authController;

  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool obscure = true;

  @override
  void initState() {
    authController = injector.get<AuthViewModel>();
    super.initState();
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    // final scope = AuthScope.of(context);
    // final vm = scope.notifier!;
    // final isDark = AppTheme.currentMode(context);
    final isDark = context.isDarkMode;

    return Scaffold(
      // backgroundColor: AppColors.background(context),
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Bem-vindo de volta',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: context.colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Entre para continuar',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.colors.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 28),
                    AuthTextFormField(
                      controller: emailCtrl,
                      label: 'E-mail',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe seu e-mail';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'E-mail inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    AuthTextFormField(
                      controller: passCtrl,
                      label: 'Senha',
                      obscureText: obscure,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(() => obscure = !obscure),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe sua senha';
                        }
                        if (value.length < 6) {
                          return 'Senha muito curta';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: context.colors.primary,
                        ),
                        child: const Text('Esqueceu a senha?'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Watch((context) {
                      final isRunning = authController
                          .commands
                          .signInCommand
                          .isExecuting
                          .value;

                      return ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() != true) {
                            return;
                          }

                          try {
                            await authController.commands.signIn(
                              emailCtrl.text,
                              passCtrl.text,
                            );

                            final auth = authController.session.session.value;
                            if (auth == null) {
                              final msg = authController.session.message.value;
                              _showSnack(msg ?? 'Falha ao autenticar usuário.');
                              return;
                            }
                            context.goNamed(AppRouteNames.home);
                          } catch (e) {
                            _showSnack('Erro ao fazer login: $e');
                          }
                        },
                        child: isRunning
                            ? const CircularProgressIndicator()
                            : Text(
                                'Entrar',
                                style: TextStyle(
                                  color: context.colors.onSecondary,
                                ),
                              ),
                      );
                    }),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: isDark
                                ? context.theme.scaffoldBackgroundColor
                                : context.colors.onPrimary.withValues(
                                    alpha: 0.8,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Ou continue com',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: context.colors.onPrimary.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Divider(
                            color: isDark
                                ? context.theme.scaffoldBackgroundColor
                                : context.colors.onPrimary.withValues(
                                    alpha: 0.8,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SocialLoginButtons(
                      onGoogle: () async {
                        try {
                          await authController.commands.signInWithGoogle();

                          if (authController.session.message.value != null) {
                            _showSnack(authController.session.message.value!);
                            return;
                          }
                          context.goNamed(AppRouteNames.home);
                        } catch (e) {
                          _showSnack('Erro ao fazer login: $e');
                        }
                      },
                      onFacebook: () {},
                      onApple: () {},
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Não tem conta? ',
                          style: TextStyle(color: context.colors.onPrimary),
                        ),
                        TextButton(
                          onPressed: () {
                            context.goNamed(AuthRouteNames.register);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: context.colors.onSecondary,
                          ),
                          child: const Text('Criar conta'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

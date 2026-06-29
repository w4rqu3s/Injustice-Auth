import 'package:injustice_app/core/di/dependency_injection.dart';
import 'package:injustice_app/core/routes/app_routes.dart';
import 'package:injustice_app/core/routes/auth_routes.dart';
import 'package:injustice_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injustice_app/domain/models/account_entity.dart';
import 'package:injustice_app/presentation/controllers/account_viewmodel.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../controllers/auth_session_viewmodel.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late final AuthViewModel _authController;
  late final AccountViewModel _accountViewModel; // ← adicionado
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    _authController = injector.get<AuthViewModel>();
    _accountViewModel = injector.get<AccountViewModel>(); // ← adicionado
    super.initState();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    try {
      await _authController.commands.signUp(
        email: email,
        password: pass,
        name: name,
      );

      final auth = _authController.session.session.value;
      if (auth == null) {
        final msg = _authController.session.message.value;
        _showSnack(msg ?? 'Falha ao cadastrar usuário.');
        return;
      }

      await _accountViewModel.commands.saveAccount(
        Account(
          name: name,
          email: email,
          displayName: name,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          level: 1,
          gold: 0,
          gems: 0,
          energy: 100,
        ),
      );

      if (!mounted) return;
      context.goNamed(AppRouteNames.home);
    } catch (e) {
      _showSnack('Erro ao cadastrar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InputTextField(
                      controller: _nameCtrl,
                      labelText: 'Nome',
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Informe seu nome' : null,
                    ),
                    const SizedBox(height: 12),
                    InputTextField(
                      controller: _emailCtrl,
                      labelText: 'E-mail',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe seu e-mail';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v))
                          return 'E-mail inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    InputTextField(
                      controller: _passCtrl,
                      labelText: 'Senha',
                      obscureText: _obscure,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe sua senha';
                        if (v.length < 6) return 'Senha muito curta';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    InputTextField(
                      controller: _confirmCtrl,
                      labelText: 'Confirmar senha',
                      obscureText: _obscure,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Confirme sua senha';
                        if (v != _passCtrl.text) return 'Senhas não coincidem';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    Watch((context) {
                      final isExecuting = _authController
                          .commands
                          .signUpCommand
                          .isExecuting
                          .value;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isExecuting ? null : _submit,
                          child: isExecuting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Criar conta'),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go(AuthRouteNames.login),
                      child: const Text('Já tem conta? Login'),
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

class InputTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const InputTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: context.colors.onSurface),
      cursorColor: context.colors.onPrimary,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.error)) {
            return TextStyle(color: context.colors.error);
          }
          return TextStyle(color: context.colors.onSurface);
        }),
        suffixIcon: suffixIcon,
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.error)) {
            return TextStyle(color: context.colors.error);
          }
          return TextStyle(color: context.colors.onSurface);
        }),
      ),
      validator: validator,
    );
  }
}

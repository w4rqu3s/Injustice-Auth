import 'package:injustice_app/core/di/dependency_injection.dart';
import 'package:injustice_app/core/routes/auth_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../domain/models/auth_entities.dart';
import '../controllers/auth_session_viewmodel.dart';
import '../widgets/social_login_buttons.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.session});

  final String title;
  final AuthSession session;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final AuthViewModel authController;
  @override
  void initState() {
    authController = injector.get<AuthViewModel>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // User info section
            if (widget.session != null) ...[
              CircleAvatar(
                radius: 36,
                child: Text(
                  (widget.session.user.name.isNotEmpty
                          ? widget.session.user.name[0]
                          : '?')
                      .toUpperCase(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.session.user.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                widget.session.user.email,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 18),
            ] else ...[
              SocialLoginButtons(
                onGoogle: () {},
                onFacebook: () {},
                onApple: () {},
              ),
              const SizedBox(height: 12),
            ],
            Watch((context) {
              final isRunning =
                  authController.commands.signOutCommand.isExecuting.value;

              return ElevatedButton(
                onPressed: () async {
                  await authController.commands.signOut();
                  context.goNamed(AuthRouteNames.login);
                },
                child:
                    isRunning
                        ? const CircularProgressIndicator()
                        : const Text('Desconectar'),
              );
            }),

            ElevatedButton(
              onPressed: () async {
                await authController.commands.signOut();
                context.goNamed(AuthRouteNames.login);
              },
              child: Text('Desconectar'),
            ),
          ],
        ),
      ),
    );
  }
}

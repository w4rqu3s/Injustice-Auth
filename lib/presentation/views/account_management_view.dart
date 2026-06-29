import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injustice_app/presentation/widgets/account_edit_sheet.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/routes/auth_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/account_entity.dart';
import '../controllers/account_viewmodel.dart';
import '../controllers/account_state_viewmodel.dart';
import '../functions/ui_functions.dart';
import '../widgets/app_drawer.dart';
import '../../authentication/presentation/controllers/auth_session_viewmodel.dart';

class AccountManagementView extends StatefulWidget {
  const AccountManagementView({super.key});

  @override
  State<AccountManagementView> createState() => _AccountManagementViewState();
}

class _AccountManagementViewState extends State<AccountManagementView> {
  late final AccountViewModel _vmAccount;
  late final AuthViewModel _vmAuth;
  late final void Function() _disposeSuccessEffect;
  late final void Function() _disposeErrorEffect;

  @override
  void initState() {
    super.initState();
    _vmAccount = injector.get<AccountViewModel>();
    _vmAuth = injector.get<AuthViewModel>();

    _disposeErrorEffect = effect(() {
      final msg = _vmAccount.accountState.message.value;
      if (msg != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showSnackBar(context, msg, backgroundColor: Colors.red);
          _vmAccount.accountState.clearMessage();
        });
      }
    });

    _disposeSuccessEffect = effect(() {
      final event = _vmAccount.accountState.successEvent.value;
      if (event != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final msg = switch (event) {
            AccountSuccessEvent.created => 'Conta criada com sucesso!',
            AccountSuccessEvent.updated => 'Conta atualizada com sucesso!',
            AccountSuccessEvent.deleted => 'Conta excluída com sucesso!',
          };
          showSnackBar(
            context,
            msg,
            backgroundColor: event == AccountSuccessEvent.deleted
                ? Colors.red.shade400
                : Colors.green,
          );
          _vmAccount.accountState.clearSuccessEvent();
        });
      }
    });
  }

  @override
  void dispose() {
    _disposeErrorEffect();
    _disposeSuccessEffect();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirm = await confirmDialog(
      context,
      title: 'Sair da conta',
      message: 'Deseja realmente sair?',
      confirmText: 'SAIR',
    );
    if (!confirm) return;
    await _vmAuth.commands.signOut();
    if (mounted) context.goNamed(AuthRouteNames.login);
  }

  void _openEditSheet(Account account) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AccountEditSheet(account: account, vmAccount: _vmAccount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Contas')),
      drawer: AppDrawer(),
      body: Watch((context) {
        final account = _vmAccount.accountState.state.value;

        if (account == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // — Conta logada —
              _AccountCard(
                account: account,
                isActive: true,
                onEdit: () => _openEditSheet(account),
              ),

              const SizedBox(height: 32),

              // — Ações —
              _SectionTitle(title: 'Ações'),
              const SizedBox(height: 12),

              _ActionTile(
                icon: Icons.person_add,
                label: 'Adicionar conta',
                onTap: () async {
                  await _vmAuth.commands.signOut();
                  if (mounted) context.goNamed(AuthRouteNames.login);
                },
              ),

              _ActionTile(
                icon: Icons.logout,
                label: 'Sair',
                color: Colors.red.shade400,
                onTap: _logout,
              ),
            ],
          ),
        );
      }),
    );
  }
}

// — Widgets internos —

class _AccountCard extends StatelessWidget {
  final Account account;
  final bool isActive;
  final VoidCallback onEdit;

  const _AccountCard({
    required this.account,
    required this.isActive,
    required this.onEdit,
  });

  String get _initials {
    final parts = account.displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colors.secondary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar com iniciais
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: colors.primary,
                  child: Text(
                    _initials,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colors.onPrimary,
                    ),
                  ),
                ),
                if (isActive)
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.green,
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              account.displayName,
              style: context.textStyles.headlineMedium?.bold.withColor(
                colors.onSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              account.email,
              style: context.textStyles.bodyMedium?.withColor(
                colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Nível ${account.level}  •  ${account.gems} gemas  •  ${account.gold.toStringAsFixed(0)} ouro',
              style: context.textStyles.bodySmall?.withColor(
                colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
              label: const Text('Editar conta'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.onSecondary,
                side: BorderSide(color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textStyles.titleMedium?.bold.withColor(
        Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? Theme.of(context).colorScheme.onSecondary;
    return ListTile(
      leading: Icon(icon, color: tileColor),
      title: Text(label, style: TextStyle(color: tileColor)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:injustice_app/presentation/controllers/account_viewmodel.dart';
import 'package:injustice_app/presentation/functions/ui_functions.dart';
import 'package:injustice_app/presentation/widgets/account_attribute_card.dart';
import 'package:injustice_app/presentation/widgets/date_wheel_picker.dart';
import 'package:injustice_app/presentation/widgets/input_text_field.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/validators/email_str_validator.dart';
import '../../../core/validators/empty_str_validator.dart';
import '../../../core/validators/text_field_validator.dart';
import '../../../domain/models/account_entity.dart';

class AccountEditSheet extends StatefulWidget {
  final Account account;
  final AccountViewModel vmAccount;

  const AccountEditSheet({
    super.key,
    required this.account,
    required this.vmAccount,
  });

  @override
  State<AccountEditSheet> createState() => _AccountEditSheetState();
}

class _AccountEditSheetState extends State<AccountEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _displayNameCtrl;
  late DateTime _createdAt;
  late int _level;
  late double _gold;
  late int _gems;
  late int _energy;

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    _emailCtrl = TextEditingController(text: a.email);
    _nameCtrl = TextEditingController(text: a.name);
    _displayNameCtrl = TextEditingController(text: a.displayName);
    _createdAt = a.createdAt;
    _level = a.level;
    _gold = a.gold;
    _gems = a.gems;
    _energy = a.energy;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _displayNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = Account(
      email: _emailCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      displayName: _displayNameCtrl.text.trim(),
      createdAt: _createdAt,
      updatedAt: DateTime.now(),
      level: _level,
      gold: _gold,
      gems: _gems,
      energy: _energy,
    );

    await widget.vmAccount.commands.updateAccount(updated);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text(
                'Editar Conta',
                style: context.textStyles.headlineSmall?.bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              InputTextField(
                controller: _emailCtrl,
                label: 'Email',
                hint: 'Digite seu e-mail',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => validateField(v, [
                  EmptyStrValidator(),
                  EmailStrValidator(),
                ]),
              ),
              const SizedBox(height: 12),

              InputTextField(
                controller: _nameCtrl,
                label: 'Nome',
                hint: 'Digite seu nome',
                prefixIcon: Icons.account_circle,
                validator: (v) => validateField(v, [EmptyStrValidator()]),
              ),
              const SizedBox(height: 12),

              InputTextField(
                controller: _displayNameCtrl,
                label: 'Apelido',
                hint: 'Digite seu apelido',
                prefixIcon: Icons.verified_user,
                validator: (v) => validateField(v, [EmptyStrValidator()]),
              ),
              const SizedBox(height: 12),

              DateWheelPicker(
                label: 'Data de Criação',
                selectedDate: _createdAt,
                onDateSelected: (date) => setState(() => _createdAt = date),
              ),
              const SizedBox(height: 12),

              AccountAttributeCard(
                icon: Icons.star,
                iconColor: Theme.of(context).colorScheme.primary,
                label: 'Nível',
                hint: '[1, 80]',
                minValue: 1,
                maxValue: 80,
                value: _level,
                onChanged: (v) => setState(() => _level = v),
              ),
              const SizedBox(height: 1),
              AccountAttributeCard(
                icon: Icons.monetization_on,
                iconColor: Colors.amber,
                label: 'Ouro',
                hint: 'Min: 0',
                minValue: 0,
                maxValue: 999999,
                value: _gold.toInt(),
                onChanged: (v) => setState(() => _gold = v.toDouble()),
              ),
              const SizedBox(height: 1),
              AccountAttributeCard(
                icon: Icons.diamond,
                iconColor: Colors.cyan,
                label: 'Gemas',
                hint: 'Min: 0',
                minValue: 0,
                maxValue: 999999,
                value: _gems,
                onChanged: (v) => setState(() => _gems = v),
              ),
              const SizedBox(height: 1),
              AccountAttributeCard(
                icon: Icons.bolt,
                iconColor: Colors.orange,
                label: 'Energia',
                hint: 'Min: 1',
                minValue: 1,
                maxValue: 999999,
                value: _energy,
                onChanged: (v) => setState(() => _energy = v),
              ),
              const SizedBox(height: 24),

              Watch((context) {
                final isRunning = widget
                    .vmAccount
                    .commands
                    .updateAccountCommand
                    .isExecuting
                    .value;
                return ElevatedButton(
                  onPressed: isRunning ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isRunning
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar alterações'),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

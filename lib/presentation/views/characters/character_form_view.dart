import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';

import 'package:injustice_app/domain/models/character_entity.dart';
import 'package:injustice_app/core/theme/app_theme.dart';
import 'package:injustice_app/presentation/widgets/input_text_field.dart';
import 'package:injustice_app/presentation/widgets/numeric_spinner.dart';
import 'package:injustice_app/presentation/widgets/star_rating.dart';

class CharacterFormView extends StatefulWidget {
  final Character? character;

  const CharacterFormView({super.key, this.character});

  bool get isEditing => character != null;

  @override
  State<CharacterFormView> createState() => _CharacterFormViewState();
}

class _CharacterFormViewState extends State<CharacterFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;

  CharacterClass _characterClass = CharacterClass.poderoso;
  CharacterRarity _rarity = CharacterRarity.prata;
  CharacterAlignment _alignment = CharacterAlignment.heroi;

  int _level = 1;
  int _threat = 0;
  int _attack = 50;
  int _health = 100;
  int _stars = 1;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();

    if (widget.character != null) {
      final c = widget.character!;

      _nameController.text = c.name;

      _characterClass = c.characterClass;
      _rarity = c.rarity;
      _alignment = c.alignment;

      _level = c.level;
      _threat = c.threat;
      _attack = c.attack;
      _health = c.health;
      _stars = c.stars;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();

    final character =
        widget.character?.copyWith(
          name: _nameController.text.trim(),
          characterClass: _characterClass,
          rarity: _rarity,
          alignment: _alignment,
          level: _level,
          threat: _threat,
          attack: _attack,
          health: _health,
          stars: _stars,
          updatedAt: now,
        ) ??
        Character(
          id: const Uuid().v4(),
          name: _nameController.text.trim(),
          characterClass: _characterClass,
          rarity: _rarity,
          alignment: _alignment,
          level: _level,
          threat: _threat,
          attack: _attack,
          health: _health,
          stars: _stars,
          createdAt: now,
          updatedAt: now,
        );

    Navigator.pop(context, character);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Editar Personagem' : 'Criar Personagem',
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.person,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: AppSpacing.lg),

              InputTextField(
                label: 'Nome',
                controller: _nameController,
                prefixIcon: Icons.badge,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe um nome';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              DropdownButtonFormField<CharacterClass>(
                value: _characterClass,
                decoration: const InputDecoration(labelText: 'Classe'),
                items: CharacterClass.values
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _characterClass = value;
                    });
                  }
                },
              ),

              const SizedBox(height: AppSpacing.md),

              DropdownButtonFormField<CharacterRarity>(
                value: _rarity,
                decoration: const InputDecoration(labelText: 'Raridade'),
                items: CharacterRarity.values
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _rarity = value;
                    });
                  }
                },
              ),

              const SizedBox(height: AppSpacing.md),

              DropdownButtonFormField<CharacterAlignment>(
                value: _alignment,
                decoration: const InputDecoration(labelText: 'Alinhamento'),
                items: CharacterAlignment.values
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _alignment = value;
                    });
                  }
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              NumericSpinner(
                label: 'Nível',
                value: _level,
                minValue: 1,
                maxValue: 80,
                onChanged: (value) {
                  setState(() {
                    _level = value;
                  });
                },
              ),

              const SizedBox(height: AppSpacing.md),

              NumericSpinner(
                label: 'Ameaça',
                value: _threat,
                minValue: 0,
                maxValue: 500,
                onChanged: (value) {
                  setState(() {
                    _threat = value;
                  });
                },
              ),

              const SizedBox(height: AppSpacing.md),

              NumericSpinner(
                label: 'Ataque',
                value: _attack,
                minValue: 0,
                maxValue: 9999,
                onChanged: (value) {
                  setState(() {
                    _attack = value;
                  });
                },
              ),

              const SizedBox(height: AppSpacing.md),

              NumericSpinner(
                label: 'Vida',
                value: _health,
                minValue: 0,
                maxValue: 99999,
                onChanged: (value) {
                  setState(() {
                    _health = value;
                  });
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              Text('Estrelas', style: Theme.of(context).textTheme.titleMedium),

              const SizedBox(height: AppSpacing.sm),

              Center(
                child: StarRating(
                  stars: _stars,
                  size: 36,
                  interactive: true,
                  onStarsChanged: (value) {
                    setState(() {
                      _stars = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              ElevatedButton(
                onPressed: _save,
                child: Text(
                  widget.isEditing ? 'SALVAR ALTERAÇÕES' : 'CRIAR PERSONAGEM',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:injustice_app/domain/models/character_entity.dart';
import 'package:injustice_app/presentation/views/characters/character_form_view.dart';
import '../../../../controllers/characters_view_model.dart';
import 'package:signals_flutter/signals_flutter.dart';

class CharactersFab extends StatelessWidget {
  final CharactersViewModel viewModel;

  const CharactersFab({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final isExecuting =
          viewModel.commands.createCharacterCommand.isExecuting.value;

      return FloatingActionButton(
        onPressed: isExecuting
            ? null
            : () async {
                final character = await Navigator.push<Character>(
                  context,
                  MaterialPageRoute(builder: (_) => const CharacterFormView()),
                );

                if (character == null) return;

                await viewModel.commands.addCharacter(character);
              },
        child: isExecuting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add),
      );
    });
  }
}

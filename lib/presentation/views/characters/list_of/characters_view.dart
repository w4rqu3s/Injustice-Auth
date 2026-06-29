import 'package:flutter/material.dart';
import 'widgets/characters_app_bar.dart';
import 'widgets/characters_body.dart';
import 'widgets/characters_floating_button.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../domain/models/character_entity.dart';
import '../../../controllers/account_viewmodel.dart';
import '../../../controllers/characters_view_model.dart';
import '../../../widgets/app_drawer.dart';

/// Página de listagem de personagens
class CharactersView extends StatefulWidget {
  const CharactersView({super.key}); // ← removido account

  @override
  State<CharactersView> createState() => _CharactersViewState();
}

class _CharactersViewState extends State<CharactersView> {
  late final CharactersViewModel _viewModel;
  late final AccountViewModel _accountViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<CharactersViewModel>();
    _accountViewModel = injector.get<AccountViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.commands.fetchCharacters();
    });
  }

  Future<void> _deleteCharacter(Character character) async {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${character.name} removido')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = _accountViewModel.accountState.state.value;

    return Scaffold(
      appBar: CharactersAppBar(state: _viewModel.charactersState),
      drawer: AppDrawer(),
      body: CharactersBody(account: account, viewModel: _viewModel),
      floatingActionButton: CharactersFab(viewModel: _viewModel),
    );
  }
}

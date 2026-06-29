import 'package:flutter/material.dart';
import 'package:injustice_app/core/theme/app_theme.dart';
// Lembre-se de importar o arquivo onde estão as suas extensions (ThemeContext, etc)
// import '../../../core/theme/app_theme.dart'; 

class UnderConstructionView extends StatelessWidget {
  // Caso você precise passar a função de logout do seu gerenciador de estado
  final VoidCallback? onLogout;

  const UnderConstructionView({
    super.key,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usando a sua extension para pegar a cor de fundo!
      backgroundColor: context.theme.scaffoldBackgroundColor,
      
      appBar: AppBar(
        title: const Text('Início'),
        centerTitle: true,
      ),
      
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone animado ou grande de construção
              Icon(
                Icons.handyman_rounded, // ou Icons.construction
                size: 80,
                color: context.colors.primary,
              ),
              
              const SizedBox(height: 24),
              
              // Texto principal
              Text(
                'App em Construção \u{1F6A7}',
                style: context.textStyles.headlineSmall?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Texto secundário explicativo
              Text(
                'Você fez login com sucesso!\nA tela inicial oficial ainda está sendo desenvolvida.',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Botão útil para você poder deslogar e testar o login de novo
              FilledButton.icon(
                onPressed: onLogout ?? () {
                  // Se não passar a função de logout, apenas avisa
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Coloque a sua função de logout aqui!'),
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sair para testar o login novamente'),
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.secondary,
                  foregroundColor: context.colors.onSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
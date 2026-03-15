import 'package:flutter/material.dart';
import 'package:prontosindico/constants.dart';

import 'components/prederence_list_tile.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Preferências de cookies"),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Redefinir"),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: defaultPadding),
        child: Column(
          children: [
            PreferencesListTile(
              titleText: "Análises",
              subtitleTxt:
                  "Cookies de análise nos ajudam a melhorar o aplicativo coletando informações sobre como você o utiliza, sem identificar diretamente as pessoas.",
              isActive: true,
              press: () {},
            ),
            const Divider(height: defaultPadding * 2),
            PreferencesListTile(
              titleText: "Personalização",
              subtitleTxt:
                  "Cookies de personalização coletam informações sobre seu uso do app para exibir conteúdo e experiência relevantes para você.",
              isActive: false,
              press: () {},
            ),
            const Divider(height: defaultPadding * 2),
            PreferencesListTile(
              titleText: "Marketing",
              subtitleTxt:
                  "Cookies de marketing coletam informações sobre seu uso deste e de outros apps para exibir anúncios e ações de marketing mais relevantes.",
              isActive: false,
              press: () {},
            ),
            const Divider(height: defaultPadding * 2),
            PreferencesListTile(
              titleText: "Cookies de redes sociais",
              subtitleTxt:
                  "Estes cookies são definidos por serviços de redes sociais que permitem compartilhar nosso conteúdo com amigos e redes.",
              isActive: false,
              press: () {},
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/screens/home/menu_lateral.dart';
import 'package:prontosindico/constants.dart';
import 'package:prontosindico/providers/auth_provider.dart';
import 'package:prontosindico/route/screen_export.dart';
import 'components/profile_card.dart';
import 'components/profile_menu_item_list_tile.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider).valueOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF0F172A)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "Meu Perfil",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: defaultPadding),
        children: [
          ProfileCard(
            name: userProfile?.name ?? "Carregando...",
            email: userProfile?.email ?? "Carregando...",
            imageSrc: (userProfile?.photoUrl != null &&
                    userProfile!.photoUrl!.isNotEmpty)
                ? userProfile.photoUrl!
                : "https://cdn-icons-png.flaticon.com/512/149/149071.png",
            press: () {
              Navigator.pushNamed(context, userInfoScreenRoute);
            },
          ).animate().fadeIn().moveY(begin: -20),
          const SizedBox(height: defaultPadding),
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Text(
              "Minha Gestão",
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ).animate().fadeIn(delay: 200.ms),
          ProfileMenuListTile(
            text: "Minhas Reservas",
            svgSrc: "assets/icons/Return.svg",
            press: () => Navigator.pushNamed(context, reservasScreenRoute),
          ),
          ProfileMenuListTile(
            text: "Avisos e Mural",
            svgSrc: "assets/icons/Wishlist.svg",
            press: () => Navigator.pushNamed(context, muralScreenRoute),
          ),
          const SizedBox(height: defaultPadding * 2),
        ],
      ),
    );
  }
}

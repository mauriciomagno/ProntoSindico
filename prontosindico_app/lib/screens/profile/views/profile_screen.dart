import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:prontosindico/constants.dart';
import 'package:prontosindico/providers/auth_provider.dart';
import 'package:prontosindico/route/screen_export.dart';

import 'components/profile_card.dart';
import 'components/profile_menu_item_list_tile.dart';

import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _userName = "Carregando...";
  String _userEmail = "Carregando...";
  String _userImage =
      "https://cdn-icons-png.flaticon.com/512/149/149071.png"; // Default image

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da Conta'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: errorColor),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Email vem da autenticação e também pode existir no banco.
      _userEmail = user.email ?? "";

      // Busca dados no nó padrão do projeto: usuarios/{uid}
      final dbRef = FirebaseDatabase.instance.ref('usuarios/${user.uid}');
      final snapshot = await dbRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        _userName = (data?['nome'] as String?) ?? _userName;
        _userEmail = (data?['email'] as String?) ?? _userEmail;
        _userImage = (data?['Foto'] as String?)?.isNotEmpty == true
            ? data!['Foto'] as String
            : _userImage;
      } else {
        _userName = "Usuário sem dados";
      }
    } else {
      _userName = "Usuário não logado";
      _userEmail = "";
    }
    // Update the UI
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ProfileCard(
            name: _userName,
            email: _userEmail,
            imageSrc: _userImage,
            press: () {
              Navigator.pushNamed(context, userInfoScreenRoute);
            },
          ).animate().fadeIn().moveY(begin: -20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Text(
              "Minha Gestão",
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: defaultPadding / 2),

          ...[
            ProfileMenuListTile(
              text: "Unidades e Moradores",
              svgSrc: "assets/icons/Order.svg",
              press: () {
                Navigator.pushNamed(context, ordersScreenRoute);
              },
            ),
            ProfileMenuListTile(
              text: "Minhas Reservas",
              svgSrc: "assets/icons/Return.svg",
              press: () {},
            ),
            ProfileMenuListTile(
              text: "Boletos e Taxas",
              svgSrc: "assets/icons/Wishlist.svg",
              press: () {},
            ),
            ProfileMenuListTile(
              text: "Documentos do Condomínio",
              svgSrc: "assets/icons/Address.svg",
              press: () {
                Navigator.pushNamed(context, addressesScreenRoute);
              },
            ),
          ],

          const SizedBox(height: defaultPadding),

          // Log Out
          ListTile(
            onTap: () => _confirmSignOut(context),
            minLeadingWidth: 24,
            leading: SvgPicture.asset(
              "assets/icons/Logout.svg",
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                errorColor,
                BlendMode.srcIn,
              ),
            ),
            title: const Text(
              "Sair da Conta",
              style: TextStyle(
                  color: errorColor,
                  fontSize: 14,
                  height: 1,
                  fontWeight: FontWeight.bold),
            ),
          ).animate().fadeIn(delay: 1500.ms).moveY(begin: 20),
          const SizedBox(height: defaultPadding * 2),
        ],
      ),
    );
  }
}

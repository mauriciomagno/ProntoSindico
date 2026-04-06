import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/constants.dart';
import 'package:prontosindico/domain/enums/user_role.dart';
import 'package:prontosindico/providers/auth_provider.dart';
import 'package:prontosindico/providers/navigation_provider.dart';
import 'package:prontosindico/route/screen_export.dart';
import 'package:prontosindico/screens/privacy/views/privacy_screen.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final userProfile = userProfileAsync.valueOrNull;
    final isAdmin = userProfile?.role == UserRole.administrador;
    final canManageBills = userProfile?.role == UserRole.administrador ||
        userProfile?.role == UserRole.tesoureiro;
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Final Premium Header (Mantido no topo com Scroll)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                      20, 50, 20, 20), // Padding reduzido
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: (userProfile?.photoUrl != null &&
                                  userProfile!.photoUrl!.isNotEmpty)
                              ? Image.network(
                                  userProfile.photoUrl!,
                                  width: 50, // Tamanho reduzido
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Image.asset(
                                    "assets/logo/logo.png",
                                    width: 50,
                                    height: 50,
                                  ),
                                )
                              : Image.asset(
                                  "assets/logo/logo.png",
                                  width: 50,
                                  height: 50,
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userProfile?.name ?? "Pronto Síndico",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16, // Fonte reduzida
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userProfile?.email ?? "sindico@prontosindico.com",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _DrawerItem(
                  icon: Icons.home,
                  label: "Início",
                  isActive:
                      currentRoute == homeScreenRoute || currentRoute == null,
                  onTap: () {
                    final navigator = Navigator.of(context);
                    if (currentRoute == homeScreenRoute ||
                        currentRoute == null) {
                      navigator.pop();
                    } else {
                      navigator.pop();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (navigator.canPop()) {
                          navigator.pushReplacementNamed(homeScreenRoute);
                        } else {
                          navigator.pushNamed(homeScreenRoute);
                        }
                      });
                    }
                  },
                ),
                _DrawerItem(
                  icon: Icons.person,
                  label: "Perfil",
                  isActive: currentRoute == userInfoScreenRoute,
                  onTap: () {
                    final navigator = Navigator.of(context);
                    navigator.pop();
                    if (currentRoute != userInfoScreenRoute) {
                      Future.microtask(() {
                        navigator.pushReplacementNamed(userInfoScreenRoute);
                      });
                    }
                  },
                ),
                _DrawerItem(
                  icon: Icons.notifications,
                  label: "Avisos",
                  hasBadge: true,
                  isActive: currentRoute == muralScreenRoute,
                  onTap: () {
                    final navigator = Navigator.of(context);
                    navigator.pop();
                    if (currentRoute != muralScreenRoute) {
                      Future.microtask(() {
                        navigator.pushReplacementNamed(muralScreenRoute);
                      });
                    }
                  },
                ),
                _DrawerItem(
                  icon: Icons.calendar_today,
                  label: "Reservas",
                  isActive: currentRoute == reservasScreenRoute,
                  onTap: () {
                    final navigator = Navigator.of(context);
                    navigator.pop();
                    if (currentRoute != reservasScreenRoute) {
                      Future.microtask(() {
                        navigator.pushReplacementNamed(reservasScreenRoute);
                      });
                    }
                  },
                ),
                _DrawerItem(
                  icon: Icons.security,
                  label: "Privacidade",
                  isActive: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PrivacyScreen()),
                    );
                  },
                ),
                if (isAdmin || canManageBills) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 16, 0, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "GERENCIAMENTO",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: blackColor40,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
                if (isAdmin) ...[
                  _DrawerItem(
                    icon: Icons.person_add,
                    label: "Gestão de Usuários",
                    isActive: currentRoute == accessManagementScreenRoute,
                    onTap: () {
                      final navigator = Navigator.of(context);
                      navigator.pop();
                      if (currentRoute != accessManagementScreenRoute) {
                        Future.microtask(() {
                          navigator.pushReplacementNamed(
                              accessManagementScreenRoute);
                        });
                      }
                    },
                  ),
                ],
                if (canManageBills) ...[
                  _DrawerItem(
                    icon: Icons.receipt_long,
                    label: "Gestão de Boletos",
                    isActive: currentRoute == residentsScreenRoute,
                    onTap: () {
                      final navigator = Navigator.of(context);
                      navigator.pop();
                      if (currentRoute != residentsScreenRoute) {
                        Future.microtask(() {
                          navigator.pushReplacementNamed(residentsScreenRoute);
                        });
                      }
                    },
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Botão Sair - Fixado no Rodapé
          const Divider(
              indent: 20,
              endIndent: 20,
              height: 1,
              thickness: 0.5,
              color: Color(0xFFEEEEEE)),

          ListTile(
            leading: const Icon(Icons.logout_outlined,
                color: Color(0xFFD32F2F), size: 22),
            dense: true, // Reduz altura do item para telas pequenas
            title: const Text(
              "Sair da Conta",
              style: TextStyle(
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            onTap: () => _confirmSignOut(context, ref),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "v2.6.0-premium",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
                Container(
                  width: 15,
                  height: 1.5,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
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
      // 1. Resetar navegação para voltar ao Início em futuros logins
      ref.read(navigationProvider.notifier).state = 0;

      // 2. Efetuar o logout no Firebase
      await ref.read(authRepositoryProvider).signOut();

      // 3. Forçar retorno imediato para a tela de login limpando a pilha
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool hasBadge;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isActive,
    this.hasBadge = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: isActive ? primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isActive ? Colors.white : const Color(0xFF616161),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFF616161),
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                if (hasBadge)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD32F2F),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

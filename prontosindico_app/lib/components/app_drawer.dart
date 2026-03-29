import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/constants.dart';
import 'package:prontosindico/domain/enums/user_role.dart';
import 'package:prontosindico/providers/auth_provider.dart';
import 'package:prontosindico/route/route_constants.dart';
import 'package:prontosindico/route/screen_export.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider).value;
    final isAdmin = userProfile?.role == UserRole.administrador;
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Final Premium Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
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
                            width: 54,
                            height: 54,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              "assets/logo/logo.png",
                              width: 54,
                              height: 54,
                            ),
                          )
                        : Image.asset(
                            "assets/logo/logo.png",
                            width: 54,
                            height: 54,
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userProfile?.name ?? "Pronto Síndico",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userProfile?.email ?? "sindico@prontosindico.com",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
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
            isActive: currentRoute == homeScreenRoute || currentRoute == null,
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != homeScreenRoute) {
                Navigator.pushReplacementNamed(context, homeScreenRoute);
              }
            },
          ),
          _DrawerItem(
            icon: Icons.person,
            label: "Perfil",
            isActive: currentRoute == profileScreenRoute,
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != profileScreenRoute) {
                Navigator.pushReplacementNamed(context, profileScreenRoute);
              }
            },
          ),
          _DrawerItem(
            icon: Icons.notifications,
            label: "Avisos",
            hasBadge: true,
            isActive: currentRoute == muralScreenRoute,
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != muralScreenRoute) {
                Navigator.pushReplacementNamed(context, muralScreenRoute);
              }
            },
          ),
          _DrawerItem(
            icon: Icons.calendar_today,
            label: "Reservas",
            isActive: currentRoute == reservasScreenRoute,
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != reservasScreenRoute) {
                Navigator.pushReplacementNamed(context, reservasScreenRoute);
              }
            },
          ),

          if (isAdmin) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 0, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "GERENCIAMENTO",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: blackColor40,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            _DrawerItem(
              icon: Icons.person_add,
              label: "Gestão de Usuários",
              isActive: currentRoute == accessManagementScreenRoute,
              onTap: () {
                Navigator.pop(context);
                if (currentRoute != accessManagementScreenRoute) {
                  Navigator.pushReplacementNamed(
                      context, accessManagementScreenRoute);
                }
              },
            ),
          ],

          const Spacer(),
          
          const Divider(indent: 20, endIndent: 20, height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),

          ListTile(
            leading: const Icon(Icons.logout_outlined, color: Color(0xFFD32F2F)),
            title: const Text(
              "Sair da Conta",
              style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w600),
            ),
            onTap: () => _confirmSignOut(context, ref),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "v2.6.0-premium",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
                Container(
                  width: 20,
                  height: 2,
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
      await ref.read(authRepositoryProvider).signOut();
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

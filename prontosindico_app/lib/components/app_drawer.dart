import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prontosindico/constants.dart';
import 'package:prontosindico/providers/auth_provider.dart';
import 'package:prontosindico/route/route_constants.dart';
import 'package:prontosindico/route/screen_export.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Para simplificar, usamos o mesmo mecanismo do ProfileScreen ou observamos o authRepository
    // Aqui vamos buscar o usuário atual do Firebase Auth para checar a role no BD
    // Mas para ser mais eficiente com Riverpod, poderíamos ter um roleProvider.
    // Por enquanto, vamos usar uma lógica similar à do ProfileScreen buscando do banco.

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: primaryColor),
            accountName: const Text("Pronto Síndico"),
            accountEmail: const Text("Administração"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset("assets/logo/logo.png"),
              ),
            ),
          ),
          ListTile(
            leading: SvgPicture.asset(
              "assets/icons/ProntoSindico.svg",
              height: 24,
              colorFilter:
                  const ColorFilter.mode(primaryColor, BlendMode.srcIn),
            ),
            title: const Text("Início"),
            onTap: () => Navigator.pop(context),
          ),
          // Itens de Gerenciamento (Apenas para Admin)
          // Nota: Seria melhor usar um provider para _isAdmin, mas vamos seguir o fluxo atual
          _AdminMenuSection(),

          const Spacer(),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: errorColor),
            title: const Text(
              "Sair da Conta",
              style: TextStyle(color: errorColor),
            ),
            onTap: () => _confirmSignOut(context, ref),
          ),
          const SizedBox(height: defaultPadding),
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

class _AdminMenuSection extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AdminMenuSection> createState() => _AdminMenuSectionState();
}

class _AdminMenuSectionState extends ConsumerState<_AdminMenuSection> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    // Reutilizando a lógica de busca de role
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final dbRef = FirebaseDatabase.instance.ref('usuarios/${user.uid}');
      final snapshot = await dbRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map?;
        if (mounted) {
          setState(() {
            _isAdmin = (data?['role'] as String?) == 'administrador';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) return const SizedBox.shrink();

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.people_outline, color: primaryColor),
          title: const Text("Gestão de Usuários"),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, accessManagementScreenRoute);
          },
        ),
        ListTile(
          leading: const Icon(Icons.bar_chart, color: primaryColor),
          title: const Text("Relatório Financeiro"),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, financialReportScreenRoute);
          },
        ),
        ListTile(
          leading: const Icon(Icons.home_work_outlined, color: primaryColor),
          title: const Text("Gerenciar Moradores"),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, residentsScreenRoute);
          },
        ),
      ],
    );
  }
}

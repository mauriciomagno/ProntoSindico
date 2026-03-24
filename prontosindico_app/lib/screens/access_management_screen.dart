import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:prontosindico/components/role_based_wrapper.dart';
import 'package:prontosindico/constants.dart';

class AccessManagementScreen extends StatelessWidget {
  const AccessManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleBasedWrapper(
      requiredRole: 'administrador',
      child: _AccessManagementView(),
    );
  }
}

class _AccessManagementView extends StatefulWidget {
  const _AccessManagementView();

  @override
  State<_AccessManagementView> createState() => _AccessManagementViewState();
}

class _AccessManagementViewState extends State<_AccessManagementView> {
  final DatabaseReference _usuariosRef = FirebaseDatabase.instance.ref('usuarios');
  bool? _filtroAtivo;
  String _searchQuery = '';

  Future<void> _toggleAtivo(String userId, bool novoValue) async {
    await _usuariosRef.child(userId).update({'Ativo': novoValue ? 'Sim' : 'Nao'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLightColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gestao de Usuarios',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: _filtroAtivo != null ? secondaryColor : primaryColor),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: blackColor10),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                  decoration: const InputDecoration(
                    hintText: 'Buscar usuario...',
                    hintStyle: TextStyle(fontSize: 14, color: blackColor20),
                    icon: Icon(Icons.search, color: blackColor20, size: 20),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: _usuariosRef.onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                    return const Center(child: Text('Nenhum usuario encontrado.'));
                  }

                  final rawMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  var usuarios = rawMap.entries.map((e) {
                    final dados = Map<String, dynamic>.from(e.value as Map<dynamic, dynamic>);
                    dados['_uid'] = e.key as String;
                    return dados;
                  }).toList();

                  // Filters
                  if (_filtroAtivo != null) {
                    usuarios = usuarios.where((u) => _filtroAtivo! ? u['Ativo'] == 'Sim' : u['Ativo'] != 'Sim').toList();
                  }
                  if (_searchQuery.isNotEmpty) {
                    usuarios = usuarios.where((u) {
                      final nome = (u['nome'] as String? ?? '').toLowerCase();
                      final email = (u['email'] as String? ?? '').toLowerCase();
                      return nome.contains(_searchQuery) || email.contains(_searchQuery);
                    }).toList();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                    itemCount: usuarios.length,
                    itemBuilder: (context, index) {
                      final user = usuarios[index];
                      return _buildUserCard(user).animate().fadeIn(delay: (index * 50).ms);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filtrar por Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.group, color: blackColor40),
              title: const Text('Todos'),
              trailing: _filtroAtivo == null ? const Icon(Icons.check, color: secondaryColor) : null,
              onTap: () {
                setState(() => _filtroAtivo = null);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: successColor),
              title: const Text('Ativos'),
              trailing: _filtroAtivo == true ? const Icon(Icons.check, color: secondaryColor) : null,
              onTap: () {
                setState(() => _filtroAtivo = true);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: errorColor),
              title: const Text('Inativos'),
              trailing: _filtroAtivo == false ? const Icon(Icons.check, color: secondaryColor) : null,
              onTap: () {
                setState(() => _filtroAtivo = false);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final String uid = user['_uid'];
    final bool isAtivo = user['Ativo'] == 'Sim';
    final String nome = user['nome'] ?? 'Sem Nome';
    final String email = user['email'] ?? 'Sem E-mail';
    final String role = (user['role'] ?? 'morador').toString().toUpperCase();
    final String? fotoUrl = user['Foto'];

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: blackColor10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: blackColor10,
                  backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty) ? NetworkImage(fotoUrl) : null,
                  child: (fotoUrl == null || fotoUrl.isEmpty) ? Text(nome[0].toUpperCase(), style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(nome, style: const TextStyle(fontWeight: FontWeight.bold, color: blackColor80, fontSize: 15)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(role, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: primaryColor)),
                          ),
                        ],
                      ),
                      Text(email, style: const TextStyle(fontSize: 12, color: blackColor40)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Usuario Ativo', style: TextStyle(fontSize: 13, color: blackColor60)),
                Switch.adaptive(
                  value: isAtivo,
                  activeColor: successColor,
                  onChanged: (value) => _confirmToggle(uid, nome, isAtivo),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmToggle(String uid, String nome, bool currentIsAtivo) {
    final action = currentIsAtivo ? 'DESATIVAR' : 'ATIVAR';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action usuario?'),
        content: Text('Tem certeza que deseja $action o acesso de $nome?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () {
              _toggleAtivo(uid, !currentIsAtivo);
              Navigator.pop(context);
            },
            child: Text(action, style: TextStyle(color: currentIsAtivo ? errorColor : successColor)),
          ),
        ],
      ),
    );
  }
}

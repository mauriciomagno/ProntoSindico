import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final DatabaseReference _usuariosRef =
      FirebaseDatabase.instance.ref('usuarios');

  /// Filtro de status: null = todos, true = apenas ativos, false = apenas inativos.
  bool? _filtroAtivo;

  Future<void> _toggleAtivo(String userId, bool novoValor) async {
    await _usuariosRef
        .child(userId)
        .update({'Ativo': novoValor ? 'Sim' : 'Não'});
  }

  Future<void> _confirmarToggle(
    BuildContext context,
    String userId,
    String nome,
    bool atualmenteAtivo,
  ) async {
    final acao = atualmenteAtivo ? 'desativar' : 'ativar';
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${acao[0].toUpperCase()}${acao.substring(1)} usuário'),
        content: Text('Deseja $acao o acesso de "$nome"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: atualmenteAtivo ? errorColor : Colors.green,
            ),
            child: Text(acao[0].toUpperCase() + acao.substring(1)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _toggleAtivo(userId, !atualmenteAtivo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Usuários"),
        actions: [
          PopupMenuButton<bool?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar por status',
            initialValue: _filtroAtivo,
            onSelected: (value) => setState(() => _filtroAtivo = value),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: null,
                child: Row(
                  children: [
                    Icon(Icons.group,
                        color: _filtroAtivo == null ? primaryColor : null,
                        size: 20),
                    const SizedBox(width: 8),
                    const Text('Todos'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: true,
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: _filtroAtivo == true ? Colors.green : null,
                        size: 20),
                    const SizedBox(width: 8),
                    const Text('Apenas ativos'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: false,
                child: Row(
                  children: [
                    Icon(Icons.cancel,
                        color: _filtroAtivo == false ? errorColor : null,
                        size: 20),
                    const SizedBox(width: 8),
                    const Text('Apenas inativos'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _usuariosRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Erro ao carregar usuários.'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text('Nenhum usuário encontrado.'));
          }

          final rawMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          var usuarios = rawMap.entries.map((e) {
            final dados =
                Map<String, dynamic>.from(e.value as Map<dynamic, dynamic>);
            dados['_uid'] = e.key as String;
            return dados;
          }).toList();

          if (_filtroAtivo != null) {
            usuarios = usuarios
                .where((u) =>
                    _filtroAtivo! ? u['Ativo'] == 'Sim' : u['Ativo'] != 'Sim')
                .toList();
          }

          // Inativos primeiro; depois por nome
          usuarios.sort((a, b) {
            final aAtivo = a['Ativo'] == 'Sim';
            final bAtivo = b['Ativo'] == 'Sim';
            if (aAtivo != bAtivo) return aAtivo ? 1 : -1;
            final nomeA = (a['nome'] as String? ?? '').toLowerCase();
            final nomeB = (b['nome'] as String? ?? '').toLowerCase();
            return nomeA.compareTo(nomeB);
          });

          if (usuarios.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 64, color: Colors.green.shade400),
                  const SizedBox(height: 12),
                  Text(
                    _filtroAtivo == false
                        ? 'Nenhum usuário inativo.'
                        : _filtroAtivo == true
                            ? 'Nenhum usuário ativo.'
                            : 'Nenhum usuário cadastrado.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(
                vertical: defaultPadding, horizontal: defaultPadding / 2),
            itemCount: usuarios.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: defaultPadding / 2),
            itemBuilder: (context, index) {
              final user = usuarios[index];
              final String uid = user['_uid'] as String;
              final bool isAtivo = user['Ativo'] == 'Sim';
              final String nome =
                  (user['nome'] as String?) ?? 'Nome não informado';
              final String email =
                  (user['email'] as String?) ?? 'E-mail não informado';
              final String role = (user['role'] as String?) ?? 'morador';
              final String? fotoUrl = user['Foto'] as String?;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isAtivo
                        ? Colors.transparent
                        : errorColor.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding, vertical: defaultPadding / 2),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty)
                        ? NetworkImage(fotoUrl)
                        : null,
                    child: (fotoUrl == null || fotoUrl.isEmpty)
                        ? Text(
                            nome.isNotEmpty ? nome[0].toUpperCase() : '?',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  title: Text(nome),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(email, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _RoleChip(role: role),
                          const Spacer(),
                          Text(
                            isAtivo ? 'Ativo' : 'Inativo',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isAtivo ? Colors.green : errorColor,
                            ),
                          ),
                          Transform.scale(
                            scale: 0.8,
                            child: Switch.adaptive(
                              value: isAtivo,
                              activeTrackColor: Colors.green,
                              inactiveThumbColor: errorColor,
                              onChanged: (_) =>
                                  _confirmarToggle(context, uid, nome, isAtivo),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: SvgPicture.asset(
                    "assets/icons/miniRight.svg",
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).iconTheme.color!.withValues(alpha: 0.4),
                      BlendMode.srcIn,
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});

  final String role;

  Color _cor() {
    switch (role) {
      case 'administrador':
        return Colors.deepPurple;
      case 'sindico':
        return primaryColor;
      case 'funcionario':
        return Colors.orange.shade700;
      case 'portaria':
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _cor().withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cor().withValues(alpha: 0.4)),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 11,
          color: _cor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

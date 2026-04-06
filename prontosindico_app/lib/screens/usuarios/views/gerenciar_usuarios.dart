import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:prontosindico/constants.dart';
import 'package:prontosindico/screens/home/menu_lateral.dart';
import 'package:prontosindico/components/role_based_wrapper.dart';

class AccessManagementScreen extends ConsumerWidget {
  const AccessManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const RoleBasedWrapper(
      requiredRole: 'administrador',
      child: _AccessManagementView(),
    );
  }
}

class _AccessManagementView extends ConsumerStatefulWidget {
  const _AccessManagementView();

  @override
  ConsumerState<_AccessManagementView> createState() =>
      _AccessManagementViewState();
}

class _AccessManagementViewState extends ConsumerState<_AccessManagementView> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  String _searchQuery = '';
  late Stream<List<Map<String, dynamic>>> _usersStream;
  final TextEditingController _searchController = TextEditingController();

  // Rastreamento de alterações pendentes
  final Map<String, Map<String, dynamic>> _pendingChanges = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _usersStream = _watchDetailedUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<List<Map<String, dynamic>>> _watchDetailedUsers() {
    final uStream = _dbRef.child('usuarios').onValue;
    final mStream = _dbRef.child('moradores').onValue;

    return Rx.combineLatest2<DatabaseEvent, DatabaseEvent,
        List<Map<String, dynamic>>>(
      uStream,
      mStream,
      (uEvent, mEvent) {
        final List<Map<String, dynamic>> results = [];
        final uSnapshot = uEvent.snapshot;
        final mSnapshot = mEvent.snapshot;

        if (!uSnapshot.exists) return results;

        final Map<String, String> userToApto = {};
        if (mSnapshot.exists) {
          for (final mChild in mSnapshot.children) {
            final mData = mChild.value as Map?;
            if (mData != null) {
              final uId = mData['usuarioId']?.toString();
              final apto = mData['apartamento']?.toString();
              if (uId != null && apto != null) {
                userToApto[uId] = "Unidade $apto";
              }
            }
          }
        }

        for (final uChild in uSnapshot.children) {
          final uData = uChild.value as Map?;
          if (uData != null) {
            final userMap = Map<String, dynamic>.from(uData);
            final id = uChild.key.toString();
            userMap['_uid'] = id;
            userMap['apartamento'] = userToApto[id];
            results.add(userMap);
          }
        }
        return results;
      },
    );
  }

  void _toggleAtivo(String userId, bool novoValue) {
    setState(() {
      if (!_pendingChanges.containsKey(userId)) {
        _pendingChanges[userId] = {};
      }
      _pendingChanges[userId]!['ativo'] = novoValue;
    });
  }

  void _updateRole(String userId, String novoRole) {
    setState(() {
      if (!_pendingChanges.containsKey(userId)) {
        _pendingChanges[userId] = {};
      }
      _pendingChanges[userId]!['role'] = novoRole;
    });
  }

  Future<void> _saveAllChanges() async {
    if (_pendingChanges.isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Salvar todas as alterações no Firebase
      for (final entry in _pendingChanges.entries) {
        final userId = entry.key;
        final changes = entry.value;
        await _dbRef.child('usuarios/$userId').update(changes);
      }

      // Limpar alterações pendentes após salvar com sucesso
      setState(() {
        _pendingChanges.clear();
        _isSaving = false;
      });

      // Mostrar mensagem de sucesso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alterações salvas com sucesso!'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar alterações: $e'),
            backgroundColor: Color(0xFFEF4444),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.light,
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: Color(0xFF94A3B8)),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        drawer: const AppDrawer(),
        floatingActionButton: _pendingChanges.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: _isSaving ? null : _saveAllChanges,
                backgroundColor: const Color(0xFF0369A1),
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  _isSaving
                      ? 'Salvando...'
                      : 'Salvar (${_pendingChanges.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _usersStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }

            final allUsers = snapshot.data ?? [];
            final filteredUsers = allUsers.where((u) {
              final query = _searchQuery.toLowerCase();
              final nome = (u['nome'] ?? '').toString().toLowerCase();
              final email = (u['email'] ?? '').toString().toLowerCase();
              final apto = (u['apartamento'] ?? '').toString().toLowerCase();
              return nome.contains(query) ||
                  email.contains(query) ||
                  apto.contains(query);
            }).toList();

            final int totalMoradores = allUsers.length;
            final int ativos = allUsers.where((u) => u['ativo'] == true).length;
            final int pendentes =
                allUsers.where((u) => u['ativo'] == false).length;

            return Column(
              children: [
                // Cabeçalho fixo (congelado) - apenas título, descrição e busca
                Container(
                  color: const Color(0xFFF8FAFC),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Builder(
                              builder: (ctx) => IconButton(
                                icon:
                                    const Icon(Icons.menu, color: primaryColor),
                                onPressed: () => Scaffold.of(ctx).openDrawer(),
                              ),
                            ),
                            const Expanded(
                              child: Text(
                                "Gestão de Usuários",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Gerencie o acesso de moradores e atribuições de unidades em todo o complexo.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: const TextStyle(
                                color: Color(0xFF1E293B), fontSize: 15),
                            decoration: const InputDecoration(
                              icon: Icon(Icons.search,
                                  color: Color(0xFF94A3B8), size: 22),
                              hintText: "Buscar por nome ou unidade...",
                              hintStyle: TextStyle(
                                  color: Color(0xFF94A3B8), fontSize: 14),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Lista rolável com estatísticas e usuários
                Expanded(
                  child: filteredUsers.isEmpty
                      ? SingleChildScrollView(
                          child: Column(
                            children: [
                              // Cards de estatísticas
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 16, 20, 0),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildStatCard(
                                        "TOTAL DE MORADORES",
                                        totalMoradores.toString(),
                                        "+12 este mês",
                                        Icons.group,
                                        const Color(0xFFE0F2FE),
                                        const Color(0xFF0EA5E9),
                                      ),
                                      const SizedBox(width: 12),
                                      _buildStatCard(
                                        "UNIDADES ATIVAS",
                                        "$ativos / $totalMoradores",
                                        "${totalMoradores > 0 ? (ativos / totalMoradores * 100).toInt() : 0}% de Ocupação",
                                        Icons.business,
                                        const Color(0xFFECFDF5),
                                        const Color(0xFF10B981),
                                      ),
                                      const SizedBox(width: 12),
                                      _buildStatCard(
                                        "ACESSOS PENDENTES",
                                        pendentes.toString().padLeft(2, '0'),
                                        "Requer aprovação",
                                        Icons.person_add,
                                        const Color(0xFFFEF2F2),
                                        const Color(0xFFEF4444),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Mensagem de nenhum usuário
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person_off_outlined,
                                          size: 64, color: Colors.grey[300]),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "Nenhum usuário encontrado.",
                                        style: TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: filteredUsers.length +
                              1, // +1 para os cards de estatísticas
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // Primeiro item: cards de estatísticas
                              return Padding(
                                padding:
                                    const EdgeInsets.only(top: 16, bottom: 20),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildStatCard(
                                        "TOTAL DE MORADORES",
                                        totalMoradores.toString(),
                                        "+12 este mês",
                                        Icons.group,
                                        const Color(0xFFE0F2FE),
                                        const Color(0xFF0EA5E9),
                                      ),
                                      const SizedBox(width: 12),
                                      _buildStatCard(
                                        "UNIDADES ATIVAS",
                                        "$ativos / $totalMoradores",
                                        "${totalMoradores > 0 ? (ativos / totalMoradores * 100).toInt() : 0}% de Ocupação",
                                        Icons.business,
                                        const Color(0xFFECFDF5),
                                        const Color(0xFF10B981),
                                      ),
                                      const SizedBox(width: 12),
                                      _buildStatCard(
                                        "ACESSOS PENDENTES",
                                        pendentes.toString().padLeft(2, '0'),
                                        "Requer aprovação",
                                        Icons.person_add,
                                        const Color(0xFFFEF2F2),
                                        const Color(0xFFEF4444),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            // Demais itens: cards de usuários
                            return _buildUserCard(filteredUsers[index - 1]);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String sub, IconData icon,
      Color bgIcon, Color iconColor) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration:
                    BoxDecoration(color: bgIcon, shape: BoxShape.circle),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(sub,
              style: TextStyle(
                  fontSize: 10, color: iconColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final String userId = user['_uid'];

    // Aplicar alterações pendentes aos dados do usuário
    final bool isAtivo =
        _pendingChanges[userId]?['ativo'] ?? user['ativo'] == true;
    final String nome = user['nome'] ?? 'Sem Nome';
    final String email = user['email'] ?? 'Sem E-mail';
    final String? apto = user['apartamento'];
    final String? fotoUrl = user['Foto'];
    final String role =
        _pendingChanges[userId]?['role'] ?? user['role'] ?? 'morador';

    // Verificar se este usuário tem alterações pendentes
    final bool hasChanges = _pendingChanges.containsKey(userId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: hasChanges
            ? Border.all(color: const Color(0xFF0369A1), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (hasChanges)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFDCEEFB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.edit, size: 14, color: Color(0xFF0369A1)),
                  SizedBox(width: 6),
                  Text(
                    'Alterações pendentes',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0369A1),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFF1F5F9),
                backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty)
                    ? NetworkImage(fotoUrl)
                    : null,
                child: (fotoUrl == null || fotoUrl.isEmpty)
                    ? Text(nome[0].toUpperCase(),
                        style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20))
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nome,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B))),
                    const SizedBox(height: 2),
                    Text(email,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (apto != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    apto,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569)),
                  ),
                ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isAtivo
                      ? const Color(0xFFCCFBF1)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isAtivo ? "ATIVO" : "INATIVO",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isAtivo
                        ? const Color(0xFF0D9488)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                "Função:",
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButton<String>(
                    value: role,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Color(0xFF64748B)),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A)),
                    dropdownColor: Colors.white,
                    items: const [
                      DropdownMenuItem(
                        value: 'administrador',
                        child: Text('Administrador'),
                      ),
                      DropdownMenuItem(
                        value: 'morador',
                        child: Text('Morador'),
                      ),
                      DropdownMenuItem(
                        value: 'tesoureiro',
                        child: Text('Tesoureiro'),
                      ),
                    ],
                    onChanged: (String? newRole) {
                      if (newRole != null && newRole != role) {
                        _updateRole(userId, newRole);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Desativar",
                style: TextStyle(
                    fontSize: 12,
                    color: !isAtivo
                        ? const Color(0xFF1E293B)
                        : const Color(0xFF64748B),
                    fontWeight: !isAtivo ? FontWeight.w600 : FontWeight.normal),
              ),
              const SizedBox(width: 12),
              Switch.adaptive(
                value: isAtivo,
                thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF0369A1);
                  }
                  return Colors.white;
                }),
                trackColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF0369A1).withOpacity(0.2);
                  }
                  return Colors.grey.withOpacity(0.3);
                }),
                onChanged: (v) => _toggleAtivo(user['_uid'], v),
              ),
              const SizedBox(width: 12),
              Text(
                "Ativar",
                style: TextStyle(
                    fontSize: 12,
                    color: isAtivo
                        ? const Color(0xFF0369A1)
                        : const Color(0xFF64748B),
                    fontWeight: isAtivo ? FontWeight.w600 : FontWeight.normal),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

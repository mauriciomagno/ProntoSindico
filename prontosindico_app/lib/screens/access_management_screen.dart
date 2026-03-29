import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:prontosindico/constants.dart';
import 'package:prontosindico/components/app_drawer.dart';
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
  ConsumerState<_AccessManagementView> createState() => _AccessManagementViewState();
}

class _AccessManagementViewState extends ConsumerState<_AccessManagementView> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  String _searchQuery = '';

  Stream<List<Map<String, dynamic>>> _watchDetailedUsers() {
    final usuariosStream = _dbRef.child('usuarios').onValue;
    final moradoresStream = _dbRef.child('moradores').onValue;

    return CombineLatestStream.combine2(usuariosStream, moradoresStream, (uEvent, mEvent) {
      final uData = uEvent.snapshot.value as Map? ?? {};
      final mData = mEvent.snapshot.value as Map? ?? {};

      final List<Map<String, dynamic>> results = [];
      uData.forEach((uid, userData) {
        if (userData is Map) {
          final userMap = Map<String, dynamic>.from(userData);
          userMap['_uid'] = uid.toString();
          
          // Buscar apartamento em moradores
          String? apartamento;
          mData.forEach((mId, moradorData) {
            if (moradorData is Map && moradorData['usuarioId'] == uid) {
              apartamento = moradorData['apartamento']?.toString();
            }
          });
          userMap['apartamento'] = apartamento;
          results.add(userMap);
        }
      });
      return results;
    });
  }

  Future<void> _toggleAtivo(String userId, bool novoValue) async {
    await _dbRef.child('usuarios/$userId').update({
      'ativo': novoValue,
      'Ativo': novoValue ? 'Sim' : 'Nao',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const AppDrawer(),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _watchDetailedUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final allUsers = snapshot.data ?? [];
          final filteredUsers = allUsers.where((u) {
            final query = _searchQuery.toLowerCase();
            final nome = (u['nome'] ?? '').toString().toLowerCase();
            final email = (u['email'] ?? '').toString().toLowerCase();
            final apto = (u['apartamento'] ?? '').toString().toLowerCase();
            return nome.contains(query) || email.contains(query) || apto.contains(query);
          }).toList();

          final int totalMoradores = allUsers.length;
          final int ativos = allUsers.where((u) => u['ativo'] == true || u['Ativo'] == 'Sim').length;
          final int pendentes = allUsers.where((u) => u['ativo'] == false || u['Ativo'] == 'Nao').length;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Gestão de Usuários",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Builder(
                            builder: (ctx) => IconButton(
                              icon: const Icon(Icons.menu, color: primaryColor),
                              onPressed: () => Scaffold.of(ctx).openDrawer(),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: const InputDecoration(
                            icon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                            hintText: "Buscar por nome ou unidade...",
                            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SingleChildScrollView(
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
                              "${totalMoradores > 0 ? (ativos/totalMoradores*100).toInt() : 0}% de Ocupação",
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
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildUserCard(filteredUsers[index]);
                    },
                    childCount: filteredUsers.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryColor,
        child: const Icon(Icons.person_add_alt_1, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String sub, IconData icon, Color bgIcon, Color iconColor) {
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
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: bgIcon, shape: BoxShape.circle),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(fontSize: 10, color: iconColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final bool isAtivo = user['ativo'] == true || user['Ativo'] == 'Sim';
    final String nome = user['nome'] ?? 'Sem Nome';
    final String email = user['email'] ?? 'Sem E-mail';
    final String? apto = user['apartamento'];
    final String? fotoUrl = user['Foto'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFF1F5F9),
                backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty) ? NetworkImage(fotoUrl) : null,
                child: (fotoUrl == null || fotoUrl.isEmpty) ? Text(nome[0].toUpperCase(), style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nome, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                    Text(email, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isAtivo ? const Color(0xFFE0F7FA) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isAtivo ? "ATIVO" : "INATIVO",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isAtivo ? const Color(0xFF00ACC1) : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (apto != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    apto,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
                  ),
                ),
                const Spacer(),
              ],
              Text(
                isAtivo ? "Ativar" : "Desativar",
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: isAtivo,
                activeColor: const Color(0xFF0369A1),
                onChanged: (v) => _toggleAtivo(user['_uid'], v),
              ),
              const SizedBox(width: 8),
              const Text(
                "Ativar",
                style: TextStyle(fontSize: 12, color: Color(0xFF0369A1), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

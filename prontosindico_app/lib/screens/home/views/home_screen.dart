import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/screens/home/menu_lateral.dart';
import 'package:prontosindico/domain/entities/comunicado.dart';
import 'package:prontosindico/domain/entities/mural_aviso.dart';
import 'package:prontosindico/domain/enums/user_role.dart';
import 'package:prontosindico/providers/auth_provider.dart';
import 'package:prontosindico/providers/communication_providers.dart';
import 'package:prontosindico/providers/navigation_provider.dart';
import 'package:prontosindico/route/route_constants.dart';
import 'package:prontosindico/screens/home/controllers/home_stats_controller.dart';
import 'package:prontosindico/screens/home/views/create_comunicado_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider).valueOrNull;
    final role = userProfile?.role ?? UserRole.morador;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Cabeçalho fixo (congelado)
          Container(
            color: const Color(0xFFF8FAFC),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (ctx) => IconButton(
                          icon:
                              const Icon(Icons.menu, color: Color(0xFF0F172A)),
                          onPressed: () => Scaffold.of(ctx).openDrawer(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      const Text(
                        "ProntoSíndico",
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      InkWell(
                        onTap: () =>
                            Navigator.pushNamed(context, userInfoScreenRoute),
                        borderRadius: BorderRadius.circular(18),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFFE2E8F0),
                          backgroundImage: (userProfile?.photoUrl != null &&
                                  userProfile!.photoUrl!.isNotEmpty)
                              ? NetworkImage(userProfile.photoUrl!)
                              : null,
                          child: (userProfile?.photoUrl == null ||
                                  userProfile!.photoUrl!.isEmpty)
                              ? const Icon(Icons.person,
                                  color: Color(0xFF64748B), size: 18)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Welcome Text
                  Text(
                    'BEM-VINDO AO LAR',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[400],
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Olá, ${userProfile?.name.split(' ').first ?? 'usuário'}!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Edíficio Monet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Conteúdo rolável
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Próximo Boleto Card
                  _buildNextBillCard(),
                  const SizedBox(height: 20),
                  // Stats Card - Exibe apenas se houver boletos do mês atual
                  const _HomeStatsWidget(),

                  // Novos Avisos (Dinâmico + Clique para Navegação)
                  GestureDetector(
                    onTap: () {
                      // Descobre o índice da aba Avisos com base no perfil
                      int muralIndex = 1; // Padrão morador: Home, Avisos
                      if (role == UserRole.administrador ||
                          role == UserRole.sindico) {
                        muralIndex = 3; // Home, Usuários, Financeiro, Avisos
                      } else if (role == UserRole.tesoureiro) {
                        muralIndex = 2; // Home, Financeiro, Avisos
                      }
                      ref.read(navigationProvider.notifier).state = muralIndex;
                    },
                    child: ref.watch(muralAvisosProvider).when(
                          data: (avisos) => _buildNoticesCard(avisos),
                          loading: () => _buildNoticesCard([]),
                          error: (e, s) => _buildNoticesCard([]),
                        ),
                  ),

                  const SizedBox(height: 20),
                  // Último Comunicado (Dinâmico + Empty State)
                  ref.watch(comunicadosProvider).when(
                        data: (comunicados) {
                          if (comunicados.isEmpty) {
                            return _buildEmptyCommunication(context, ref);
                          }
                          final ultimo = comunicados.last;
                          return _buildLastCommunication(context, ref, ultimo);
                        },
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (e, s) => const SizedBox.shrink(),
                      ),
                ],
              ).animate().fadeIn(duration: 400.ms).moveY(begin: 10, end: 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextBillCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFDCEEFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: Color(0xFF0369A1),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Próximo Boleto',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'R\$ 1.240,00',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Vence em 65 Mai',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFCCFBF1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'PENDENTE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D9488),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticesCard(List<MuralAviso> avisos) {
    final count = avisos.length;
    final String lastTime =
        count > 0 ? (avisos.last.time ?? 'Recém postado') : 'Nenhum recente';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.campaign,
                  color: Color(0xFFDC2626),
                  size: 24,
                ),
              ),
              if (count > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Novos Avisos',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  count == 0
                      ? 'Tudo em dia'
                      : count < 10
                          ? '0$count Recentes'
                          : '$count Recentes',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  count > 0 ? 'Último $lastTime' : 'Sem novos avisos',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastCommunication(
      BuildContext context, WidgetRef ref, Comunicado comunicado) {
    final userProfile = ref.watch(userProfileProvider).valueOrNull;
    final bool canAddComunicado = userProfile != null &&
        (userProfile.role == UserRole.administrador ||
            userProfile.role == UserRole.sindico ||
            userProfile.role == UserRole.tesoureiro);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Último Comunicado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            TextButton.icon(
              onPressed: canAddComunicado
                  ? () => _createNewComunicado(context, ref)
                  : null,
              icon: Icon(
                Icons.add_circle_outline,
                size: 18,
                color: canAddComunicado ? const Color(0xFF1E40AF) : Colors.grey,
              ),
              label: Text(
                'Novo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color:
                      canAddComunicado ? const Color(0xFF1E40AF) : Colors.grey,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0369A1),
                Color(0xFF0284C7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (comunicado.author ?? 'COMUNICADO').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      comunicado.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      comunicado.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recentemente',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Ler mais',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCommunication(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider).valueOrNull;
    final bool canAddComunicado = userProfile != null &&
        (userProfile.role == UserRole.administrador ||
            userProfile.role == UserRole.sindico ||
            userProfile.role == UserRole.tesoureiro);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Último Comunicado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            TextButton.icon(
              onPressed: canAddComunicado
                  ? () => _createNewComunicado(context, ref)
                  : null,
              icon: Icon(
                Icons.add_circle_outline,
                size: 18,
                color: canAddComunicado ? const Color(0xFF1E40AF) : Colors.grey,
              ),
              label: Text(
                'Novo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color:
                      canAddComunicado ? const Color(0xFF1E40AF) : Colors.grey,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: const Column(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF94A3B8), size: 32),
              SizedBox(height: 12),
              Text(
                'Sem comunicados para exibir.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _createNewComunicado(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateComunicadoScreen()),
    );
  }
}

// Widget separado para gerenciar o stats card
class _HomeStatsWidget extends ConsumerStatefulWidget {
  const _HomeStatsWidget();

  @override
  ConsumerState<_HomeStatsWidget> createState() => _HomeStatsWidgetState();
}

class _HomeStatsWidgetState extends ConsumerState<_HomeStatsWidget> {
  @override
  void initState() {
    super.initState();
    // Inicializa o provider no initState para garantir que esteja pronto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(homeStatsControllerProvider);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usa um try-catch para lidar com provider não inicializado
    try {
      final homeStats = ref.watch(homeStatsControllerProvider);

      // Exibe o card se houver boletos (pagos ou pendentes) do mês atual
      if (homeStats.total == 0) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          _buildStatsCard(context, homeStats),
          const SizedBox(height: 20),
        ],
      );
    } catch (e) {
      // Se o provider não estiver inicializado, retorna widget vazio
      return const SizedBox.shrink();
    }
  }

  Widget _buildStatsCard(BuildContext context, HomeStatsState state) {
    final double percent = state.paidPercentage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 140,
                  width: 140,
                  child: CircularProgressIndicator(
                    value: state.isLoading ? null : (percent / 100),
                    strokeWidth: 12,
                    backgroundColor: const Color(0xFFF1F5F9),
                    color: const Color(0xFF0369A1),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${percent.toInt()}%',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const Text(
                      'PAGO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Pagos',
                value: state.paidCount.toString(),
                color: const Color(0xFF0369A1),
              ),
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFFF1F5F9),
              ),
              _StatItem(
                label: 'Pendentes',
                value: state.pendingCount.toString(),
                color: const Color(0xFFF59E0B),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

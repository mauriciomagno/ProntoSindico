import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:prontosindico/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/screens/home/menu_lateral.dart';
import 'package:prontosindico/providers/auth_provider.dart';
import 'package:prontosindico/providers/reserva_providers.dart';
import 'package:prontosindico/domain/entities/reserva.dart';
import 'package:prontosindico/domain/enums/user_role.dart';
import 'package:prontosindico/route/route_constants.dart';
import 'package:prontosindico/screens/reservas/views/create_area_comum_screen.dart';
import 'package:prontosindico/screens/reservas/views/make_reserva_screen.dart';

class ReservasScreen extends ConsumerWidget {
  const ReservasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider).valueOrNull;
    final areasAsync = ref.watch(areasComunsProvider);
    final reservasAsync = ref.watch(reservasStreamProvider);

    final bool canAddArea = userProfile != null &&
        (userProfile.role == UserRole.administrador ||
            userProfile.role == UserRole.sindico ||
            userProfile.role == UserRole.tesoureiro);

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
                    children: [
                      Builder(
                        builder: (ctx) => IconButton(
                          icon:
                              const Icon(Icons.menu, color: Color(0xFF0F172A)),
                          onPressed: () => Scaffold.of(ctx).openDrawer(),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          "Reservas",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      if (canAddArea)
                        TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CreateAreaComumScreen()),
                          ),
                          icon: const Icon(Icons.add_circle_outline,
                              size: 18, color: Color(0xFF1E40AF)),
                          label: const Text(
                            'Novo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E40AF),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
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
                  const SizedBox(height: 8),
                  const Text(
                    'Gerencie suas reservas de espaços comuns.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Conteúdo rolável
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // My Bookings Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Meus Agendamentos',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: blackColor80),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Ver Historico',
                            style:
                                TextStyle(fontSize: 12, color: primaryColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  reservasAsync.when(
                    data: (reservas) {
                      final minhasReservas = reservas
                          .where((r) => r.usuarioId == userProfile?.uid)
                          .toList();
                      if (minhasReservas.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('Você não possui reservas pendentes.',
                                style: TextStyle(
                                    color: blackColor40, fontSize: 13)),
                          ),
                        );
                      }
                      return Column(
                        children: minhasReservas.map((reserva) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildBookingCard(
                              context,
                              ref,
                              reserva: reserva,
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('Erro: $e')),
                  ),

                  const SizedBox(height: 24),

                  // Available Spaces Section
                  const Text(
                    'Espacos Disponiveis',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: blackColor80),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Encontre o local perfeito para seu evento.',
                    style: TextStyle(fontSize: 12, color: blackColor40),
                  ),
                  const SizedBox(height: 16),

                  areasAsync.when(
                    data: (areas) {
                      if (areas.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('Ainda não há espaços cadastrados.',
                                style: TextStyle(
                                    color: blackColor40, fontSize: 13)),
                          ),
                        );
                      }
                      return Column(
                        children: areas.map((area) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildSpaceItem(
                              context,
                              area: area,
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('Erro: $e')),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    WidgetRef ref, {
    required Reserva reserva,
  }) {
    final Color statusColor = reserva.status.toUpperCase() == 'CONFIRMADA'
        ? successColor
        : warningColor;

    // Simplistic icon mapping based on area name
    IconData icon = Icons.event;
    if (reserva.id?.contains('churrasqueira') ?? false) {
      icon = Icons.outdoor_grill;
    }
    if (reserva.id?.contains('tenis') ?? false) {
      icon = Icons.sports_tennis;
    }
    if (reserva.id?.contains('salao') ?? false) {
      icon = Icons.celebration;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: blackColor10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ideally we'd fetch the area name from areaId
                      Text("Reserva: ${reserva.horario}",
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: blackColor80)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 12, color: blackColor40),
                          const SizedBox(width: 4),
                          Text(reserva.data,
                              style: const TextStyle(
                                  fontSize: 11, color: blackColor40)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(reserva.status.toUpperCase(),
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (reserva.id != null) {
                        ref
                            .read(reservaRepositoryProvider)
                            .deleteReserva(reserva.id!);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: errorColor,
                      side: const BorderSide(color: blackColor10),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancelar',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: whiteColor,
                      foregroundColor: primaryColor,
                      elevation: 0,
                      side: const BorderSide(color: primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Detalhes',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpaceItem(BuildContext context, {required AreaComum area}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: blackColor10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              area.imagem,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(area.nome,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: blackColor80)),
                    Text("Capacidade: ${area.capacidade} pessoas",
                        style:
                            const TextStyle(fontSize: 12, color: blackColor40)),
                  ],
                ),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MakeReservaScreen(area: area),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.05),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_forward_ios,
                        size: 12, color: primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

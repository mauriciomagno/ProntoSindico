import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:prontosindico/constants.dart';

import 'package:prontosindico/components/app_drawer.dart';

class ReservasScreen extends StatelessWidget {
  const ReservasScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      IconButton(
                        icon: const Icon(Icons.notifications_none,
                            color: Color(0xFF0F172A)),
                        onPressed: () {},
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
                  _buildBookingCard(
                    context,
                    title: 'Churrasqueira',
                    time: '12 de Outubro - 12:00 - 18:00',
                    status: 'PENDENTE',
                    statusColor: warningColor,
                    icon: Icons.outdoor_grill,
                  ),
                  const SizedBox(height: defaultPadding),
                  _buildBookingCard(
                    context,
                    title: 'Quadra de Tenis',
                    time: '15 de Outubro - 09:00 - 10:30',
                    status: 'CONFIRMADO',
                    statusColor: successColor,
                    icon: Icons.sports_tennis,
                  ),
                  const SizedBox(height: defaultPadding * 2),

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

                  // Horizontal or Grid List of spaces
                  _buildSpaceItem(
                    context,
                    title: 'Salao de Festas',
                    imageUrl:
                        'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&q=80&w=400',
                  ),
                  const SizedBox(height: 16),
                  _buildSpaceItem(
                    context,
                    title: 'Churrasqueira Coberta',
                    imageUrl:
                        'https://images.unsplash.com/photo-1558603668-6570496b66f8?auto=format&fit=crop&q=80&w=400',
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
    BuildContext context, {
    required String title,
    required String time,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
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
                      Text(title,
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
                          Text(time,
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
                  child: Text(status,
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
                    onPressed: () {},
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

  Widget _buildSpaceItem(BuildContext context,
      {required String title, required String imageUrl}) {
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
              imageUrl,
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
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: blackColor80)),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.05),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_forward_ios,
                      size: 12, color: primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

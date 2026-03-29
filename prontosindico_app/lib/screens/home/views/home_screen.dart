import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/components/app_drawer.dart';
import 'package:prontosindico/constants.dart';
import 'package:prontosindico/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: backgroundLightColor,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: primaryColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Image.asset(
          'assets/logo/logo.png',
          height: 32,
          errorBuilder: (context, error, stackTrace) => Text("ProntoSindico",
              style:
                  TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: primaryColor),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: userProfile.maybeWhen(
              data: (user) => CircleAvatar(
                radius: 16,
                backgroundImage: (user?.photoUrl != null &&
                        user!.photoUrl!.isNotEmpty)
                    ? NetworkImage(user.photoUrl!)
                    : const NetworkImage(
                        'https://i.pravatar.cc/150?u=ProntoSindico'),
              ),
              orElse: () => const CircleAvatar(
                radius: 16,
                backgroundImage:
                    NetworkImage('https://i.pravatar.cc/150?u=ProntoSindico'),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BEM-VINDO AO LAR',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: blackColor40,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              userProfile.when(
                data: (user) => Text(
                  'Ola, ${user?.name.split(' ').first ?? 'usuário'}!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontFamily: grandisExtendedFont,
                  ),
                ),
                loading: () => const Text('Carregando...'),
                error: (_, __) => const Text('Ola!'),
              ),
              Text(
                'Condominio Skyline',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                  fontFamily: grandisExtendedFont,
                ),
              ),
              const SizedBox(height: 32),
              _buildReceiptCard(context),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Meus Avisos',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: blackColor40),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('ver todos',
                        style: TextStyle(fontSize: 12, color: primaryColor)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildRecentNotice(
                context,
                title: '03 Recentes',
                subtitle: 'Ultima ha 2 horas',
                icon: Icons.notifications_active,
                color: errorColor,
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),
        ),
      ),
    );
  }

  Widget _buildReceiptCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PROXIMO RECIBO',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: blackColor40)),
                    const SizedBox(height: 4),
                    const Text('R\$ 1.240,00',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor)),
                    const Text('Vence em 10 Mai',
                        style: TextStyle(fontSize: 12, color: blackColor40)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('PENDENTE',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: secondaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: CircularProgressIndicator(
                      value: 0.82,
                      strokeWidth: 10,
                      backgroundColor: blackColor10,
                      color: primaryColor,
                    ),
                  ),
                  const Text('82%',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Condominio Pago no Mes',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: blackColor60)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _buildAmountRow('Pago', 'R\$ 382.400,00', primaryColor),
            const SizedBox(height: 8),
            _buildAmountRow('Pendente', 'R\$ 22.120,00', secondaryColor),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Arrecadado',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: blackColor40)),
                Text('R\$ 404.520,00',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, String amount, Color color) {
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: blackColor60)),
        const Spacer(),
        Text(amount,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: blackColor80)),
      ],
    );
  }

  Widget _buildRecentNotice(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor, // Azul conforme solicitado
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'MANUTENÇÃO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.more_horiz, color: Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Manutenção Preventiva dos Elevadores',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Informamos que na próxima terça-feira (02/05), os elevadores do Bloco B passarão por limpeza técnica.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Postado há 2h',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Ler mais',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

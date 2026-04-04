import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/constants.dart';
import 'package:prontosindico/domain/entities/resident.dart';
import 'package:prontosindico/ui/features/residents/controllers/residents_controller.dart';
import 'package:prontosindico/components/app_drawer.dart';
import 'package:prontosindico/providers/auth_provider.dart';
import 'package:prontosindico/ui/features/home/controllers/home_stats_controller.dart';

class ResidentsScreen extends ConsumerWidget {
  const ResidentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _ResidentsView();
  }
}

class _ResidentsView extends ConsumerWidget {
  const _ResidentsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(residentsControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

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
                          "Gestão de Boletos",
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
                    'Gerencie o status de pagamento dos moradores.',
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
            child: _buildBody(context, ref, state, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    state,
    ColorScheme colorScheme,
  ) {
    final userProfile = ref.watch(userProfileProvider).valueOrNull;
    final canManageBills = userProfile?.role.name == 'administrador' ||
        userProfile?.role.name == 'tesoureiro';

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFDC2626)),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(residentsControllerProvider),
              child: const Text("Tentar Novamente"),
            ),
          ],
        ),
      );
    }

    final residents = state.residents;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botão Gerar Boletos - sempre visível para admin/tesoureiro
          if (canManageBills) ...[
            Consumer(
              builder: (context, ref, child) {
                final homeStats = ref.watch(homeStatsControllerProvider);
                return _GenerateBillsButton(homeStats: homeStats);
              },
            ),
            const SizedBox(height: 20),
          ],
          // Lista de moradores ou mensagem de vazio
          if (residents.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text("Nenhum morador encontrado."),
              ),
            )
          else
            ...residents.map((resident) => Padding(
                  padding: const EdgeInsets.only(bottom: defaultPadding),
                  child: _ResidentCard(resident: resident),
                )),
        ],
      ),
    );
  }
}

class _GenerateBillsButton extends ConsumerStatefulWidget {
  const _GenerateBillsButton({required this.homeStats});

  final HomeStatsState homeStats;

  @override
  ConsumerState<_GenerateBillsButton> createState() =>
      _GenerateBillsButtonState();
}

class _GenerateBillsButtonState extends ConsumerState<_GenerateBillsButton> {
  @override
  Widget build(BuildContext context) {
    final homeStats = widget.homeStats;

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'GESTÃO DE BOLETOS',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gerar Boletos Mensais',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cria boletos para todos os moradores ativos com referência ao mês atual e vencimento dia 10 do próximo mês.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: homeStats.isLoading
                    ? null
                    : () => _showGenerateBillsConfirmation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005EB8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  disabledBackgroundColor:
                      const Color(0xFF005EB8).withOpacity(0.6),
                ),
                child: homeStats.isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Gerando...',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                        ],
                      )
                    : const Text('Gerar Boletos Mensais',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showGenerateBillsConfirmation(BuildContext context) async {
    try {
      // Verifica se já existem boletos do mês atual
      // O notifier pode ser acessado diretamente sem inicializar o state
      final billsExist = await ref
          .read(homeStatsControllerProvider.notifier)
          .checkIfBillsExist();

      if (!mounted) return;

      if (billsExist) {
        // Se existir, mostra dialog perguntando se quer limpar e gerar novamente
        final shouldRegenerate = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Boletos Já Existem'),
              content: const Text(
                'Já existem boletos criados no mês atual. Deseja limpar os boletos existentes e gerar novamente?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Limpar e Gerar Novamente'),
                ),
              ],
            );
          },
        );

        if (shouldRegenerate == true) {
          await _generateBills(context, clearExisting: true);
        }
      } else {
        // Se não existir, mostra dialog de confirmação simples
        final shouldGenerate = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Gerar Boletos Mensais'),
              content: const Text(
                'Deseja gerar os boletos (mês atual, vencimento dia 10 do próximo mês) para todos os moradores ativos?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9),
                      foregroundColor: Colors.white),
                  child: const Text('Gerar Boletos'),
                ),
              ],
            );
          },
        );

        if (shouldGenerate == true) {
          await _generateBills(context, clearExisting: false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao verificar boletos: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  Future<void> _generateBills(BuildContext context,
      {required bool clearExisting}) async {
    try {
      // O notifier pode ser acessado diretamente sem inicializar o state
      await ref
          .read(homeStatsControllerProvider.notifier)
          .generateMonthlyBills(clearExisting: clearExisting);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(clearExisting
                ? 'Boletos limpos e gerados com sucesso!'
                : 'Boletos gerados com sucesso!'),
            backgroundColor: const Color(0xFF0D9488),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar boletos: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }
}

class _ResidentCard extends ConsumerWidget {
  const _ResidentCard({required this.resident});

  final Resident resident;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = resident.user;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: user.isActive
              ? const Color(0xFFF1F5F9)
              : const Color(0xFFDC2626).withOpacity(0.3),
          width: 1,
        ),
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          user.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.person,
                            color: Color(0xFF64748B),
                            size: 24,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.person,
                        color: Color(0xFF64748B),
                        size: 24,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            children: [
              _RoleChip(role: user.role.name),
              const SizedBox(width: 8),
              if (resident.apartment != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCEEFB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Unidade ${resident.apartment}",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF0369A1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: resident.hasPaid
                          ? const Color(0xFFCCFBF1)
                          : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      resident.hasPaid ? 'PAGO' : 'PENDENTE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: resident.hasPaid
                            ? const Color(0xFF0D9488)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Transform.scale(
                    scale: 0.85,
                    child: Switch.adaptive(
                      value: resident.hasPaid,
                      activeColor: const Color(0xFF0D9488),
                      inactiveThumbColor: const Color(0xFFDC2626),
                      onChanged: (value) {
                        if (resident.id != null) {
                          ref
                              .read(residentsControllerProvider.notifier)
                              .togglePaymentStatus(resident.id!, value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});

  final String role;

  Color _cor() {
    switch (role.toLowerCase()) {
      case 'administrador':
        return const Color(0xFF7C3AED);
      case 'tesoureiro':
        return const Color(0xFF0369A1);
      case 'morador':
        return const Color(0xFF059669);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _cor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
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

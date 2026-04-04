import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/components/app_drawer.dart';
import 'package:prontosindico/providers/auth_provider.dart';
import 'package:prontosindico/providers/resident_providers.dart';
import 'package:prontosindico/ui/features/home/controllers/home_stats_controller.dart';

class FinancialReportScreen extends ConsumerWidget {
  const FinancialReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final residentsAsync = ref.watch(residentsStreamProvider);
    final userProfile = ref.watch(userProfileProvider).valueOrNull;
    final canManageBills = userProfile?.role.name == 'administrador' ||
        userProfile?.role.name == 'tesoureiro';

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
                          "Relatório Financeiro",
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
                    'Fluxo de caixa e visão geral do condomínio.',
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
            child: residentsAsync.when(
              data: (residents) {
                final double totalRevenue = residents
                    .where((r) => r.hasPaid)
                    .fold(0.0, (prev, element) => prev + 1240.0);
                final double totalPending = residents
                    .where((r) => !r.hasPaid)
                    .fold(0.0, (prev, element) => prev + 1240.0);
                final recentPaid = residents.where((r) => r.hasPaid).toList()
                  ..sort((a, b) => (b.createdAt ?? DateTime(2000))
                      .compareTo(a.createdAt ?? DateTime(2000)));

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryDashboard(totalRevenue, totalPending),
                      const SizedBox(height: 32),
                      // Botão Gerar Boletos - apenas para admin/tesoureiro
                      if (canManageBills) ...[
                        Consumer(
                          builder: (context, ref, child) {
                            final homeStats =
                                ref.watch(homeStatsControllerProvider);
                            return _buildGenerateBillsButton(
                                context, ref, homeStats);
                          },
                        ),
                        const SizedBox(height: 32),
                      ],
                      const Text(
                        'RECEBIMENTOS RECENTES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (recentPaid.isEmpty)
                        const Center(
                            child: Text('Nenhum pagamento registrado.'))
                      else
                        ...recentPaid.take(5).map((r) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildTransactionItem(
                                title: 'Taxa: ${r.user.name}',
                                category: r.apartment ?? 'Unidade',
                                amount: 'R\$ 1.240,00',
                                date: r.createdAt != null
                                    ? '${r.createdAt!.day}/${r.createdAt!.month}/${r.createdAt!.year}'
                                    : 'Recente',
                                isExpense: false,
                              ),
                            )),
                    ],
                  ).animate().fadeIn(duration: 400.ms),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text('Erro ao carregar dados: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryDashboard(double revenue, double pending) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildValueCard(
                    'RECEITA ACUMULADA',
                    'R\$ ${revenue.toStringAsFixed(0)}',
                    const Color(0xFF10B981),
                    Icons.trending_up)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildValueCard(
                    'VALOR PENDENTE',
                    'R\$ ${pending.toStringAsFixed(0)}',
                    const Color(0xFFF59E0B),
                    Icons.access_time)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SALDO DISPONÍVEL',
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
              const SizedBox(height: 12),
              Text('R\$ ${(revenue).toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Total arrecadado no período atual',
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValueCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required String category,
    required String amount,
    required String date,
    required bool isExpense,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  isExpense ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isExpense
                  ? Icons.remove_circle_outline
                  : Icons.add_circle_outline,
              color:
                  isExpense ? const Color(0xFFEF4444) : const Color(0xFF10B981),
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text('UNIDADE $category - $date',
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color:
                  isExpense ? const Color(0xFFEF4444) : const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateBillsButton(
      BuildContext context, WidgetRef ref, HomeStatsState state) {
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
                onPressed: state.isLoading
                    ? null
                    : () => _showGenerateBillsConfirmation(context, ref),
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
                child: state.isLoading
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

  Future<void> _showGenerateBillsConfirmation(
      BuildContext context, WidgetRef ref) async {
    // O notifier pode ser acessado diretamente sem inicializar o state
    // Verifica se já existem boletos do mês atual
    final billsExist = await ref
        .read(homeStatsControllerProvider.notifier)
        .checkIfBillsExist();

    if (!context.mounted) return;

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
        await _generateBills(context, ref, clearExisting: true);
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
                  foregroundColor: Colors.white,
                ),
                child: const Text('Gerar Boletos'),
              ),
            ],
          );
        },
      );

      if (shouldGenerate == true) {
        await _generateBills(context, ref, clearExisting: false);
      }
    }
  }

  Future<void> _generateBills(BuildContext context, WidgetRef ref,
      {required bool clearExisting}) async {
    try {
      // O notifier pode ser acessado diretamente sem inicializar o state
      await ref
          .read(homeStatsControllerProvider.notifier)
          .generateMonthlyBills(clearExisting: clearExisting);

      if (context.mounted) {
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
      if (context.mounted) {
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

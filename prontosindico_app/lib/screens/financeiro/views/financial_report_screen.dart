import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/components/app_drawer.dart';
import 'package:prontosindico/providers/resident_providers.dart';

class FinancialReportScreen extends ConsumerWidget {
  const FinancialReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final residentsAsync = ref.watch(residentsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF0F172A)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "Financeiro",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: residentsAsync.when(
        data: (residents) {
          final double totalRevenue = residents
              .where((r) => r.hasPaid)
              .fold(0.0, (prev, element) => prev + 1240.0); // Valor fixo conforme solicitado ou real se disponível
          final double totalPending = residents
              .where((r) => !r.hasPaid)
              .fold(0.0, (prev, element) => prev + 1240.0);
          final recentPaid = residents.where((r) => r.hasPaid).toList()
            ..sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RELATÓRIO FINANCEIRO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Visão Geral',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const Text(
                    'Fluxo de caixa do Condomínio Skyline',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 24),
                  _buildSummaryDashboard(totalRevenue, totalPending),
                  const SizedBox(height: 32),
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
                    const Center(child: Text('Nenhum pagamento registrado.'))
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
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro ao carregar dados: $err')),
      ),
    );
  }

  Widget _buildSummaryDashboard(double revenue, double pending) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildValueCard('RECEITA ACUMULADA', 'R\$ ${revenue.toStringAsFixed(0)}', const Color(0xFF10B981),
                    Icons.trending_up)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildValueCard(
                    'VALOR PENDENTE', 'R\$ ${pending.toStringAsFixed(0)}', const Color(0xFFF59E0B), Icons.access_time)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SALDO DISPONÍVEL',
                  style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text('R\$ ${(revenue).toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),
              const Text('Total arrecadado no período atual', style: TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValueCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isExpense ? Colors.red : Colors.green).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isExpense ? Icons.remove_circle_outline : Icons.add_circle_outline,
              color: isExpense ? Colors.red : Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text('UNIDADE $category - $date', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isExpense ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:prontosindico/screens/home/menu_lateral.dart';
import 'package:prontosindico/providers/auth_provider.dart';
import 'package:prontosindico/providers/resident_providers.dart';
import 'package:prontosindico/route/route_constants.dart';
import 'package:prontosindico/screens/home/controllers/home_stats_controller.dart';

class FinancialReportScreen extends ConsumerStatefulWidget {
  const FinancialReportScreen({super.key});

  @override
  ConsumerState<FinancialReportScreen> createState() =>
      _FinancialReportScreenState();
}

class _FinancialReportScreenState extends ConsumerState<FinancialReportScreen> {
  String _selectedFilter = "Todos"; // Controle do filtro ativo
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final residentsAsync = ref.watch(residentsStreamProvider);
    final userProfile = ref.watch(userProfileProvider).valueOrNull;

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
                final isAdmin = userProfile?.role.name == 'administrador' ||
                    userProfile?.role.name == 'sindico' ||
                    userProfile?.role.name == 'tesoureiro';

                // Lógica de Filtro Hierárquica e Pesquisa
                final List filteredResidents = residents.where((r) {
                  // 1. Filtro por Permissão (RBAC)
                  if (!isAdmin && r.user.uid != userProfile?.uid) return false;

                  // 2. Filtro pelas Abas (Apenas para Admins)
                  if (isAdmin) {
                    if (_selectedFilter == "Pago" && !r.hasPaid) return false;
                    if (_selectedFilter == "Pendente" && r.hasPaid) {
                      return false;
                    }
                  }

                  // 3. Filtro de Pesquisa (Nome ou Unidade)
                  final query = _normalizeString(_searchController.text);
                  if (query.isNotEmpty) {
                    final nameMatch =
                        _normalizeString(r.user.name).contains(query);
                    final unitMatch =
                        _normalizeString(r.apartment ?? "").contains(query);
                    if (!nameMatch && !unitMatch) {
                      return false;
                    }
                  }

                  return true;
                }).toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seletor de Mês
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Mês de Referência",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          _buildMonthDropdown(context, ref),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Filtros (TABS) - Apenas Admins
                      if (isAdmin) ...[
                        Row(
                          children: [
                            _buildFilterTab("Todos",
                                isActive: _selectedFilter == "Todos"),
                            const SizedBox(width: 8),
                            _buildFilterTab("Pago",
                                isActive: _selectedFilter == "Pago"),
                            const SizedBox(width: 8),
                            _buildFilterTab("Pendente",
                                isActive: _selectedFilter == "Pendente"),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Barra de Busca - Apenas Admins
                      if (isAdmin) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() {}),
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xFF1E293B)),
                            decoration: const InputDecoration(
                              hintText: 'Buscar morador ou unidade...',
                              hintStyle: TextStyle(
                                  fontSize: 14, color: Color(0xFF94A3B8)),
                              prefixIcon: Icon(Icons.search,
                                  color: Color(0xFF94A3B8), size: 20),
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Novo Bloco - Gerar Boletos (APENAS ADMINS)
                      if (isAdmin) ...[
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

                      // Habeçalhos da Tabela
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: const [
                            Expanded(
                              flex: 5,
                              child: Text("MORADOR / UNIDADE",
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF64748B))),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text("STATUS",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF64748B))),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text("AÇÃO",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF64748B))),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Lista de Moradores / Boletos
                      if (filteredResidents.isEmpty)
                        const Center(child: Text('Nenhum registro encontrado.'))
                      else
                        ...filteredResidents.map((r) {
                          String dueDateStr = "-";
                          if (r.dueDate != null) {
                            final d = r.dueDate!;
                            dueDateStr =
                                "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
                          }
                          return _buildResidentBoletoRow(
                            name: r.user.name,
                            unit: r.apartment ?? "000",
                            vencimento: dueDateStr,
                            isPaid: r.hasPaid,
                          );
                        }),

                      const SizedBox(height: 40),
                      // Dashboard Antigo (Opcional) - APENAS ADMINS
                      if (isAdmin)
                        _buildSummaryDashboard(
                          residents.where((r) => r.hasPaid).length * 1240.0,
                          residents.where((r) => !r.hasPaid).length * 1240.0,
                        ),
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

  Widget _buildMonthDropdown(BuildContext context, WidgetRef ref) {
    final currentMonthStr = ref.watch(selectedMonthProvider);

    // Parse da data atual selecionada (formato YYYY-MM)
    final parts = currentMonthStr.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final displayValue = "${month.toString().padLeft(2, '0')}/$year";

    return GestureDetector(
      onTap: () async {
        final selectedDate = await showMonthYearPicker(
          context: context,
          initialDate: DateTime(year, month),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          locale: const Locale('pt', 'BR'),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF1E40AF), // Cor primária do app
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Color(0xFF1E293B),
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1E40AF),
                  ),
                ),
              ),
              child: child!,
            );
          },
        );

        if (selectedDate != null) {
          final newMonthStr =
              '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}';
          ref.read(selectedMonthProvider.notifier).state = newMonthStr;
        }
      },
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_month,
              size: 16,
              color: Color(0xFF1E40AF),
            ),
            const SizedBox(width: 8),
            Text(
              displayValue,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        selected: true,
        onSelected: (_) async {
          // Mesma lógica do GestureDetector acima
          final selectedDate = await showMonthYearPicker(
            context: context,
            initialDate: DateTime(year, month),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            locale: const Locale('pt', 'BR'),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF1E40AF),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Color(0xFF1E293B),
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1E40AF),
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );

          if (selectedDate != null) {
            final newMonthStr =
                '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}';
            ref.read(selectedMonthProvider.notifier).state = newMonthStr;
          }
        },
        showCheckmark: false,
        backgroundColor: Colors.white,
        selectedColor: Colors.white,
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildFilterTab(String label, {required bool isActive}) {
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF004C99) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildResidentBoletoRow({
    required String name,
    required String unit,
    required String vencimento,
    required bool isPaid,
  }) {
    final initials =
        name.split(' ').take(2).map((e) => e[0]).join().toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Informações do Morador e Unidade
          Expanded(
            flex: 5,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFDBEAFE),
                  child: Text(initials,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        "Unidade: $unit • Vencimento: $vencimento",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color:
                    isPaid ? const Color(0xFFCCFBF1) : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isPaid ? "PAGO" : "PENDENTE",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isPaid
                        ? const Color(0xFF0D9488)
                        : const Color(0xFFB91C1C)),
              ),
            ),
          ),

          // Ação (Download/Visualização)
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(
                  isPaid
                      ? Icons.picture_as_pdf_outlined
                      : Icons.file_download_outlined,
                  size: 14,
                  color: isPaid ? const Color(0xFF1E293B) : Colors.white,
                ),
                label: Text(
                  isPaid ? "Boleto\nPDF" : "Download\nBoleto",
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isPaid ? const Color(0xFF1E293B) : Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPaid
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFF004C99),
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('SALDO DISPONÍVEL',
                      style: TextStyle(
                          color: Color(0xFF065F46),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2)),
                  const Icon(Icons.account_balance_wallet,
                      color: Color(0xFF10B981), size: 18),
                ],
              ),
              const SizedBox(height: 12),
              Text('R\$ ${(revenue).toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                      color: Color(0xFF064E3B),
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Total arrecadado no período atual',
                  style: TextStyle(
                      color: Color(0xFF065F46),
                      fontSize: 12,
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
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A))),
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
    final billsExist = await ref
        .read(homeStatsControllerProvider.notifier)
        .checkIfBillsExist();

    if (!mounted) return;

    if (billsExist) {
      final shouldRegenerate = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Boletos Já Existem'),
            content: const Text(
              'Já existem boletos criados no mês atual. Deseja limpar os boletos existentes e gerar novamente?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
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

      if (!mounted) return;

      if (shouldRegenerate == true) {
        await _generateBills(context, ref, clearExisting: true);
      }
    } else {
      final shouldGenerate = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Gerar Boletos Mensais'),
            content: const Text(
              'Deseja gerar os boletos (mês atual, vencimento dia 10 do próximo mês) para todos os moradores ativos?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
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

      if (!mounted) return;

      if (shouldGenerate == true) {
        await _generateBills(context, ref, clearExisting: false);
      }
    }
  }

  Future<void> _generateBills(BuildContext context, WidgetRef ref,
      {required bool clearExisting}) async {
    try {
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

  String _normalizeString(String text) {
    const withDia =
        'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    const withoutDia =
        'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';
    String normalized = text;
    for (int i = 0; i < withDia.length; i++) {
      normalized = normalized.replaceAll(withDia[i], withoutDia[i]);
    }
    return normalized.toLowerCase();
  }
}

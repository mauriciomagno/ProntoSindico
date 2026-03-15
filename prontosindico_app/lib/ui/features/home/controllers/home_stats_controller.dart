import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/providers/resident_providers.dart';

class HomeStatsState {
  final int paidCount;
  final int pendingCount;
  final bool isLoading;
  final bool isAdmin;
  final String? error;

  const HomeStatsState({
    this.paidCount = 0,
    this.pendingCount = 0,
    this.isLoading = true,
    this.isAdmin = false,
    this.error,
  });

  double get total => (paidCount + pendingCount).toDouble();
  double get paidPercentage => total == 0 ? 0 : (paidCount / total) * 100;
  double get pendingPercentage => total == 0 ? 0 : (pendingCount / total) * 100;

  HomeStatsState copyWith({
    int? paidCount,
    int? pendingCount,
    bool? isLoading,
    bool? isAdmin,
    String? error,
  }) {
    return HomeStatsState(
      paidCount: paidCount ?? this.paidCount,
      pendingCount: pendingCount ?? this.pendingCount,
      isLoading: isLoading ?? this.isLoading,
      isAdmin: isAdmin ?? this.isAdmin,
      error: error ?? this.error,
    );
  }
}

class HomeStatsController extends Notifier<HomeStatsState> {
  @override
  HomeStatsState build() {
    final residentsAsync = ref.watch(residentsStreamProvider);
    
    // Buscar role do usuário atual de forma assíncrona
    // Como build() deve ser síncrono no Notifier básico, 
    // vamos iniciar a busca e atualizar o estado depois.
    _checkAdminStatus();

    return residentsAsync.when(
      data: (residents) {
        // Removemos o filtro rigoroso de mês/ano para que todos os boletos 
        // cadastrados reflitam no gráfico, evitando divergências de contagem.
        final currentMonthResidents = residents;
        
        int paid = 0;
        int pending = 0;

        for (final r in currentMonthResidents) {
          if (r.hasPaid) {
            paid++;
          } else {
            pending++;
          }
        }
        
        return HomeStatsState(
          paidCount: paid,
          pendingCount: pending,
          isLoading: false,
          isAdmin: state.isAdmin, // Mantém o valor atual de admin
        );
      },
      loading: () => HomeStatsState(isLoading: true, isAdmin: stateOrNull?.isAdmin ?? false),
      error: (err, stack) => HomeStatsState(error: err.toString(), isLoading: false, isAdmin: stateOrNull?.isAdmin ?? false),
    );
  }

  Future<void> _checkAdminStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseDatabase.instance.ref('usuarios/${user.uid}').get();
        if (snapshot.exists) {
          final data = snapshot.value as Map?;
          final isAdmin = (data?['role'] as String?) == 'administrador';
          if (state.isAdmin != isAdmin) {
            state = state.copyWith(isAdmin: isAdmin);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> generateMonthlyBills() async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(residentRepositoryProvider).generateMonthlyBills();
      // O stream watchResidents() atualizará os dados automaticamente
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final homeStatsControllerProvider =
    NotifierProvider<HomeStatsController, HomeStatsState>(
  HomeStatsController.new,
);

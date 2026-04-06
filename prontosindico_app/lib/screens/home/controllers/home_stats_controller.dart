import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/providers/resident_providers.dart';

class HomeStatsState {
  final int paidCount;
  final int pendingCount;
  final bool isLoading;
  final bool isAdmin;
  final bool hasPaymentRealized;
  final String? error;

  const HomeStatsState({
    this.paidCount = 0,
    this.pendingCount = 0,
    this.isLoading = true,
    this.isAdmin = false,
    this.hasPaymentRealized = false,
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
    bool? hasPaymentRealized,
    String? error,
  }) {
    return HomeStatsState(
      paidCount: paidCount ?? this.paidCount,
      pendingCount: pendingCount ?? this.pendingCount,
      isLoading: isLoading ?? this.isLoading,
      isAdmin: isAdmin ?? this.isAdmin,
      hasPaymentRealized: hasPaymentRealized ?? this.hasPaymentRealized,
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
        // Filtrar apenas boletos com referência ao mês atual
        final now = DateTime.now();
        final currentMonthResidents = residents.where((r) {
          if (r.referenceMonth == null) return false;
          return r.referenceMonth!.year == now.year &&
              r.referenceMonth!.month == now.month;
        }).toList();

        int paid = 0;
        int pending = 0;
        bool hasPayment = false;

        for (final r in currentMonthResidents) {
          if (r.hasPaid) {
            paid++;
            hasPayment = true; // Marca que há pelo menos um pagamento realizado
          } else {
            pending++;
          }
        }

        return HomeStatsState(
          paidCount: paid,
          pendingCount: pending,
          isLoading: false,
          isAdmin: stateOrNull?.isAdmin ?? false,
          hasPaymentRealized: hasPayment,
        );
      },
      loading: () => HomeStatsState(
          isLoading: true, isAdmin: stateOrNull?.isAdmin ?? false),
      error: (err, stack) => HomeStatsState(
          error: err.toString(),
          isLoading: false,
          isAdmin: stateOrNull?.isAdmin ?? false),
    );
  }

  Future<void> _checkAdminStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot =
            await FirebaseDatabase.instance.ref('usuarios/${user.uid}').get();
        if (snapshot.exists) {
          final data = snapshot.value as Map?;
          final isAdmin = (data?['role'] as String?) == 'administrador';
          if (stateOrNull != null && stateOrNull!.isAdmin != isAdmin) {
            state = state.copyWith(isAdmin: isAdmin);
          }
        }
      }
    } catch (_) {}
  }

  Future<bool> checkIfBillsExist() async {
    try {
      return await ref
          .read(residentRepositoryProvider)
          .checkMonthlyBillsExist();
    } catch (e) {
      return false;
    }
  }

  Future<void> generateMonthlyBills({bool clearExisting = false}) async {
    // Evita acessar state se não estiver inicializado
    try {
      if (stateOrNull != null) {
        state = state.copyWith(isLoading: true);
      }
    } catch (_) {
      // State não inicializado, continua sem atualizar isLoading
    }

    try {
      final repository = ref.read(residentRepositoryProvider);

      if (clearExisting) {
        await repository.clearMonthlyBills();
      }

      await repository.generateMonthlyBills();
      // O stream watchResidents() atualizará os dados automaticamente

      try {
        if (stateOrNull != null) {
          state = state.copyWith(isLoading: false);
        }
      } catch (_) {
        // State não inicializado, ignora
      }
    } catch (e) {
      try {
        if (stateOrNull != null) {
          state = state.copyWith(isLoading: false, error: e.toString());
        }
      } catch (_) {
        // State não inicializado, ignora
      }
      rethrow;
    }
  }
}

final homeStatsControllerProvider =
    NotifierProvider<HomeStatsController, HomeStatsState>(
  HomeStatsController.new,
);

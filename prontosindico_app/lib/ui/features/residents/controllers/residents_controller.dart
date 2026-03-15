import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/providers/resident_providers.dart';
import 'package:prontosindico/ui/features/residents/states/residents_state.dart';

class ResidentsController extends Notifier<ResidentsState> {
  @override
  ResidentsState build() {
    // Observamos o stream de moradores
    final residentsAsync = ref.watch(residentsStreamProvider);

    return residentsAsync.when(
      data: (residents) => ResidentsState(residents: residents, isLoading: false),
      loading: () => const ResidentsState(isLoading: true),
      error: (err, stack) => ResidentsState(error: err.toString(), isLoading: false),
    );
  }

  Future<void> togglePaymentStatus(String userId, bool hasPaid) async {
    try {
      final repository = ref.read(residentRepositoryProvider);
      await repository.updatePaymentStatus(userId, hasPaid);
    } catch (e) {
      // Opcional: tratar erro de atualização ou mostrar um snackbar via UI
      state = state.copyWith(error: 'Erro ao atualizar pagamento: $e');
    }
  }
}

final residentsControllerProvider =
    NotifierProvider.autoDispose<ResidentsController, ResidentsState>(
  ResidentsController.new,
);


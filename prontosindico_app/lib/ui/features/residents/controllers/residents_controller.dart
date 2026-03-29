import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/providers/resident_providers.dart';
import 'package:prontosindico/ui/features/residents/states/residents_state.dart';

class ResidentsController extends StateNotifier<ResidentsState> {
  final Ref ref;

  ResidentsController(this.ref) : super(const ResidentsState(isLoading: true)) {
    _init();
  }

  void _init() {
    // Observamos o stream de moradores
    ref.listen(residentsStreamProvider, (previous, next) {
      next.when(
        data: (residents) =>
            state = ResidentsState(residents: residents, isLoading: false),
        loading: () => state = const ResidentsState(isLoading: true),
        error: (err, stack) =>
            state = ResidentsState(error: err.toString(), isLoading: false),
      );
    });
  }

  Future<void> togglePaymentStatus(String billId, bool hasPaid) async {
    try {
      final repository = ref.read(residentRepositoryProvider);
      await repository.updatePaymentStatus(billId, hasPaid);
    } catch (e) {
      // Opcional: tratar erro de atualização ou mostrar um snackbar via UI
      state = state.copyWith(error: 'Erro ao atualizar pagamento: $e');
    }
  }
}

final residentsControllerProvider =
    StateNotifierProvider.autoDispose<ResidentsController, ResidentsState>(
  (ref) => ResidentsController(ref),
);

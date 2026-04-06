import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/domain/entities/resident.dart';
import 'package:prontosindico/providers/resident_providers.dart';
import 'package:prontosindico/screens/residents/states/residents_state.dart';

class ResidentsController extends Notifier<ResidentsState> {
  @override
  ResidentsState build() {
    final residentsAsync = ref.watch(residentsStreamProvider);

    return residentsAsync.when(
      data: (residents) => ResidentsState(
        residents: residents.cast<Resident>().toList(),
        isLoading: false,
      ),
      loading: () => const ResidentsState(isLoading: true),
      error: (err, stack) =>
          ResidentsState(error: err.toString(), isLoading: false),
    );
  }

  Future<void> togglePaymentStatus(String billId, bool hasPaid) async {
    try {
      final repository = ref.read(residentRepositoryProvider);
      await repository.updatePaymentStatus(billId, hasPaid);
    } catch (e) {
      state = state.copyWith(error: 'Erro ao atualizar pagamento: $e');
    }
  }
}

final residentsControllerProvider =
    NotifierProvider<ResidentsController, ResidentsState>(
  ResidentsController.new,
);

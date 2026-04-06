import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/data/repositories/resident_repository.dart';
import 'package:prontosindico/domain/repositories/i_resident_repository.dart';
import 'package:prontosindico/providers/auth_provider.dart';

final residentRepositoryProvider = Provider<IResidentRepository>((ref) {
  return ResidentRepository();
});

// Provedor para armazenar o mês selecionado no relatório financeiro (ex: '2026-03')
final selectedMonthProvider = StateProvider<String>((ref) {
  return DateTime.now().toIso8601String().substring(0, 7);
});

final residentsStreamProvider = StreamProvider.autoDispose((ref) {
  final repository = ref.watch(residentRepositoryProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);
  final userProfile = ref.watch(userProfileProvider).valueOrNull;

  // Se não há usuário logado, retorna lista vazia
  if (userProfile == null) {
    return Stream.value(<dynamic>[]);
  }

  return repository.watchResidents(
    currentUserUid: userProfile.uid,
    currentUserRole: userProfile.role,
    referenceMonth: selectedMonth,
  );
});

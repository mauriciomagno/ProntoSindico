import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/data/repositories/resident_repository.dart';
import 'package:prontosindico/domain/repositories/i_resident_repository.dart';

final residentRepositoryProvider = Provider<IResidentRepository>((ref) {
  return ResidentRepository();
});

final residentsStreamProvider = StreamProvider.autoDispose((ref) {
  final repository = ref.watch(residentRepositoryProvider);
  return repository.watchResidents();
});

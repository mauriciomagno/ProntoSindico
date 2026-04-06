import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/data/repositories/reserva_repository.dart';
import 'package:prontosindico/domain/entities/reserva.dart';
import 'package:prontosindico/domain/repositories/i_reserva_repository.dart';

final reservaRepositoryProvider = Provider<IReservaRepository>((ref) {
  return ReservaRepository();
});

final areasComunsProvider = StreamProvider<List<AreaComum>>((ref) {
  return ref.watch(reservaRepositoryProvider).watchAreasComuns();
});

final reservasStreamProvider = StreamProvider<List<Reserva>>((ref) {
  return ref.watch(reservaRepositoryProvider).watchReservas();
});

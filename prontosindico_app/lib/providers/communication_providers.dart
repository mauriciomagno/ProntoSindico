import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/data/repositories/communication_repository.dart';
import 'package:prontosindico/domain/entities/comunicado.dart';
import 'package:prontosindico/domain/entities/mural_aviso.dart';
import 'package:prontosindico/domain/repositories/i_communication_repository.dart';

final communicationRepositoryProvider = Provider<ICommunicationRepository>((ref) {
  return CommunicationRepository();
});

final muralAvisosProvider = StreamProvider<List<MuralAviso>>((ref) {
  return ref.watch(communicationRepositoryProvider).watchMuralAvisos();
});

final comunicadosProvider = StreamProvider<List<Comunicado>>((ref) {
  return ref.watch(communicationRepositoryProvider).watchComunicados();
});

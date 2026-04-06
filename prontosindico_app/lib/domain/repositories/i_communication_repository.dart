import 'package:prontosindico/domain/entities/mural_aviso.dart';
import 'package:prontosindico/domain/entities/comunicado.dart';

abstract class ICommunicationRepository {
  Future<void> saveMuralAviso(String authorUid, MuralAviso muralAviso);
  Stream<List<MuralAviso>> watchMuralAvisos();
  
  Future<void> saveComunicado(String authorUid, Comunicado comunicado);
  Stream<List<Comunicado>> watchComunicados();
}

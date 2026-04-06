import 'package:firebase_database/firebase_database.dart';
import 'package:prontosindico/domain/entities/mural_aviso.dart';
import 'package:prontosindico/domain/entities/comunicado.dart';
import 'package:prontosindico/domain/repositories/i_communication_repository.dart';

class CommunicationRepository implements ICommunicationRepository {
  final FirebaseDatabase _db;

  CommunicationRepository({FirebaseDatabase? db})
      : _db = db ?? FirebaseDatabase.instance;

  @override
  Future<void> saveMuralAviso(String authorUid, MuralAviso muralAviso) async {
    final ref = _db.ref('mural_avisos').child(authorUid);
    try {
      await ref.push().set(muralAviso.toMap());
    } catch (e) {
      throw Exception('Erro ao salvar no mural de avisos: $e');
    }
  }

  @override
  Stream<List<MuralAviso>> watchMuralAvisos() {
    return _db.ref('mural_avisos').onValue.map((event) {
      final authorMap = event.snapshot.value as Map? ?? {};
      final List<MuralAviso> avisos = [];
      
      authorMap.forEach((authorUid, avisosMap) {
        if (avisosMap is Map) {
          avisosMap.forEach((key, value) {
            if (value is Map) {
              avisos.add(MuralAviso.fromMap(value, key.toString()));
            }
          });
        }
      });

      avisos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return avisos;
    });
  }

  @override
  Future<void> saveComunicado(String authorUid, Comunicado comunicado) async {
    final ref = _db.ref('comunicados').child(authorUid);
    try {
      await ref.push().set(comunicado.toMap());
    } catch (e) {
      throw Exception('Erro ao salvar comunicado: $e');
    }
  }

  @override
  Stream<List<Comunicado>> watchComunicados() {
    return _db.ref('comunicados').onValue.map((event) {
      final authorMap = event.snapshot.value as Map? ?? {};
      final List<Comunicado> comunicadosList = [];
      
      authorMap.forEach((authorUid, itemsMap) {
        if (itemsMap is Map) {
          itemsMap.forEach((key, value) {
            if (value is Map) {
              comunicadosList.add(Comunicado.fromMap(value, key.toString()));
            }
          });
        }
      });

      comunicadosList.sort((a, b) => b.date.compareTo(a.date));
      return comunicadosList;
    });
  }
}

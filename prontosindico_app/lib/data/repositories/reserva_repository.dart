import 'package:firebase_database/firebase_database.dart';
import 'package:prontosindico/domain/entities/reserva.dart';
import 'package:prontosindico/domain/repositories/i_reserva_repository.dart';

class ReservaRepository implements IReservaRepository {
  final FirebaseDatabase _db;

  ReservaRepository({FirebaseDatabase? db})
      : _db = db ?? FirebaseDatabase.instance;

  @override
  Future<void> saveAreaComum(AreaComum area) async {
    final ref = _db.ref('areas_comuns');
    try {
      await ref.push().set(area.toMap());
    } catch (e) {
      throw Exception('Erro ao salvar área comum: $e');
    }
  }

  @override
  Stream<List<AreaComum>> watchAreasComuns() {
    return _db.ref('areas_comuns').onValue.map((event) {
      final data = event.snapshot.value as Map? ?? {};
      final List<AreaComum> areas = [];
      
      data.forEach((key, value) {
        if (value is Map) {
          areas.add(AreaComum.fromMap(value, key.toString()));
        }
      });

      return areas;
    });
  }

  @override
  Future<void> saveReserva(Reserva reserva) async {
    final ref = _db.ref('reservas');
    try {
      await ref.push().set(reserva.toMap());
    } catch (e) {
      throw Exception('Erro ao salvar reserva: $e');
    }
  }

  @override
  Stream<List<Reserva>> watchReservas() {
    return _db.ref('reservas').onValue.map((event) {
      final data = event.snapshot.value as Map? ?? {};
      final List<Reserva> reservasList = [];
      
      data.forEach((key, value) {
        if (value is Map) {
          reservasList.add(Reserva.fromMap(value, key.toString()));
        }
      });

      return reservasList;
    });
  }

  @override
  Future<void> deleteReserva(String id) async {
    final ref = _db.ref('reservas/$id');
    try {
      await ref.remove();
    } catch (e) {
      throw Exception('Erro ao cancelar reserva: $e');
    }
  }
}

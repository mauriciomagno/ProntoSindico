import 'package:prontosindico/domain/entities/reserva.dart';

abstract class IReservaRepository {
  // Common Areas (Created by Admin/Síndico/Tesoureiro)
  Future<void> saveAreaComum(AreaComum area);
  Stream<List<AreaComum>> watchAreasComuns();
  
  // Reservations (Done by any user for themselves)
  Future<void> saveReserva(Reserva reserva);
  Stream<List<Reserva>> watchReservas();
  Future<void> deleteReserva(String id);
}

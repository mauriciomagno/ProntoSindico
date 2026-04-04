import 'package:prontosindico/domain/entities/resident.dart';

abstract interface class IResidentRepository {
  /// Stream reativa da lista de moradores.
  Stream<List<Resident>> watchResidents();

  /// Atualiza o status de pagamento do morador.
  Future<void> updatePaymentStatus(String userId, bool hasPaid);

  /// Verifica se já existem boletos para o mês atual.
  Future<bool> checkMonthlyBillsExist();

  /// Remove todos os boletos do mês atual.
  Future<void> clearMonthlyBills();

  /// Gera boletos para todos os usuários ativos no mês atual.
  Future<void> generateMonthlyBills();
}

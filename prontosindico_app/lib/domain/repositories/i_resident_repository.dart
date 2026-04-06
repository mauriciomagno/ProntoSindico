import 'package:prontosindico/domain/entities/resident.dart';
import 'package:prontosindico/domain/enums/user_role.dart';

abstract interface class IResidentRepository {
  /// Stream reativa da lista de moradores e boletos (filtravel por mês).
  /// [currentUserUid] UID do usuário logado
  /// [currentUserRole] Papel do usuário logado
  /// [referenceMonth] Mês de referência para filtrar boletos (formato 'yyyy-MM')
  Stream<List<Resident>> watchResidents({
    required String currentUserUid,
    required UserRole currentUserRole,
    String? referenceMonth,
  });

  /// Atualiza o status de pagamento do morador.
  Future<void> updatePaymentStatus(String userId, bool hasPaid);

  /// Verifica se já existem boletos para o mês atual.
  Future<bool> checkMonthlyBillsExist();

  /// Remove todos os boletos do mês atual.
  Future<void> clearMonthlyBills();

  /// Gera boletos para todos os usuários ativos no mês atual.
  Future<void> generateMonthlyBills();
}

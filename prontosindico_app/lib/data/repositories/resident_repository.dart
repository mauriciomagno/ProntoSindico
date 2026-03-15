import 'package:firebase_database/firebase_database.dart';
import 'package:prontosindico/domain/entities/app_user.dart';
import 'package:prontosindico/domain/entities/resident.dart';
import 'package:prontosindico/domain/enums/user_role.dart';
import 'package:prontosindico/domain/repositories/i_resident_repository.dart';
import 'package:rxdart/rxdart.dart';

class ResidentRepository implements IResidentRepository {
  final FirebaseDatabase _db;

  ResidentRepository({FirebaseDatabase? db})
      : _db = db ?? FirebaseDatabase.instance;

  @override
  Stream<List<Resident>> watchResidents() {
    final usuariosStream = _db.ref('usuarios').onValue;
    final moradoresStream = _db.ref('moradores').onValue;
    final boletosStream = _db.ref('boletos').onValue;

    return CombineLatestStream.combine3(
      usuariosStream,
      moradoresStream,
      boletosStream,
      (usersEvent, residentsEvent, billsEvent) {
        final usersMap = usersEvent.snapshot.value as Map? ?? {};
        final residentsMap = residentsEvent.snapshot.value as Map? ?? {};
        final billsMap = billsEvent.snapshot.value as Map? ?? {};

        final List<Resident> residents = [];

        usersMap.forEach((uid, userData) {
          if (userData is! Map) return;
          final userUid = uid.toString();
          final userMapStr = Map<String, dynamic>.from(userData);
          
          final role = UserRole.fromString(userMapStr['role']?.toString() ?? 'morador');
          
          final appUser = AppUser(
            uid: userUid,
            email: userMapStr['email']?.toString() ?? '',
            name: userMapStr['nome']?.toString() ?? '',
            role: role,
            isActive: _parseAtivo(userMapStr['ativo']),
            photoUrl: userMapStr['Foto']?.toString(),
            phone: userMapStr['telefone']?.toString(),
          );

          // 1. Buscar apartamento em 'moradores' (onde usuarioId == userUid)
          String? apartment;
          residentsMap.forEach((moradorId, mData) {
            if (mData is Map && mData['usuarioId'] == userUid) {
              apartment = mData['apartamento']?.toString();
            }
          });

          // 2. Buscar pagamento em 'boletos'
          // Pode ser a chave direta (userId) ou uma entrada com usuarioId
          bool hasPaid = false;
          if (billsMap.containsKey(userUid)) {
            final directBill = billsMap[userUid];
            if (directBill is Map) {
              hasPaid = _parseAtivo(directBill['pagamentoRealizado']);
            }
          } else {
            billsMap.forEach((billId, bData) {
              if (bData is Map && bData['usuarioId'] == userUid) {
                hasPaid = _parseAtivo(bData['pagamentoRealizado']);
              }
            });
          }

          residents.add(Resident(
            user: appUser,
            apartment: apartment,
            hasPaid: hasPaid,
          ));
        });

        return residents;
      },
    );
  }

  @override
  Future<void> updatePaymentStatus(String userId, bool hasPaid) async {
    final billsRef = _db.ref('boletos');
    final snapshot = await billsRef.get();
    
    if (snapshot.exists) {
      final billsMap = snapshot.value as Map? ?? {};
      
      // Se existe uma chave direta com o userId, atualiza ela
      if (billsMap.containsKey(userId)) {
        await billsRef.child(userId).update({
          'pagamentoRealizado': hasPaid ? 'Sim' : 'Não',
        });
        return;
      }
      
      // Caso contrário, procura a entrada que contém o usuarioId
      String? targetBillId;
      billsMap.forEach((billId, bData) {
        if (bData is Map && bData['usuarioId'] == userId) {
          targetBillId = billId.toString();
        }
      });
      
      if (targetBillId != null) {
        await billsRef.child(targetBillId!).update({
          'pagamentoRealizado': hasPaid ? 'Sim' : 'Não',
        });
      } else {
        // Se não encontrar nada, cria uma entrada direta para garantir o funcionamento
        await billsRef.child(userId).set({
          'usuarioId': userId,
          'pagamentoRealizado': hasPaid ? 'Sim' : 'Não',
        });
      }
    } else {
      // Nó de boletos vazio, cria o primeiro
      await billsRef.child(userId).set({
        'usuarioId': userId,
        'pagamentoRealizado': hasPaid ? 'Sim' : 'Não',
      });
    }
  }


  bool _parseAtivo(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'sim';
    if (value is int) return value == 1;
    return false;
  }
}

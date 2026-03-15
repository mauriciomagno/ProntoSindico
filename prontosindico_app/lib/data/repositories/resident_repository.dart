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
        final usersData = usersEvent.snapshot.value;
        final residentsData = residentsEvent.snapshot.value;
        final billsData = billsEvent.snapshot.value;

        final Map<dynamic, dynamic> usersMap = _convertToMap(usersData);
        final Map<dynamic, dynamic> residentsMap = _convertToMap(residentsData);
        final Map<dynamic, dynamic> billsMap = _convertToMap(billsData);

        final List<Resident> residents = [];

        // Iterar sobre os boletos em vez dos usuários para garantir que todos os registros sejam vistos
        billsMap.forEach((billId, bData) {
          if (bData is! Map) return;
          
          final String userUid = bData['usuarioId']?.toString() ?? '';
          if (userUid.isEmpty) return;

          // Buscar dados do usuário
          AppUser appUser;
          final userData = usersMap[userUid];
          
          if (userData is Map) {
            final userMapStr = Map<String, dynamic>.from(userData);
            final role = UserRole.fromString(userMapStr['role']?.toString() ?? 'morador');
            
            appUser = AppUser(
              uid: userUid,
              email: userMapStr['email']?.toString() ?? '',
              name: userMapStr['nome']?.toString() ?? '',
              role: role,
              isActive: _parseAtivo(userMapStr['ativo']),
              photoUrl: userMapStr['Foto']?.toString(),
              phone: userMapStr['telefone']?.toString(),
            );
          } else {
            // Caso o usuário não exista no nó 'usuarios', cria um placeholder
            // para não perder o registro financeiro do boleto.
            appUser = AppUser(
              uid: userUid,
              email: '',
              name: 'Usuário Desconhecido ($userUid)',
              role: UserRole.morador,
              isActive: true,
            );
          }

          // Buscar apartamento em 'moradores'
          String? apartment;
          residentsMap.forEach((mId, mData) {
            if (mData is Map && mData['usuarioId'] == userUid) {
              apartment = mData['apartamento']?.toString();
            }
          });

          residents.add(Resident(
            id: billId.toString(),
            user: appUser,
            apartment: apartment,
            hasPaid: _parseAtivo(bData['pagamentoRealizado']),
            createdAt: _parseDate(bData['dataCriacao']),
          ));
        });

        return residents;
      },
    );
  }

  @override
  Future<void> updatePaymentStatus(String billId, bool hasPaid) async {
    final billsRef = _db.ref('boletos');
    // Agora atualizamos diretamente pelo ID do boleto, que é mais robusto
    await billsRef.child(billId).update({
      'pagamentoRealizado': hasPaid ? 'Sim' : 'Não',
    });
  }

  @override
  Future<void> generateMonthlyBills() async {
    final now = DateTime.now();
    final dataCriacaoStr = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    
    final dueDate = now.add(const Duration(days: 10));
    final vencimentoStr = "${dueDate.day.toString().padLeft(2, '0')}/${dueDate.month.toString().padLeft(2, '0')}/${dueDate.year}";

    final usersSnapshot = await _db.ref('usuarios').get();
    final residentsSnapshot = await _db.ref('moradores').get();
    
    if (!usersSnapshot.exists) return;

    final usersMap = usersSnapshot.value as Map? ?? {};
    final residentsMap = residentsSnapshot.value as Map? ?? {};

    final billsRef = _db.ref('boletos');

    for (final entry in usersMap.entries) {
      final userData = entry.value;
      if (userData is! Map || userData['ativo'] != 'Sim') continue;
      
      final userUid = entry.key.toString();
      
      // Encontrar moradorId para este usuarioId
      String? moradorId;
      residentsMap.forEach((mId, mData) {
        if (mData is Map && mData['usuarioId'] == userUid) {
          moradorId = mId.toString();
        }
      });

      if (moradorId != null) {
        // Criar boleto para este usuário no mês atual
        // Usamos uma chave composta por userId e mes_ano para evitar duplicidade rápida ou apenas o userId se o padrão for um boleto por vez
        // Seguindo o código anterior, ele usa o userId como chave em alguns casos.
        // Vamos usar o userId como chave principal para manter a simplicidade ou um push() se preferir lista.
        // O usuário pediu "crie uma lista", então usaremos push().
        
        await billsRef.push().set({
          'usuarioId': userUid,
          'moradorId': moradorId,
          'dataCriacao': dataCriacaoStr,
          'pagamentoRealizado': 'Não',
          'vencimentoPagamento': vencimentoStr,
          'dataPagamento': '',
        });
      }
    }
  }

  bool _parseAtivo(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'sim';
    if (value is int) return value == 1;
    return false;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        // Tenta formato comum no Brasil dd/MM/yyyy
        try {
          final parts = value.split('/');
          if (parts.length == 3) {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            return DateTime(year, month, day);
          }
        } catch (_) {}
      }
    }
    return null;
  }

  Map<dynamic, dynamic> _convertToMap(dynamic data) {
    if (data == null) return {};
    if (data is Map) return data;
    if (data is List) {
      final Map<dynamic, dynamic> map = {};
      for (int i = 0; i < data.length; i++) {
        if (data[i] != null) {
          map[i.toString()] = data[i];
        }
      }
      return map;
    }
    return {};
  }
}

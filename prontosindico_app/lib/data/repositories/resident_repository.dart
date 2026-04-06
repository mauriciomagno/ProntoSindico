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
  Stream<List<Resident>> watchResidents({
    required String currentUserUid,
    required UserRole currentUserRole,
    String? referenceMonth,
  }) {
    // Determina se o usuário é admin (pode ver todos)
    final isAdmin = currentUserRole == UserRole.administrador ||
        currentUserRole == UserRole.sindico ||
        currentUserRole == UserRole.tesoureiro;

    // Se for morador, busca apenas dados específicos dele
    if (!isAdmin) {
      return _watchResidentForMorador(currentUserUid, referenceMonth);
    }

    // Se for admin, busca todos os dados (comportamento anterior)
    return _watchAllResidents(referenceMonth);
  }

  /// Query filtrada para moradores - só traz os próprios dados
  Stream<List<Resident>> _watchResidentForMorador(
    String userUid,
    String? referenceMonth,
  ) {
    // Primeiro, encontra o moradorId deste usuário
    final moradoresStream = _db.ref('moradores').onValue;

    return moradoresStream.asyncExpand((moradoresEvent) async* {
      final moradoresData = moradoresEvent.snapshot.value;
      final moradoresMap = _convertToMap(moradoresData);

      // Encontra o moradorId para este usuário
      String? moradorId;
      String? apartment;

      moradoresMap.forEach((mId, mData) {
        if (mData is Map && mData['usuarioId'] == userUid) {
          moradorId = mId.toString();
          apartment = mData['apartamento']?.toString();
        }
      });

      if (moradorId == null) {
        yield [];
        return;
      }

      // Agora busca dados específicos deste morador
      final userStream = _db.ref('usuarios/$userUid').onValue;
      final billsStream = _db.ref('boletos/$moradorId').onValue;

      await for (final combined in CombineLatestStream.combine2(
        userStream,
        billsStream,
        (userEvent, billsEvent) {
          final userData = userEvent.snapshot.value;
          final billsData = billsEvent.snapshot.value;

          if (userData == null || userData is! Map) return <Resident>[];

          final userMapStr = Map<String, dynamic>.from(userData);
          final role =
              UserRole.fromString(userMapStr['role']?.toString() ?? 'morador');

          final appUser = AppUser(
            uid: userUid,
            email: userMapStr['email']?.toString() ?? '',
            name: userMapStr['nome']?.toString() ?? '',
            role: role,
            isActive: _parseAtivo(userMapStr['ativo']),
            photoUrl: userMapStr['Foto']?.toString(),
            phone: userMapStr['telefone']?.toString(),
          );

          if (appUser.isActive != true) return <Resident>[];

          final targetMonth = referenceMonth ??
              DateTime.now().toIso8601String().substring(0, 7);
          final billsMap = _convertToMap(billsData);

          Resident resident;

          if (billsMap.isNotEmpty) {
            // Tenta encontrar o boleto do mês específico
            dynamic currentBill;
            billsMap.forEach((key, bData) {
              if (bData is Map && bData['mesReferencia'] == targetMonth) {
                currentBill = bData;
              }
            });

            // Se não achou do mês atual, pega o último gerado
            if (currentBill == null) {
              final sortedKeys = billsMap.keys.toList()..sort();
              currentBill = billsMap[sortedKeys.last];
            }

            if (currentBill != null) {
              resident = Resident(
                id: moradorId!,
                user: appUser,
                apartment: apartment,
                hasPaid: _parseAtivo(currentBill['pagamentoRealizado']),
                createdAt: _parseDate(currentBill['dataCriacao']),
                dueDate: _parseDate(currentBill['vencimentoPagamento']),
                referenceMonth: _parseDate(currentBill['mesReferencia']),
              );
            } else {
              resident = Resident(
                id: moradorId!,
                user: appUser,
                apartment: apartment,
                hasPaid: false,
              );
            }
          } else {
            resident = Resident(
              id: moradorId!,
              user: appUser,
              apartment: apartment,
              hasPaid: false,
            );
          }

          return [resident];
        },
      )) {
        yield combined;
      }
    });
  }

  /// Query completa para admins - traz todos os dados
  Stream<List<Resident>> _watchAllResidents(String? referenceMonth) {
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
        final targetMonth =
            referenceMonth ?? DateTime.now().toIso8601String().substring(0, 7);

        // Iterar primeiro pelos moradores cadastrados
        residentsMap.forEach((moradorId, moradorData) {
          if (moradorData is! Map) {
            return;
          }

          final String userUid = moradorData['usuarioId']?.toString() ?? '';
          final String? apartment = moradorData['apartamento']?.toString();

          if (userUid.isEmpty) {
            return;
          }

          // Buscar dados do usuário
          final userData = usersMap[userUid];
          if (userData is! Map) {
            return;
          }

          final userMapStr = Map<String, dynamic>.from(userData);
          final role =
              UserRole.fromString(userMapStr['role']?.toString() ?? 'morador');

          final appUser = AppUser(
            uid: userUid,
            email: userMapStr['email']?.toString() ?? '',
            name: userMapStr['nome']?.toString() ?? '',
            role: role,
            isActive: _parseAtivo(userMapStr['ativo']),
            photoUrl: userMapStr['Foto']?.toString(),
            phone: userMapStr['telefone']?.toString(),
          );

          // Se o usuário não está ativo, não mostrar no relatório financeiro
          if (appUser.isActive != true) {
            return;
          }

          // Buscar boletos deste morador
          final moradorBills = billsMap[moradorId];
          Resident selectedResidentState;

          if (moradorBills is Map) {
            // Tenta encontrar o boleto do mês atual
            dynamic currentBill;
            moradorBills.forEach((key, bData) {
              if (bData is Map && bData['mesReferencia'] == targetMonth) {
                currentBill = bData;
              }
            });

            // Se não achou do mês atual, pega o último gerado
            if (currentBill == null && moradorBills.isNotEmpty) {
              final sortedKeys = moradorBills.keys.toList()..sort();
              currentBill = moradorBills[sortedKeys.last];
            }

            if (currentBill != null) {
              selectedResidentState = Resident(
                id: moradorId.toString(),
                user: appUser,
                apartment: apartment,
                hasPaid: _parseAtivo(currentBill['pagamentoRealizado']),
                createdAt: _parseDate(currentBill['dataCriacao']),
                dueDate: _parseDate(currentBill['vencimentoPagamento']),
                referenceMonth: _parseDate(currentBill['mesReferencia']),
              );
            } else {
              // Tem boletos, mas nenhum do mês atual (Pendente por padrão)
              selectedResidentState = Resident(
                id: moradorId.toString(),
                user: appUser,
                apartment: apartment,
                hasPaid: false,
              );
            }
          } else {
            // Morador sem nenhum boleto gerado
            selectedResidentState = Resident(
              id: moradorId.toString(),
              user: appUser,
              apartment: apartment,
              hasPaid: false,
            );
          }

          residents.add(selectedResidentState);
        });

        return residents;
      },
    );
  }

  @override
  Future<void> updatePaymentStatus(String billId, bool hasPaid) async {
    // billId está no formato: moradorId/bol_2026_XX
    final parts = billId.split('/');
    if (parts.length != 2) {
      return;
    }

    final moradorId = parts[0];
    final billKey = parts[1];

    final billsRef = _db.ref('boletos');
    await billsRef.child(moradorId).child(billKey).update({
      'pagamentoRealizado': hasPaid,
      'dataPagamento':
          hasPaid ? DateTime.now().toIso8601String().substring(0, 10) : '',
    });
  }

  @override
  Future<bool> checkMonthlyBillsExist() async {
    final now = DateTime.now();
    final currentMonth = now.toIso8601String().substring(0, 7); // yyyy-MM

    final billsSnapshot = await _db.ref('boletos').get();
    if (!billsSnapshot.exists) {
      return false;
    }

    final billsMap = billsSnapshot.value as Map? ?? {};

    // Estrutura: boletos/{moradorId}/{guid}
    for (final moradorBills in billsMap.values) {
      if (moradorBills is! Map) {
        continue;
      }

      for (final billData in moradorBills.values) {
        if (billData is! Map) {
          continue;
        }
        final mesReferencia = billData['mesReferencia']?.toString();
        if (mesReferencia == currentMonth) {
          return true; // Encontrou boleto do mês atual
        }
      }
    }
    return false;
  }

  @override
  Future<void> clearMonthlyBills() async {
    final now = DateTime.now();
    final currentMonth = now.toIso8601String().substring(0, 7); // yyyy-MM

    final billsRef = _db.ref('boletos');
    final billsSnapshot = await billsRef.get();
    if (!billsSnapshot.exists) {
      return;
    }

    final billsMap = billsSnapshot.value as Map? ?? {};

    // Estrutura: boletos/{moradorId}/{guid}
    for (final moradorEntry in billsMap.entries) {
      final moradorId = moradorEntry.key.toString();
      final moradorBills = moradorEntry.value;
      if (moradorBills is! Map) {
        continue;
      }

      for (final billEntry in moradorBills.entries) {
        final billKey = billEntry.key.toString();
        final billData = billEntry.value;
        if (billData is! Map) {
          continue;
        }

        final mesReferencia = billData['mesReferencia']?.toString();
        if (mesReferencia == currentMonth) {
          await billsRef.child(moradorId).child(billKey).remove();
        }
      }
    }
  }

  @override
  Future<void> generateMonthlyBills() async {
    final now = DateTime.now();
    final dataCriacaoStr = now.toIso8601String().substring(0, 10); // yyyy-MM-dd
    final mesReferenciaStr = now.toIso8601String().substring(0, 7); // yyyy-MM

    // Vencimento: dia 10 do mês seguinte
    final nextMonth = DateTime(now.year, now.month + 1, 10);
    final vencimentoStr = nextMonth.toIso8601String().substring(0, 10);

    final usersSnapshot = await _db.ref('usuarios').get();
    final residentsSnapshot = await _db.ref('moradores').get();

    if (!usersSnapshot.exists) {
      return;
    }

    final usersMap = usersSnapshot.value as Map? ?? {};
    final residentsMap = residentsSnapshot.value as Map? ?? {};

    final billsRef = _db.ref('boletos');

    // Verifica se o nó 'boletos' existe, se não, cria
    final billsSnapshot = await billsRef.get();
    if (!billsSnapshot.exists) {
      await billsRef.set({});
    }

    for (final entry in usersMap.entries) {
      final userData = entry.value;
      if (userData is! Map || _parseAtivo(userData['ativo']) != true) {
        continue;
      }

      final userUid = entry.key.toString();

      // Encontrar moradorId para este usuarioId no nó de moradores
      String? moradorId;
      residentsMap.forEach((mId, mData) {
        if (mData is Map && mData['usuarioId'] == userUid) {
          moradorId = mId.toString();
        }
      });

      if (moradorId != null) {
        // Verifica/cria o nó do morador dentro de boletos
        final moradorBillsRef = billsRef.child(moradorId!);
        final moradorSnapshot = await moradorBillsRef.get();
        if (!moradorSnapshot.exists) {
          await moradorBillsRef.set({});
        }

        // Estrutura: boletos/{moradorId}/{guid-firebase}
        await moradorBillsRef.push().set({
          'mesReferencia': mesReferenciaStr,
          'dataCriacao': dataCriacaoStr,
          'pagamentoRealizado': false,
          'vencimentoPagamento': vencimentoStr,
        });
      }
    }
  }

  bool _parseAtivo(dynamic value) {
    if (value == null) {
      return false;
    }
    if (value is bool) {
      return value;
    }
    if (value is String) {
      final v = value.toLowerCase();
      return v == 'sim' || v == 'true' || v == '1';
    }
    if (value is int) {
      return value == 1;
    }
    return false;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      try {
        // Se for formato yyyy-MM (mês de referência), adiciona dia 01
        if (value.length == 7 && value[4] == '-') {
          return DateTime.parse('$value-01');
        }
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

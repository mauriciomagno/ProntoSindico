class AreaComum {
  final String id;
  final String nome;
  final String descricao;
  final String imagem;
  final int capacidade;

  AreaComum({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.imagem,
    required this.capacidade,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'imagem': imagem,
      'capacidade': capacidade,
    };
  }

  factory AreaComum.fromMap(Map<dynamic, dynamic> map, String id) {
    return AreaComum(
      id: id,
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      imagem: map['imagem'] ?? '',
      capacidade: map['capacidade'] ?? 0,
    );
  }
}

class Reserva {
  final String? id;
  final String areaId;
  final String usuarioId;
  final String data;
  final String horario;
  final String status;

  Reserva({
    this.id,
    required this.areaId,
    required this.usuarioId,
    required this.data,
    required this.horario,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'areaId': areaId,
      'usuarioId': usuarioId,
      'data': data,
      'horario': horario,
      'status': status,
    };
  }

  factory Reserva.fromMap(Map<dynamic, dynamic> map, String id) {
    return Reserva(
      id: id,
      areaId: map['areaId'] ?? '',
      usuarioId: map['usuarioId'] ?? '',
      data: map['data'] ?? '',
      horario: map['horario'] ?? '',
      status: map['status'] ?? 'pendente',
    );
  }
}

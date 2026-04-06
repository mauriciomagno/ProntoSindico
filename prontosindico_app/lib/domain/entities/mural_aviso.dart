import 'package:flutter/material.dart';

enum MuralTag {
  importante,
  social,
  manutencao,
  informativo,
}

extension MuralTagExtension on MuralTag {
  String get label {
    switch (this) {
      case MuralTag.importante:
        return 'IMPORTANTE';
      case MuralTag.social:
        return 'SOCIAL';
      case MuralTag.manutencao:
        return 'MANUTENÇÃO';
      case MuralTag.informativo:
        return 'INFORMATIVO';
    }
  }

  Color get color {
    switch (this) {
      case MuralTag.importante:
        return const Color(0xFF334155);
      case MuralTag.social:
        return const Color(0xFF00D1FF);
      case MuralTag.manutencao:
        return const Color(0xFF0C91C9);
      case MuralTag.informativo:
        return const Color(0xFF64748B);
    }
  }
}

class MuralAviso {
  final String? id;
  final String title;
  final String description;
  final MuralTag tag;
  final String? time;
  final String? attachment;
  final DateTime createdAt;
  final String? authorId;

  const MuralAviso({
    this.id,
    required this.title,
    required this.description,
    required this.tag,
    this.time,
    this.attachment,
    required this.createdAt,
    this.authorId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'tag': tag.name,
      'time': time,
      'attachment': attachment,
      'createdAt': createdAt.toIso8601String(),
      'authorId': authorId,
    };
  }

  factory MuralAviso.fromMap(Map<dynamic, dynamic> map, String id) {
    return MuralAviso(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      tag: MuralTag.values.firstWhere(
        (e) => e.name == map['tag'],
        orElse: () => MuralTag.informativo,
      ),
      time: map['time'],
      attachment: map['attachment'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      authorId: map['authorId'],
    );
  }
}

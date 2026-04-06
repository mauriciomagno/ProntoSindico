class Comunicado {
  final String? id;
  final String title;
  final String description;
  final DateTime date;
  final String? author; // Nome do autor (SÍNDICO, etc.)
  final String? category; // Manutenção, Aviso Geral, etc.
  final bool? canNotify; // Notificar todos os moradores

  const Comunicado({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    this.author,
    this.category,
    this.canNotify,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'author': author,
      'category': category,
      'canNotify': canNotify,
    };
  }

  factory Comunicado.fromMap(Map<dynamic, dynamic> map, String id) {
    return Comunicado(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      author: map['author'],
      category: map['category'],
      canNotify: map['canNotify'],
    );
  }
}

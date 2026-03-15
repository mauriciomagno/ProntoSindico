import 'package:prontosindico/domain/entities/app_user.dart';

class Resident {
  final String? id; // ID do boleto
  final AppUser user;
  final String? apartment;
  final bool hasPaid;
  final DateTime? createdAt;

  const Resident({
    this.id,
    required this.user,
    this.apartment,
    required this.hasPaid,
    this.createdAt,
  });

  Resident copyWith({
    String? id,
    AppUser? user,
    String? apartment,
    bool? hasPaid,
    DateTime? createdAt,
  }) {
    return Resident(
      id: id ?? this.id,
      user: user ?? this.user,
      apartment: apartment ?? this.apartment,
      hasPaid: hasPaid ?? this.hasPaid,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

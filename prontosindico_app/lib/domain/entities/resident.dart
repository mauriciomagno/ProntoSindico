import 'package:prontosindico/domain/entities/app_user.dart';

class Resident {
  final AppUser user;
  final String? apartment;
  final bool hasPaid;

  const Resident({
    required this.user,
    this.apartment,
    required this.hasPaid,
  });

  Resident copyWith({
    AppUser? user,
    String? apartment,
    bool? hasPaid,
  }) {
    return Resident(
      user: user ?? this.user,
      apartment: apartment ?? this.apartment,
      hasPaid: hasPaid ?? this.hasPaid,
    );
  }
}

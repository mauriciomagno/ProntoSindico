import 'package:prontosindico/domain/enums/user_role.dart';

class AppUser {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final bool isActive;
  final String? photoUrl;
  final String? phone;

  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.isActive,
    this.photoUrl,
    this.phone,
  });
}

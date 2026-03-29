enum UserRole {
  administrador,
  tesoureiro,
  sindico,
  morador,
  funcionario,
  prestador;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name.toLowerCase() == value.toLowerCase(),
      orElse: () => UserRole.morador,
    );
  }
}

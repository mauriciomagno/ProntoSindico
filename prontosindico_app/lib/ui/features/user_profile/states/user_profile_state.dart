/// Estados da tela de edição de perfil do usuário.
sealed class UserProfileState {
  const UserProfileState();
}

final class UserProfileInitial extends UserProfileState {
  const UserProfileInitial();
}

final class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
}

final class UserProfileLoaded extends UserProfileState {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? photoUrl;

  const UserProfileLoaded({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.photoUrl,
  });

  UserProfileLoaded copyWith({
    String? name,
    String? phone,
    String? photoUrl,
    bool clearPhoto = false,
  }) {
    return UserProfileLoaded(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      role: role,
      photoUrl: clearPhoto ? null : (photoUrl ?? this.photoUrl),
    );
  }
}

final class UserProfileSaving extends UserProfileState {
  final UserProfileLoaded data;
  const UserProfileSaving(this.data);
}

final class UserProfileSaved extends UserProfileState {
  final UserProfileLoaded data;
  const UserProfileSaved(this.data);
}

final class UserProfileError extends UserProfileState {
  final String message;
  final UserProfileLoaded? previousData;
  const UserProfileError(this.message, {this.previousData});
}

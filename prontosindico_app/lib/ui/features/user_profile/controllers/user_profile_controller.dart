import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/domain/enums/user_role.dart';
import 'package:prontosindico/ui/features/user_profile/states/user_profile_state.dart';

class UserProfileController extends StateNotifier<UserProfileState> {
  late FirebaseAuth _auth;
  late DatabaseReference _usuariosRef;
  late FirebaseStorage _storage;

  UserProfileController() : super(const UserProfileInitial()) {
    _auth = FirebaseAuth.instance;
    _usuariosRef = FirebaseDatabase.instanceFor(
      app: FirebaseDatabase.instance.app,
      databaseURL: FirebaseDatabase.instance.app.options.databaseURL,
    ).ref('usuarios');
    _storage = FirebaseStorage.instance;
  }

  /// Carrega os dados do perfil do usuário autenticado.
  Future<void> loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      state = const UserProfileError('Usuário não autenticado.');
      return;
    }

    state = const UserProfileLoading();
    try {
      final snapshot = await _usuariosRef.child(user.uid).get();

      if (!snapshot.exists) {
        state =
            const UserProfileError('Perfil não encontrado no banco de dados.');
        return;
      }

      final raw = snapshot.value;
      if (raw == null || raw is! Map) {
        state = const UserProfileError('Dados de perfil inválidos.');
        return;
      }

      final data = Map<String, dynamic>.from(raw);
      final role = UserRole.fromString(data['role']?.toString() ?? 'morador');
      final photoUrl = (data['Foto']?.toString() ?? '').isNotEmpty
          ? data['Foto'].toString()
          : null;

      state = UserProfileLoaded(
        uid: user.uid,
        name: data['nome']?.toString() ?? '',
        email: data['email']?.toString() ?? user.email ?? '',
        phone: data['telefone']?.toString() ?? '',
        role: _roleLabel(role),
        photoUrl: photoUrl,
      );
    } catch (e, stack) {
      debugPrint('[UserProfileController] loadProfile ERROR: $e\n$stack');
      state = UserProfileError('Erro ao carregar perfil: ${e.toString()}');
    }
  }

  /// Salva nome e telefone no Realtime Database.
  Future<void> saveProfile({
    required String name,
    required String phone,
  }) async {
    final current = _currentLoaded();
    if (current == null) return;

    state = UserProfileSaving(current);
    try {
      await _usuariosRef.child(current.uid).update({
        'nome': name,
        'telefone': phone,
      });

      final updated = current.copyWith(name: name, phone: phone);
      state = UserProfileSaved(updated);
    } catch (e, stack) {
      debugPrint('[UserProfileController] saveProfile ERROR: $e\n$stack');
      state = UserProfileError(
        'Erro ao salvar perfil: ${e.toString()}',
        previousData: current,
      );
    }
  }

  /// Faz upload da foto para Firebase Storage e atualiza o banco.
  Future<void> updatePhoto(File photo) async {
    final current = _currentLoaded();
    if (current == null) return;

    state = UserProfileSaving(current);
    try {
      final ref = _storage.ref('profile_photos/${current.uid}.jpg');
      await ref.putFile(
        photo,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final downloadUrl = await ref.getDownloadURL();

      await _usuariosRef.child(current.uid).update({'Foto': downloadUrl});

      final updated = current.copyWith(photoUrl: downloadUrl);
      state = UserProfileSaved(updated);
    } catch (e, stack) {
      debugPrint('[UserProfileController] updatePhoto ERROR: $e\n$stack');
      state = UserProfileError(
        'Erro ao atualizar foto: ${e.toString()}',
        previousData: current,
      );
    }
  }

  UserProfileLoaded? _currentLoaded() {
    final s = state;
    if (s is UserProfileLoaded) return s;
    if (s is UserProfileSaving) return s.data;
    if (s is UserProfileSaved) return s.data;
    if (s is UserProfileError) return s.previousData;
    return null;
  }

  static String _roleLabel(UserRole role) {
    return switch (role) {
      UserRole.administrador => 'Administrador',
      UserRole.sindico => 'Síndico',
      UserRole.morador => 'Morador',
      UserRole.funcionario => 'Funcionário',
      UserRole.prestador => 'Prestador',
    };
  }
}

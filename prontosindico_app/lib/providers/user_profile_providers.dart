import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/screens/usuarios/controllers/user_profile_controller.dart';
import 'package:prontosindico/screens/usuarios/states/user_profile_state.dart';

final userProfileControllerProvider =
    StateNotifierProvider.autoDispose<UserProfileController, UserProfileState>(
  (ref) => UserProfileController(),
);

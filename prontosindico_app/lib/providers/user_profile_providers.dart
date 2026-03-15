import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/ui/features/user_profile/controllers/user_profile_controller.dart';
import 'package:prontosindico/ui/features/user_profile/states/user_profile_state.dart';

final userProfileControllerProvider =
    NotifierProvider.autoDispose<UserProfileController, UserProfileState>(
  UserProfileController.new,
);

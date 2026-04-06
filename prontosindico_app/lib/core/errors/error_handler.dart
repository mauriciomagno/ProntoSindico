import 'package:firebase_auth/firebase_auth.dart';
import 'error_messages.dart';

class ErrorHandler {
  /// Converte uma exceção ou código de erro em uma mensagem amigável para o usuário.
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return _handleAuthException(error);
    } else if (error is FirebaseException) {
      return _handleFirebaseException(error);
    } else if (error is Exception) {
      // Pode adicionar outros tipos de exceção aqui (ex: DioException para APIs)
      return ErrorMessages.defaultError;
    }

    return ErrorMessages.unknownError;
  }

  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return ErrorMessages.invalidEmail;
      case 'user-disabled':
        return ErrorMessages.userDisabled;
      case 'user-not-found':
        return ErrorMessages.userNotFound;
      case 'wrong-password':
        return ErrorMessages.wrongPassword;
      case 'email-already-in-use':
        return ErrorMessages.emailAlreadyInUse;
      case 'operation-not-allowed':
        return ErrorMessages.operationNotAllowed;
      case 'weak-password':
        return ErrorMessages.weakPassword;
      case 'network-request-failed':
        return ErrorMessages.networkRequestFailed;
      case 'too-many-requests':
        return ErrorMessages.tooManyRequests;
      default:
        return ErrorMessages.defaultError;
    }
  }

  static String _handleFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return ErrorMessages.permissionDenied;
      case 'unavailable':
        return ErrorMessages.unavailable;
      case 'not-found':
        return ErrorMessages.notFound;
      default:
        return ErrorMessages.defaultError;
    }
  }
}

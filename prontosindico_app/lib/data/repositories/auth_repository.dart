import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:prontosindico/domain/entities/app_user.dart';
import 'package:prontosindico/domain/enums/user_role.dart';
import 'package:prontosindico/domain/repositories/i_auth_repository.dart';

class AuthRepository implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final DatabaseReference _usuariosRef;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    DatabaseReference? usuariosRef,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              serverClientId:
                  '253104354974-2mm2b22kn4s3atkfcenv856k4fho66ef.apps.googleusercontent.com',
            ),
        _usuariosRef = usuariosRef ??
            FirebaseDatabase.instanceFor(
              app: FirebaseDatabase.instance.app,
              databaseURL: FirebaseDatabase.instance.app.options.databaseURL,
            ).ref('usuarios') {
    final dbUrl = FirebaseDatabase.instance.app.options.databaseURL;
    debugPrint('[AuthRepository] Using databaseURL: $dbUrl');
  }

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<AppUser?> signInWithGoogle() async {
    final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();
    if (googleAccount == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    debugPrint('[AuthRepository] signInWithCredential success');
    final User? firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      debugPrint('[AuthRepository] firebaseUser is null');
      return null;
    }

    debugPrint('[AuthRepository] Persisting new user: ${firebaseUser.uid}');
    try {
      await _persistNewUser(firebaseUser);
      debugPrint('[AuthRepository] Persistence complete, fetching data...');
      return fetchUserData(firebaseUser.uid);
    } catch (e) {
      debugPrint('[AuthRepository] Error during post-login flow: $e');
      rethrow;
    }
  }

  @override
  Future<AppUser?> signInWithEmailAndPassword(
      String email, String password) async {
    final UserCredential userCredential =
        await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final User? firebaseUser = userCredential.user;
    if (firebaseUser == null) return null;

    return fetchUserData(firebaseUser.uid);
  }

  @override
  Future<AppUser?> fetchUserData(String uid) async {
    try {
      final snapshot = await _usuariosRef.child(uid).get();
      if (!snapshot.exists) {
        debugPrint(
            '[AuthRepository] fetchUserData: nó não encontrado para uid=$uid');
        return null;
      }

      final raw = snapshot.value;
      if (raw == null || raw is! Map) {
        debugPrint(
            '[AuthRepository] fetchUserData: valor inesperado para uid=$uid → $raw');
        return null;
      }

      final data = Map<String, dynamic>.from(raw);
      debugPrint('[AuthRepository] fetchUserData: dados=$data');

      final role = UserRole.fromString(data['role']?.toString() ?? 'morador');
      final isActive =
          role == UserRole.administrador || _parseAtivo(data['ativo']);

      debugPrint(
          '[AuthRepository] fetchUserData: role=$role, isActive=$isActive');

      return AppUser(
        uid: uid,
        email: data['email']?.toString() ?? '',
        name: data['nome']?.toString() ?? '',
        role: role,
        isActive: isActive,
        photoUrl: (data['Foto']?.toString() ?? '').isNotEmpty
            ? data['Foto'].toString()
            : null,
        phone: data['telefone']?.toString(),
      );
    } catch (e, stack) {
      debugPrint('[AuthRepository] fetchUserData ERROR: $e\n$stack');
      rethrow;
    }
  }

  @override
  Stream<AppUser?> watchUserData(String uid) {
    return _usuariosRef.child(uid).onValue.map((event) {
      final raw = event.snapshot.value;
      if (raw == null || raw is! Map) return null;

      final data = Map<String, dynamic>.from(raw);
      final role = UserRole.fromString(data['role']?.toString() ?? 'morador');
      final isActive =
          role == UserRole.administrador || _parseAtivo(data['ativo']);

      return AppUser(
        uid: uid,
        email: data['email']?.toString() ?? '',
        name: data['nome']?.toString() ?? '',
        role: role,
        isActive: isActive,
        photoUrl: (data['Foto']?.toString() ?? '').isNotEmpty
            ? data['Foto'].toString()
            : null,
        phone: data['telefone']?.toString(),
      );
    });
  }

  static bool _parseAtivo(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'sim';
    if (value is int) return value == 1;
    return false;
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _googleSignIn.signOut(),
      _firebaseAuth.signOut(),
    ]);
  }

  /// Persiste o usuário no banco apenas se for a primeira vez (novo cadastro).
  Future<void> _persistNewUser(User firebaseUser) async {
    final userRef = _usuariosRef.child(firebaseUser.uid);
    final event = await userRef.once();
    if (event.snapshot.exists) return;

    // Dynamic Admin Check
    bool isAdmin = false;
    try {
      debugPrint('[AuthRepository] Checking admin status for ${firebaseUser.email}');
      final adminsSnapshot = await _usuariosRef.parent!.child('config/admins').get().timeout(const Duration(seconds: 5));
      if (adminsSnapshot.exists) {
        final adminsData = adminsSnapshot.value;
        debugPrint('[AuthRepository] Admins node found: $adminsData');
        if (adminsData is Map) {
          isAdmin = adminsData.values.contains(firebaseUser.email);
        } else if (adminsData is List) {
          isAdmin = adminsData.contains(firebaseUser.email);
        }
      } else {
        debugPrint('[AuthRepository] No config/admins node found');
      }
    } catch (e) {
      debugPrint('[AuthRepository] Error fetching admins (ignoring): $e');
    }

    final String role = isAdmin ? 'administrador' : 'morador';
    debugPrint('[AuthRepository] Persisting as role: $role');

    await userRef.set({
      'email': firebaseUser.email ?? '',
      'nome': firebaseUser.displayName ?? '',
      'role': role,
      'ativo': true, // Temporariamente true para facilitar testes e garantir redirecionamento
    });
    debugPrint('[AuthRepository] User persisted successfully');
  }
}

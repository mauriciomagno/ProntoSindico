import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '253104354974-2mm2b22kn4s3atkfcenv856k4fho66ef.apps.googleusercontent.com',
  );
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
      app: FirebaseDatabase.instance.app,
      databaseURL: 'https://prontosindico-59bd4-default-rtdb.firebaseio.com');

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        await _saveUserToDatabase(user);
      }

      return user;
    } catch (e) {
      log("Error during Google Sign-In: $e");
      rethrow;
    }
  }

  Future<void> _saveUserToDatabase(User user) async {
    final String uid = user.uid;
    final DatabaseReference userRef = _database.ref("usuarios/$uid");

    // Check if user already exists so we don't overwrite their 'Ativo' status
    final DatabaseEvent event = await userRef.once();
    if (event.snapshot.exists) {
      return;
    }

    final String email = user.email ?? "";
    final String name = user.displayName ?? "";

    // Dynamic Admin Check
    bool isAdmin = false;
    try {
      final adminsSnapshot = await _database.ref("config/admins").get();
      if (adminsSnapshot.exists) {
        final adminsData = adminsSnapshot.value;
        if (adminsData is Map) {
          isAdmin = adminsData.values.contains(email);
        } else if (adminsData is List) {
          isAdmin = adminsData.contains(email);
        }
      }
    } catch (e) {
      log("Error fetching admin config: $e");
    }

    String role = isAdmin ? "administrador" : "morador";

    await userRef.set({
      "email": email,
      "nome": name,
      "role": role,
      "ativo": "Não",
    });
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

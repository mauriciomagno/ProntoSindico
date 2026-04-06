import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RoleBasedWrapper extends StatelessWidget {
  final Widget child;
  final String requiredRole;

  const RoleBasedWrapper({
    super.key,
    required this.child,
    required this.requiredRole,
  });

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Should not happen if this widget is used behind an auth wall,
      // but as a fallback, deny access.
      return const _AccessDeniedWidget();
    }

    return FutureBuilder<DataSnapshot>(
      future:
          FirebaseDatabase.instance.ref('usuarios/${currentUser.uid}').get(),
      builder: (BuildContext context, AsyncSnapshot<DataSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          // Handle error or user not in database
          return const _AccessDeniedWidget(
            message: "Erro ao verificar permissões ou usuário não encontrado.",
          );
        }

        final userData = snapshot.data!.value as Map<dynamic, dynamic>?;
        final userRole = userData?['role'] as String?;

        if (userRole == requiredRole) {
          return child;
        } else {
          return const _AccessDeniedWidget();
        }
      },
    );
  }
}

class _AccessDeniedWidget extends StatelessWidget {
  final String message;

  const _AccessDeniedWidget({
    this.message = "Você não tem permissão para acessar esta área.",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Acesso Negado"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      ),
    );
  }
}

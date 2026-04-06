import 'package:flutter/material.dart';
import '../constants.dart';

class ErrorDisplayWidget {
  /// Exibe um SnackBar customizado com a mensagem de erro.
  static void showSnackBar(BuildContext context, String message) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Remove qualquer SnackBar ativo antes de mostrar o novo
    scaffoldMessenger.hideCurrentSnackBar();

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: defaultPadding / 2),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadious),
        ),
        margin: const EdgeInsets.all(defaultPadding),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: "OK",
          textColor: Colors.white,
          onPressed: () {
            scaffoldMessenger.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Retorna um widget simples para exibir erro em listas ou áreas específicas da UI.
  static Widget errorPlaceholder({required String message, VoidCallback? onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: errorColor,
              size: 48,
            ),
            const SizedBox(height: defaultPadding),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: blackColor80,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: defaultPadding),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text("Tentar Novamente"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

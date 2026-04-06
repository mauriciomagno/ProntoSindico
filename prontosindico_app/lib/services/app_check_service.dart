import 'dart:async';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:prontosindico/config/app_config.dart';

/// Serviço para gerenciar Firebase App Check
/// Fornece debug logging e monitoramento do status
class AppCheckService {
  static final AppCheckService _instance = AppCheckService._internal();

  factory AppCheckService() {
    return _instance;
  }

  AppCheckService._internal();

  bool _isInitialized = false;
  late AppConfig _appConfig;
  StreamSubscription<String?>? _tokenStream;

  bool get isInitialized => _isInitialized;

  /// Inicializar App Check com logging detalhado
  Future<void> initialize(AppConfig appConfig) async {
    if (_isInitialized) {
      debugPrint('[AppCheck] ⚠️ Já foi inicializado anteriormente');
      return;
    }

    _appConfig = appConfig;

    try {
      // ignore: deprecated_member_use
      await FirebaseAppCheck.instance.activate(
        // ignore: deprecated_member_use
        androidProvider: appConfig.isProduction
            ? AndroidProvider.playIntegrity
            : AndroidProvider.debug,
        // ignore: deprecated_member_use
        appleProvider: appConfig.isProduction
            ? AppleProvider.deviceCheck
            : AppleProvider.debug,
      );

      _isInitialized = true;

      _logDebugInfo();
      _setupTokenListener();

      debugPrint('[AppCheck] ✅ Inicializado com SUCESSO');
    } catch (e, stackTrace) {
      debugPrint('[AppCheck] ❌ Erro na inicialização: $e');
      debugPrint(stackTrace.toString());
    }
  }

  /// Obter token do App Check
  Future<String?> getAppCheckToken() async {
    if (!_isInitialized) {
      debugPrint('[AppCheck] ⚠️ Serviço não inicializado');
      return null;
    }

    try {
      final token = await FirebaseAppCheck.instance.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint('[AppCheck] 🔐 Token obtido (${token.substring(0, 20)}...)');
        return token;
      } else {
        debugPrint('[AppCheck] ⚠️ Token obtido mas vazio');
        return null;
      }
    } catch (e) {
      debugPrint('[AppCheck] ❌ Erro ao obter token: $e');
      return null;
    }
  }

  /// Refresh do token
  Future<String?> refreshAppCheckToken() async {
    if (!_isInitialized) {
      debugPrint('[AppCheck] ⚠️ Serviço não inicializado');
      return null;
    }

    try {
      final token = await FirebaseAppCheck.instance.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint('[AppCheck] 🔄 Token atualizado com sucesso');
        return token;
      } else {
        debugPrint('[AppCheck] ⚠️ Token de refresh vazio');
        return null;
      }
    } catch (e) {
      debugPrint('[AppCheck] ❌ Erro ao atualizar token: $e');
      return null;
    }
  }

  /// Logging detalhado das configurações
  void _logDebugInfo() {
    debugPrint('''
    ╔════════════════════════════════════════════════════════════╗
    ║          🔐 FIREBASE APP CHECK - INICIALIZADO            ║
    ╠════════════════════════════════════════════════════════════╣
    ║ Status: ✅ ATIVO
    ║ Modo: ${_appConfig.appCheckMode}
    ║ Ambiente: ${_appConfig.flavor.name.toUpperCase()}
    ║
    ║ Providers:
    ║ • Android: ${_appConfig.androidProvider}
    ║ • Apple:  ${_appConfig.appleProvider}
    ║
    ║ Configuração:
    ║ • Firebase Project: ${_appConfig.firebaseProjectId}
    ║ • É Produção: ${_appConfig.isProduction}
    ║ • Debug Mode: ${!_appConfig.isProduction}
    ╚════════════════════════════════════════════════════════════╝
    ''');
  }

  /// Setup listener para mudanças de token
  void _setupTokenListener() {
    _tokenStream = FirebaseAppCheck.instance.onTokenChange.listen(
      (token) {
        if (token != null && token.isNotEmpty && token.length >= 30) {
          debugPrint('[AppCheck] 🔑 Novo token gerado');
          debugPrint('[AppCheck] Token: ${token.substring(0, 30)}...');
        } else if (token != null) {
          debugPrint(
              '[AppCheck] 🔑 Novo token gerado (tamanho: ${token.length})');
        } else {
          debugPrint('[AppCheck] 🔑 Novo token gerado (vazio)');
        }
      },
      onError: (error) {
        debugPrint('[AppCheck] ❌ Erro no listener de token: $error');
      },
    );
  }

  /// Cleanup do serviço
  void dispose() {
    _tokenStream?.cancel();
    _isInitialized = false;
  }
}

// Configuração centralizada de ambiente da aplicação
enum Environment {
  dev,
  hml,
  prod,
}

// Classe que agrupa todas as configurações específicas do ambiente
class AppConfig {
  final String appTitle;
  final String apiBaseUrl;
  final Environment flavor;
  final String firebaseProjectId;
  final bool enableDebugBanner;
  final bool isProduction;
  final String appCheckMode;
  final String androidProvider;
  final String appleProvider;
  final String firebaseApiKey;
  final String firebaseAppId;
  final String firebaseMessagingSenderId;

  const AppConfig({
    required this.appTitle,
    required this.apiBaseUrl,
    required this.flavor,
    required this.firebaseProjectId,
    required this.enableDebugBanner,
    required this.isProduction,
    this.appCheckMode = 'DEBUG',
    this.androidProvider = 'debug',
    this.appleProvider = 'debug',
    required this.firebaseApiKey,
    required this.firebaseAppId,
    required this.firebaseMessagingSenderId,
  });


  /// Factory constructor que determina a configuração baseado no Dart Define
  factory AppConfig.fromEnvironment() {
    const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'prod');
    const String appTitle = String.fromEnvironment('APP_TITLE', defaultValue: 'ProntoSindico');
    const String apiBaseUrl = String.fromEnvironment('API_URL', defaultValue: '');
    const String firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'prontosindico-59bd4');
    const String firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
    const String firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
    const String firebaseMessagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '253104354974');
    const String enableDebugBanner = String.fromEnvironment('ENABLE_DEBUG_BANNER', defaultValue: 'true');
    const String isProduction = String.fromEnvironment('IS_PRODUCTION', defaultValue: 'false');


    final Environment environment = Environment.values.firstWhere(
      (e) => e.name == flavor.toLowerCase(),
      orElse: () => Environment.prod,
    );

    // Determinar providers do App Check baseado no ambiente
    final isProd = isProduction.toLowerCase() == 'true' || environment == Environment.prod;
    final appCheckMode = isProd ? 'PRODUCTION' : 'DEBUG';
    final androidProvider = isProd ? 'Play Integrity' : 'Debug';
    final appleProvider = isProd ? 'Device Check' : 'Debug';

    return AppConfig(
      appTitle: appTitle,
      apiBaseUrl: apiBaseUrl,
      flavor: environment,
      firebaseProjectId: firebaseProjectId,
      enableDebugBanner: enableDebugBanner.toLowerCase() == 'true',
      isProduction: isProd,
      appCheckMode: appCheckMode,
      androidProvider: androidProvider,
      appleProvider: appleProvider,
      firebaseApiKey: firebaseApiKey,
      firebaseAppId: firebaseAppId,
      firebaseMessagingSenderId: firebaseMessagingSenderId,
    );
  }


  /// Getter para verificar rapidamente o ambiente
  bool get isDev => flavor == Environment.dev;
  bool get isHml => flavor == Environment.hml;
  bool get isProd => flavor == Environment.prod;

  /// Getter para obter informações de App Check formatadas
  String get appCheckDebugInfo {
    return '''
    ╔════════════════════════════════════════════════════════════╗
    ║          🔐 FIREBASE APP CHECK - DEBUG INFO               ║
    ╠════════════════════════════════════════════════════════════╣
    ║ Modo: $appCheckMode
    ║ Status: ${isProduction ? '🔒 PRODUÇÃO' : '🐛 DESENVOLVIMENTO'}
    ║ 
    ║ Providers Configurados:
    ║ • Android: $androidProvider
    ║ • Apple:  $appleProvider
    ║
    ║ Detalhes:
    ║ • Ambiente: ${flavor.name.toUpperCase()}
    ║ • Firebase Project: $firebaseProjectId
    ║ • É Produção: $isProduction
    ╚════════════════════════════════════════════════════════════╝
    ''';
  }

  /// Debug string para logs
  @override
  String toString() {
    return '''
    ╔════════════════════════════════════════════════════════════╗
    ║          🚀 CONFIGURAÇÃO DO AMBIENTE CARREGADA            ║
    ╠════════════════════════════════════════════════════════════╣
    ║ Título: $appTitle
    ║ Ambiente: ${flavor.name.toUpperCase()}
    ║ Produção: $isProduction
    ║ Debug Banner: $enableDebugBanner
    ║ Firebase Project: $firebaseProjectId
    ║ API Base URL: ${apiBaseUrl.isEmpty ? 'Não configurada' : apiBaseUrl}
    ╠════════════════════════════════════════════════════════════╣
    ║          🔐 FIREBASE APP CHECK                            ║
    ║ Modo: $appCheckMode
    ║ Android Provider: $androidProvider
    ║ Apple Provider: $appleProvider
    ╚════════════════════════════════════════════════════════════╝
    ''';
  }
}

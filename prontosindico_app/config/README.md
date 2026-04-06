# Configurações do Ambiente - ProntoSíndico

Esta pasta contém os arquivos de configuração para cada ambiente de execução do aplicativo.

## 📁 Arquivos

### `config_dev.json`

Configuração para o ambiente de **Desenvolvimento (DEV)**

- Uso: Desenvolvimento local e testes
- Debug banner habilitado
- API de desenvolvimento

### `config_hml.json`

Configuração para o ambiente de **Homologação (HML)**

- Uso: Testes de validação e QA
- Ambiente de staging
- API de homologação

### `config_prod.json`

Configuração para o ambiente de **Produção (PROD)**

- Uso: App publicado na loja (Google Play / App Store)
- Debug banner desabilitado
- API de produção

## 🔧 Como Usar

### Durante o desenvolvimento:

Os arquivos de configuração são carregados automaticamente baseado no flavor selecionado:

```bash
# Desenvolvimento
flutter run --flavor dev

# Homologação
flutter run --flavor hml

# Produção
flutter run --flavor prod
```

### Build para release:

```bash
# Android - Homologação
flutter build apk --flavor hml --release

# Android - Produção
flutter build apk --flavor prod --release

# iOS - Produção
flutter build ios --flavor prod --release
```

## ⚙️ Estrutura dos Arquivos

```json
{
  "FLAVOR": "dev|hml|prod",
  "APP_TITLE": "Nome do app com indicador de ambiente",
  "API_URL": "URL da API do backend",
  "FIREBASE_PROJECT_ID": "ID do projeto Firebase",
  "FIREBASE_APP_ID": "ID específico do app (Android/iOS)",
  "FIREBASE_API_KEY": "Chave da API Firebase",
  "FIREBASE_MESSAGING_SENDER_ID": "ID do sender FCM",
  "ENABLE_DEBUG_BANNER": "true|false",
  "IS_PRODUCTION": "true|false"
}
```

## 🔒 Segurança

- ⚠️ **NÃO** commite chaves de API privadas ou tokens secretos
- Os arquivos atuais contêm apenas configurações públicas
- Para dados sensíveis, use variáveis de ambiente ou arquivos `.env` (não versionados)

## 📝 Notas

- Todos os IDs Firebase devem corresponder aos registrados no Firebase Console
- Mantenha sincronizados com os arquivos `google-services.json` (Android) e `GoogleService-Info.plist` (iOS)
- As configurações de produção devem ser rigorosamente testadas antes do release

## 🔄 Última Atualização

**Data**: 06/04/2026
**Versão**: 1.0.0 - Organização de arquivos de configuração

# ProntoSíndico

Aplicativo completo para administração de condomínios, desenvolvido em Flutter com Firebase, seguindo as melhores práticas de mercado e arquitetura limpa.

## 📱 Sobre o Projeto

O ProntoSíndico é uma solução mobile que facilita a gestão de condomínios, oferecendo ferramentas para comunicação, finanças, reservas, ocorrências e muito mais. O app atende diferentes perfis de usuários:

- **Síndico** — Gestão completa do condomínio
- **Administrador** — Suporte administrativo
- **Tesoureiro** — Suporte administrativo financeiro
- **Moradores** — Acesso a informações e serviços
- **Portaria** — Controle de acesso e visitantes
- **Prestadores** — Agendamento e serviços

📝 Resumo das Permissões

## usuarios

✅ Admin/Síndico: Lista TODOS os usuários (raiz)
✅ Usuário: Lê apenas o próprio perfil ($uid)
✅ Admin/Síndico: Edita qualquer perfil
✅ Usuário: Edita apenas o próprio perfil

## boletos

✅ Síndico/Administrador/Tesoureiro: Lê TODOS os boletos (raiz e filhos)
✅ Morador: Lê apenas os próprios boletos
✅ Síndico/Administrador/Tesoureiro: Cria/edita qualquer boleto

## moradores

✅ Todos autenticados: Podem ler
✅ Apenas Admin: Pode editar

## config

✅ Todos autenticados: Podem ler
✅ Apenas Admin: Pode editar

## 🚀 Tecnologias

### Core Stack

- **Flutter** (3.24.0) + **Dart** (3.5.0)
- **Firebase** (Authentication, Firestore, Storage, Messaging, Crashlytics)
- **Riverpod** + **StateNotifier** para gerenciamento de estado
- **Freezed** para classes imutáveis
- **GoRouter** para navegação

## 🔐 Firebase App Check - Debug Token

### Por que preciso do Debug Token?

O Firebase App Check protege sua API de acesso não autorizado. Em modo debug, você precisa registrar o token do seu dispositivo de desenvolvimento no Firebase Console.

### Como obter o Debug Token:

#### Opção 1: Via Script Automático (RECOMENDADO)

**Windows (PowerShell):**

```powershell
.\get_appcheck_token.ps1
```

**Windows (CMD):**

```cmd
get_appcheck_token.bat
```

#### Opção 2: Manualmente via ADB

**Windows:**

```powershell
adb logcat -s DebugAppCheckProvider:I | Select-String "token"
```

**Linux/Mac:**

```bash
adb logcat -s DebugAppCheckProvider:I | grep "token"
```

#### Opção 3: Procurar nos Logs do App

1. Execute o app no dispositivo/emulador
2. Procure no console por: **"Enter this debug token into the allow list"**
3. O token aparecerá logo abaixo dessa mensagem

### Como registrar o token no Firebase:

1. Acesse: [Firebase Console](https://console.firebase.google.com/)
2. Selecione seu projeto
3. Vá em: **App Check** → **Apps** → Seu app Android
4. Clique em: **"Manage debug tokens"** (Gerenciar tokens de depuração)
5. Clique em **"Add debug token"** (Adicionar token de depuração)
6. Cole o token copiado e salve

⚠️ **IMPORTANTE**: O token é específico para cada dispositivo/emulador. Se trocar de dispositivo, precisa gerar um novo token.

### Principais Pacotes

```yaml
# Firebase
firebase_core: ^2.24.2
firebase_auth: ^4.16.0
cloud_firestore: ^4.14.0
firebase_storage: ^11.6.0
firebase_messaging: ^14.7.10
firebase_crashlytics: ^3.4.9

# Estado
flutter_riverpod: ^2.4.9
freezed_annotation: ^2.4.1

# UI/UX
google_fonts: ^6.1.0
flutter_svg: ^2.0.9
shimmer: ^3.0.0
animations: ^2.0.10

# Utilitários
go_router: ^14.0.0
hive_flutter: ^1.1.0
connectivity_plus: ^5.0.2
image_picker: ^1.0.5
intl: ^0.18.1

lib/
├── core/                      # Configurações centrais
│   ├── auth/                  # Autenticação e perfis
│   ├── firebase/              # Configuração Firebase
│   │   ├── firebase_options_dev.dart
│   │   ├── firebase_options_hml.dart
│   │   └── firebase_options_prod.dart
│   ├── notifications/          # Push notifications
│   └── theme/                  # Temas claro/escuro
│
├── data/                        # Camada de dados
│   ├── models/                  # Modelos Freezed
│   │   ├── user_model.dart
│   │   ├── aviso_model.dart
│   │   ├── reserva_model.dart
│   │   └── ...
│   ├── repositories/            # Repositórios
│   │   ├── aviso_repository.dart
│   │   ├── reserva_repository.dart
│   │   └── ...
│   └── services/                # Serviços
│       ├── firestore_service.dart
│       ├── storage_service.dart
│       └── hive_service.dart
│
├── domain/                       # Camada de domínio
│   ├── entities/                 # Entidades
│   ├── enums/                    # Enums
│   │   ├── user_role.dart
│   │   ├── reserva_status.dart
│   │   └── ...
│   └── usecases/                 # Casos de uso
│
├── providers/                     # Riverpod providers
│   ├── auth_provider.dart
│   ├── connectivity_provider.dart
│   └── repository_providers.dart
│
├── routing/                       # Roteamento
│   └── router.dart
│
├── ui/                            # Camada de apresentação
│   ├── core/                      # Componentes reutilizáveis
│   │   ├── widgets/
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_card.dart
│   │   │   ├── loading_shimmer.dart
│   │   │   └── ...
│   │   └── themes/
│   │
│   └── features/                   # Features por módulo
│       ├── auth/
│       │   ├── controllers/
│       │   ├── states/
│       │   └── views/
│       ├── dashboard/
│       ├── comunicacao/
│       │   ├── avisos/
│       │   ├── chat/
│       │   └── enquetes/
│       ├── financeiro/
│       ├── reservas/
│       ├── ocorrencias/
│       ├── documentos/
│       ├── seguranca/
│       ├── prestadores/
│       └── profile/
│
└── utils/                          # Utilitários
    ├── extensions/
    ├── formatters/
    └── validators/

	🏗️ Arquitetura
Clean Architecture + MVVM

O projeto segue os princípios da Clean Architecture, organizada em camadas:

    Domain — Regras de negócio e entidades (independente)

    Data — Implementações concretas (repositórios, serviços)

    Presentation — UI com padrão MVVM via Riverpod

Padrões Implementados
Repository Pattern

abstract class AvisoRepository {
  Stream<List<Aviso>> getAvisos();
  Future<void> createAviso(Aviso aviso);
  Future<void> updateAviso(Aviso aviso);
  Future<void> deleteAviso(String id);
}

class FirebaseAvisoRepository implements AvisoRepository {
  final FirebaseFirestore _firestore;

  @override
  Stream<List<Aviso>> getAvisos() {
    return _firestore
        .collection('avisos')
        .orderBy('dataCriacao', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Aviso.fromJson(doc.data()))
            .toList());
  }
}

StateNotifier + Freezed

// states/aviso_state.dart
@freezed
class AvisoState with _$AvisoState {
  const factory AvisoState.initial() = _Initial;
  const factory AvisoState.loading() = _Loading;
  const factory AvisoState.loaded(List<Aviso> avisos) = _Loaded;
  const factory AvisoState.error(String message) = _Error;
}

// controllers/aviso_controller.dart
class AvisoController extends StateNotifier<AvisoState> {
  AvisoController(this._repository) : super(const AvisoState.initial());

  final AvisoRepository _repository;

  Future<void> loadAvisos() async {
    state = const AvisoState.loading();
    try {
      final avisos = await _repository.getAvisos().first;
      state = AvisoState.loaded(avisos);
    } catch (e) {
      state = AvisoState.error(e.toString());
    }
  }
}

## 🔐 Firebase Configuration

### Único Firebase Project

O projeto usa um **único Firebase Project** (`prontosindico-59bd4`) para todos os ambientes.

```

firebase_options.dart → Configuração centralizada (mesmo para dev, hml, prod)

```

**Vantagens**:
- ✅ Dados do dev/staging não descartados ao deletar projects
- ✅ Mesma base de dados para todos os ambientes
- ✅ Menos complexity no Firebase Console
- ✅ App Check usa `projectId` único

### Google Services JSON por Flavor

O Gradle seleciona automaticamente o arquivo correto:

```

android/app/src/
├── dev/
│ └── google-services.json # Bundle ID: com.prontosindico.prontosindico.dev
├── hml/
│ └── google-services.json # Bundle ID: com.prontosindico.prontosindico.hml
└── prod/
└── google-services.json # Bundle ID: com.prontosindico.prontosindico

````

Cada arquivo tem seu próprio `package_name` para garantir instalação simultânea em teste:
- **DEV**: `com.prontosindico.prontosindico.dev`
- **HML**: `com.prontosindico.prontosindico.hml`
- **PROD**: `com.prontosindico.prontosindico`

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }

    function getUserRole(condominioId) {
      return get(/databases/$(database)/documents/condominios/$(condominioId)/usuarios/$(request.auth.uid)).data.perfil;
    }

    match /condominios/{condominioId} {
      allow read: if isAuthenticated();

      match /avisos/{avisoId} {
        allow read: if isAuthenticated();
        allow write: if isAuthenticated() && getUserRole(condominioId) in ['sindico', 'administrador'];
      }

      match /reservas/{reservaId} {
        allow read: if isAuthenticated();
        allow create: if isAuthenticated() && getUserRole(condominioId) in ['morador', 'sindico'];
        allow update: if isAuthenticated() && (
          resource.data.usuarioId == request.auth.uid ||
          getUserRole(condominioId) == 'sindico'
        );
      }
    }
  }
}

Firebase Indexes

Configure os índices necessários no Firestore para consultas otimizadas.
## 🚦 Ambientes

O projeto utiliza **Flutter Flavors** combinado com **Dart Define** para gerenciar múltiplos ambientes (DEV, HML, PROD) de forma profissional e segura.

### Diferenças Entre Ambientes

| Aspecto | Config | Onde |
|--------|--------|------|
| **API Backend URL** | Diferente | `config_*.json` |
| **App Title/Label** | Diferente | `config_*.json` |
| **Debug Banner** | Ativado em DEV/HML | `config_*.json` |
| **App Check Mode** | Debug em DEV/HML, Production em PROD | `main.dart` |
| **Firebase Project** | **MESMO para todos** | `firebase_options.dart` |
| **Google Services JSON** | Automático via Flavor | `android/app/src/{flavor}/` |

### Estrutura de Variáveis (config_*.json)

Cada ambiente tem seu próprio arquivo JSON com variáveis:

```json
{
  "FLAVOR": "dev",
  "APP_TITLE": "ProntoSindico (DEV)",
  "API_URL": "https://dev-api.prontosindico.com",
  "ENABLE_DEBUG_BANNER": "true",
  "IS_PRODUCTION": "false"
}
````

**Nota**: O `FIREBASE_PROJECT_ID` é informativo apenas - o Firebase usa o projeto único definido em `firebase_options.dart`

📦 Instalação
Pré-requisitos
Flutter SDK (3.24.0 ou superior)
Dart SDK (3.5.0 ou superior)
Firebase CLI (para desenvolvimento)
url: https://prontosindico-59bd4-default-rtdb.firebaseio.com
Android Studio / Xcode (para emuladores)

Passos
Clone o repositório

git clone https://github.com/seu-org/prontosindico.git
cd prontosindico

flutter pub get

Configure o Firebase
Crie projetos no Firebase Console para cada ambiente
Baixe os arquivos de configuração:
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
Configure os arquivos de opções do Firebase

Execute o gerador de código

flutter pub run build_runner build --delete-conflicting-outputs

Execute o app

### Desenvolvimento (DEV)

```bash
# Executar em debug
flutter run --flavor dev --dart-define-from-file=config/config_dev.json

# Build Debug
flutter build apk --flavor dev --dart-define-from-file=config/config_dev.json

# Build Release
flutter build apk --flavor dev --dart-define-from-file=config/config_dev.json --release
```

### Homologação (HML)

```bash
# Executar em debug
flutter run --flavor hml --dart-define-from-file=config/config_hml.json

# Build Debug
flutter build apk --flavor hml --dart-define-from-file=config/config_hml.json

# Build Release
flutter build apk --flavor hml --dart-define-from-file=config/config_hml.json --release
```

### Produção (PROD)

````bash
# Executar em debug (raro, apenas para testes)
flutter run --flavor prod --dart-define-from-file=config/config_prod.json

# Build Debug
flutter build apk --flavor prod --dart-define-from-file=config/config_prod.json

# Build Release (RECOMENDADO)
flutter build apk --flavor prod --dart-define-from-file=config/config_prod.json --release
``` --target lib/main.dart

🧪 Testes

# Executar todos os testes
flutter test

# Com cobertura
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Testes específicos
flutter test test/features/auth

📱 Features Implementadas
✅ Concluído
    Autenticação com email/senha
    Onboarding
    Dashboard inicial
    Mural de avisos
    Perfil do usuário

🚧 Em Desenvolvimento
    Módulo de reservas
    Chat interno
    Notificações push

📅 Próximas Features
    Módulo financeiro
    Controle de acesso
    Documentos
    Ocorrências
    Prestadores de serviço

📋 Convenções de Código
Nomenclatura
    Classes: PascalCase
    Variáveis/métodos: camelCase
    Arquivos: snake_case.dart
    Constantes: UPPER_CASE

Commits (Conventional Commits)

feat: adicionar módulo de reservas
fix: corrigir erro no login com Google
docs: atualizar README com instruções de setup
style: formatar código conforme lint
refactor: simplificar lógica do controller de avisos
test: adicionar testes para o repositório de reservas
chore: atualizar dependências

## 🚀 Deploy com Flavors e Dart Define

O padrão utiliza `--dart-define-from-file` para passar variáveis de ambiente sem expor dados sensíveis no código.

### Android

#### DEV - Desenvolvimento
```bash
# APK
flutter build apk --flavor dev --dart-define-from-file=config/config_dev.json --release

# App Bundle (Google Play)
flutter build appbundle --flavor dev --dart-define-from-file=config/config_dev.json --release
````

#### HML - Homologação

```bash
# APK
flutter build apk --flavor hml --dart-define-from-file=config/config_hml.json --release

# App Bundle (Google Play)
flutter build appbundle --flavor hml --dart-define-from-file=config/config_hml.json --release
```

#### PROD - Produção

```bash
# APK
flutter build apk --flavor prod --dart-define-from-file=config/config_prod.json --release

# App Bundle (Google Play) - **RECOMENDADO**
flutter build appbundle --flavor prod --dart-define-from-file=config/config_prod.json --release
```

### iOS

#### DEV

```bash
flutter build ios --flavor dev --dart-define-from-file=config/config_dev.json --release
```

#### HML

```bash
flutter build ios --flavor hml --dart-define-from-file=config/config_hml.json --release
```

#### PROD

```bash
flutter build ios --flavor prod --dart-define-from-file=config/config_prod.json --release
```

### Onde Encontrar os Builds

- **APK**: `build/app/outputs/apk/{flavor}/release/app-{flavor}-release.apk`
- **App Bundle**: `build/app/outputs/bundle/{flavor}Release/app-{flavor}-release.aab`

### Registrar SHA-1 para cada Flavor

⚠️ **IMPORTANTE**: O Firebase precisa do SHA-1 certificate hash de cada flavor para funcionar:

1. **Android Debug SHA-1** (para DEV/HML):

   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

2. **Android Release SHA-1** (para PROD):

   ```bash
   keytool -list -v -keystore android/app/keys/production.keystore -alias {alias} -storepass {password}
   ```

3. Registre cada SHA-1 no [Firebase Console](https://console.firebase.google.com/):
   - **DEV**: Firebase Console → Seu Projeto DEV → Configurações → Certificados SHA
   - **HML**: Firebase Console → Seu Projeto HML → Configurações → Certificados SHA
   - **PROD**: Firebase Console → Seu Projeto PROD → Configurações → Certificados SHA

🤝 Contribuição
Crie uma branch a partir da develop
Implemente suas alterações
Adicione testes
Execute flutter analyze e flutter test
Abra um Pull Request

📄 Licença

Este projeto é proprietário e confidencial. Todos os direitos reservados.
📞 Suporte

Para questões técnicas, entre em contato com o squad de desenvolvimento:
Tech Lead: [mauricio.developer@gmail.com]
Product Owner: [mauricio.developer@gmail.com]
Squad Mobile: [mauricio.developer@gmail.com]

ProntoSíndico — Simplificando a gestão do seu condomínio 🏢

```

```

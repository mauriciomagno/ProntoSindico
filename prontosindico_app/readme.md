# ProntoSíndico

Aplicativo completo para administração de condomínios, desenvolvido em Flutter com Firebase, seguindo as melhores práticas de mercado e arquitetura limpa.

## 📱 Sobre o Projeto

O ProntoSíndico é uma solução mobile que facilita a gestão de condomínios, oferecendo ferramentas para comunicação, finanças, reservas, ocorrências e muito mais. O app atende diferentes perfis de usuários:

- **Síndicos** — Gestão completa do condomínio
- **Administradores** — Suporte administrativo
- **Moradores** — Acesso a informações e serviços
- **Portaria** — Controle de acesso e visitantes
- **Prestadores** — Agendamento e serviços

📝 Resumo das Permissões

## usuarios

✅ Admin: Lista TODOS os usuários (raiz)
✅ Usuário: Lê apenas o próprio perfil ($uid)
✅ Admin: Edita qualquer perfil
✅ Usuário: Edita apenas o próprio perfil

## boletos

✅ Admin/Tesoureiro: Lê TODOS os boletos (raiz e filhos)
✅ Morador: Lê apenas os próprios boletos
✅ Admin/Tesoureiro: Cria/edita qualquer boleto

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

🔐 Firebase Configuration
Firestore Security Rules (Exemplo)

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
🚦 Ambientes

O projeto suporta três ambientes com configurações específicas:
Ambiente	Entrypoint	Firebase Config	Uso
DEV	main_dev.dart	firebase_options_dev.dart	Desenvolvimento local com emulador
HML	main_hml.dart	firebase_options_hml.dart	Homologação/Testes
PROD	main.dart	firebase_options_prod.dart	Produção

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

# Desenvolvimento (com emulador Firebase)
flutter run --target lib/main_dev.dart

# Homologação
flutter run --target lib/main_hml.dart

# Produção
flutter run --target lib/main.dart

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

🚀 Deploy
Android

# Homologação
flutter build apk --target lib/main_hml.dart --release
# ou bundle
flutter build appbundle --target lib/main_hml.dart --release

# Produção
flutter build apk --target lib/main.dart --release
flutter build appbundle --target lib/main.dart --release

iOS

# Homologação
flutter build ios --target lib/main_hml.dart --release

# Produção
flutter build ios --target lib/main.dart --release

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
    Tech Lead: [email]
    Product Owner: [email]
    Squad Mobile: [email]

ProntoSíndico — Simplificando a gestão do seu condomínio 🏢

```

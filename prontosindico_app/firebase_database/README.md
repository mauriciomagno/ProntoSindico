# Firebase Realtime Database - Regras de Segurança

Esta pasta contém os arquivos de configuração e regras de segurança do Firebase Realtime Database.

## 📁 Arquivos

### `database_rules.json`

Regras de segurança do Firebase Realtime Database com controle de acesso baseado em roles (RBAC).

### `firebase.json`

Configuração do Firebase CLI para deploy das regras.

## 🚀 Como Aplicar as Regras

### Opção 1: Firebase Console (Manual)

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Selecione o projeto **prontosindico-59bd4**
3. Vá em **Realtime Database** → **Regras**
4. Copie o conteúdo de `database_rules.json` e cole
5. Clique em **Publicar**

### Opção 2: Firebase CLI (Automatizado)

```bash
# Na pasta firebase_database
firebase deploy --only database
```

## 🔒 Resumo das Permissões

### `usuarios`

- **Leitura**: Todos autenticados
- **Escrita**: Próprio perfil OU Admin/Síndico

### `areas_comuns`

- **Leitura**: Todos autenticados
- **Escrita**: Admin/Síndico/Tesoureiro

### `reservas`

- **Leitura**: Todos autenticados
- **Escrita**: Dono da reserva OU Admin/Síndico/Tesoureiro

### `boletos`

- **Leitura**: Todos autenticados (filtrado no código)
- **Escrita**: Admin/Síndico/Tesoureiro

### `moradores`

- **Leitura**: Todos autenticados (filtrado no código)
- **Escrita**: Admin/Síndico

### `mural_avisos` e `comunicados`

- **Leitura**: Todos autenticados
- **Escrita**: Próprio autor E (Admin/Síndico/Tesoureiro)

### `config`

- **Leitura**: Todos autenticados
- **Escrita**: Admin/Síndico

## 🛡️ Segurança em Camadas

1. **Firebase Rules** (Servidor): Validação no banco de dados
2. **ResidentRepository** (Aplicação): Queries filtradas por role
3. **UI Controllers** (Apresentação): Filtros adicionais de visualização

## 📝 Notas Importantes

- As regras permitem leitura ampla em `usuarios`, `moradores` e `boletos` para compatibilidade com as queries atuais
- A segurança efetiva é garantida pela combinação das regras Firebase + queries filtradas no código
- Moradores só recebem seus próprios dados através do `_watchResidentForMorador()`
- Admins/Síndicos/Tesoureiros recebem dados completos através do `_watchAllResidents()`

## 🔄 Última Atualização

**Data**: 06/04/2026
**Versão**: 1.0.0 - Refatoração com queries filtradas baseadas em roles

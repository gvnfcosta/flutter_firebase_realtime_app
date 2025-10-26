# Flutter Firebase Realtime Database - Cadastro de Usuários (Provider)

Projeto mínimo com:
- Firebase Authentication (email/senha)
- Firebase Realtime Database (dados do usuário em /users/{uid})
- Provider para gerenciamento de estado
- Telas: Login, SignUp, UserForm (dados pessoais), UserData (exibe dados)

## Passos para rodar
1. Instale o Flutter e configure seu ambiente.
2. Crie um projeto Flutter ou extraia este zip como um diretório de projeto.
3. Substitua `android`/`ios` configurações pelo seu projeto Firebase ou rode `flutterfire configure` para gerar `lib/firebase_options.dart`.
4. No terminal do projeto: `flutter pub get`
5. Rode o app: `flutter run`

## Observações
- Este repositório contém os arquivos principais em `lib/` e o `pubspec.yaml` com as dependências.
- Você precisa configurar o Firebase (Android/iOS/Web) e gerar `firebase_options.dart`. Há um arquivo placeholder em `lib/firebase_options.dart`.
- Regras do Realtime Database (exemplo):

```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid"
      }
    }
  }
}
```

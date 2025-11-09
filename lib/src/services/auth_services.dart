import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../providers/user_provider.dart';
import '../../utils/local_storage.dart';
import '../config/app_routes.dart';

/// Serviço central de autenticação do app.
/// Controla login, cadastro, logout, login automático e mensagens de erro.
class AuthService {
  static const _defaultError =
      'Ocorreu um erro inesperado. Tente novamente.'; // mensagem padrão

  // ===============================================================
  // MÉTODOS AUXILIARES
  // ===============================================================

  /// Verifica se há conexão com a internet
  static Future<bool> hasInternet() async {
    final result = await Connectivity()
        .checkConnectivity(); // obtém status atual da rede
    return result !=
        ConnectivityResult.none; // retorna true se houver rede disponível
  }

  /// Exibe uma snackbar customizada no topo da tela (em vez da padrão do Flutter)
  static void _showSnack(BuildContext context, String message) {
    final overlay = Overlay.of(
      context,
    ); // acessa overlay da tela (camada superior)

    // Cria o conteúdo da snackbar
    final overlayEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        top:
            MediaQuery.of(ctx).padding.top +
            10, // posiciona logo abaixo da status bar
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red, // fundo vermelho
              borderRadius: BorderRadius.circular(8), // cantos arredondados
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2), // sombra leve
                  blurRadius: 6,
                ),
              ],
            ),
            child: Text(
              message, // mensagem recebida
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry); // insere a mensagem na tela
    Future.delayed(
      const Duration(seconds: 5),
    ).then((_) => overlayEntry.remove()); // remove após 5s
  }

  /// Traduz códigos de erro do FirebaseAuth para mensagens em português
  static String _mapFirebaseAuthCodeToMessage(String code) {
    return switch (code) {
      'network-request-failed' => 'Falha de conexão. Verifique sua internet.',
      'user-not-found' => 'Usuário não encontrado.',
      'wrong-password' => 'Senha incorreta.',
      'invalid-email' => 'Email inválido.',
      'email-already-in-use' => 'Este email já está em uso.',
      'weak-password' => 'Senha fraca. Use pelo menos 6 caracteres.',
      'user-disabled' => 'Conta desativada. Contate o suporte.',
      'operation-not-allowed' => 'Operação não permitida.',
      'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde.',
      'invalid-credential' => 'Conta não cadastrada ou expirada.',
      'invalid-verification-code' => 'Código de verificação inválido.',
      'invalid-verification-id' => 'ID de verificação inválido.',
      'credential-already-in-use' =>
        'Credencial já está em uso por outra conta.',
      _ => _defaultError, // fallback para erro genérico
    };
  }

  /// Carrega email e senha armazenados localmente (para login automático)
  static Future<void> loadSavedLogin({
    required TextEditingController emailCtrl,
    required TextEditingController passCtrl,
  }) async {
    final email =
        await LocalStorage.getEmail(); // obtém email salvo no storage local
    final pass = await LocalStorage.getPassword(); // obtém senha salva

    if (email != null) emailCtrl.text = email; // preenche campo email
    if (pass != null) passCtrl.text = pass; // preenche campo senha
  }

  // ===============================================================
  // FLUXO DE LOGIN E CADASTRO
  // ===============================================================

  /// 🧩 Etapa pós-login: busca dados do usuário e redireciona
  static Future<void> _handlePostLogin(BuildContext context, User user) async {
    final provider = context.read<UserProvider>(); // obtém o provider

    try {
      await provider.fetchUserData(user.uid); // busca dados no banco
    } catch (e) {
      debugPrint('⚠️ Erro ao buscar dados do usuário: $e');
    }

    if (!context.mounted) return; // segurança: evita usar context inválido

    if (provider.user == null) {
      // Usuário novo → redireciona para formulário de cadastro
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.userForm,
        arguments: user.uid,
      );
    } else {
      // Usuário já cadastrado → redireciona para tela principal
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (r) => false);
    }
  }

  // ===============================================================
  // LOGIN GENÉRICO (REUTILIZÁVEL)
  // ===============================================================

  /// Faz login no Firebase e executa navegação pós-login
  static Future<void> _signInAndNavigate(
    BuildContext context,
    String email,
    String password,
  ) async {
    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    ); // autentica no Firebase

    // Armazena credenciais para login automático
    await LocalStorage.saveLogin(cred.user!.uid, email, password);

    if (!context.mounted) return;

    // Executa o pós-login
    await _handlePostLogin(context, cred.user!);
  }

  // ===============================================================
  // LOGIN AUTOMÁTICO
  // ===============================================================

  /// Tenta autenticar automaticamente com base no que está salvo no dispositivo
  static Future<void> autoLogin({
    required BuildContext context,
    required TextEditingController emailCtrl,
    required TextEditingController passCtrl,
    required ValueChanged<bool> setLoading,
  }) async {
    try {
      await loadSavedLogin(
        emailCtrl: emailCtrl,
        passCtrl: passCtrl,
      ); // carrega credenciais

      if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) return; // nada salvo
      if (!await hasInternet()) return; // sem conexão

      setLoading(true); // ativa indicador de carregamento
      await _signInAndNavigate(
        context,
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      final msg = _mapFirebaseAuthCodeToMessage(e.code); // traduz erro
      _showSnack(context, msg); // mostra erro na tela
    } catch (e) {
      debugPrint('⚠️ Erro no autoLogin: $e');
      _showSnack(context, _defaultError);
    } finally {
      if (context.mounted) setLoading(false); // desativa loading
    }
  }

  // ===============================================================
  // LOGIN MANUAL
  // ===============================================================

  /// Realiza login após o usuário preencher os campos e clicar em “Entrar”
  static Future<void> login({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController emailCtrl,
    required TextEditingController passCtrl,
    required ValueChanged<bool> setLoading,
  }) async {
    if (!formKey.currentState!.validate()) return; // valida formulário

    if (!await hasInternet()) {
      _showSnack(context, 'Sem conexão com a internet.');
      return;
    }

    setLoading(true);
    try {
      await _signInAndNavigate(
        context,
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      final msg = _mapFirebaseAuthCodeToMessage(
        e.code,
      ); // traduz código de erro
      _showSnack(context, msg);
    } catch (e) {
      debugPrint('⚠️ Erro no login: $e');
      _showSnack(context, _defaultError);
    } finally {
      if (context.mounted) setLoading(false);
    }
  }

  // ===============================================================
  // CADASTRO DE NOVO USUÁRIO
  // ===============================================================

  /// Cria um novo usuário no Firebase e direciona para completar o perfil
  static Future<void> signUp({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController emailCtrl,
    required TextEditingController passCtrl,
    required TextEditingController confirmPassCtrl,
    required ValueChanged<bool> setLoading,
  }) async {
    if (!formKey.currentState!.validate()) return; // valida campos

    if (!await hasInternet()) {
      _showSnack(context, 'Sem conexão com a internet.');
      return;
    }

    setLoading(true);
    try {
      // Cria conta no Firebase
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      final uid = cred.user?.uid; // pega identificador único do usuário
      if (uid == null) throw Exception('Erro ao recuperar UID do usuário.');

      // Salva credenciais localmente
      await LocalStorage.saveLogin(
        uid,
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );

      _showSnack(context, 'Conta criada. Complete seu cadastro.');

      // Vai para tela de formulário de dados do usuário
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.userForm,
        arguments: uid,
      );
    } on FirebaseAuthException catch (e) {
      final msg = _mapFirebaseAuthCodeToMessage(e.code);
      _showSnack(context, msg);
    } catch (e) {
      debugPrint('⚠️ Erro no signUp: $e');
      _showSnack(context, _defaultError);
    } finally {
      if (context.mounted) setLoading(false);
    }
  }

  // ===============================================================
  // LOGOUT
  // ===============================================================

  /// Encerra sessão, limpa dados locais e redireciona para tela de login
  static Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // encerra sessão Firebase
      await LocalStorage.removeLogin(); // limpa credenciais locais

      _showSnack(context, 'Sessão encerrada.');

      // Retorna para tela inicial de login
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.signIn,
        (r) => false,
      );
    } catch (e) {
      _showSnack(context, 'Erro ao sair: $e');
    }
  }
}


// 🧭 Estrutura visual do código:

// Seção	  Tema	                   Descrição

// 🧩 1	    Métodos auxiliares	    Conectividade, snackbar e tradução de erros
// 🧭 2	    Pós-login	              Busca dados e redirecionamento
// 🔑 3	    Login genérico	        Reutilizável para manual e automático
// ⚙️ 4	    Login automático	      Usa dados salvos localmente
// 👤 5   	Login manual	           Quando o usuário preenche o formulário
// 🆕 6	    Cadastro	              Criação de nova conta
// 🚪 7	    Logout	                Finaliza sessão e limpa dados locais
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/providers/user_provider.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_colors.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_routes.dart';
import 'package:flutter_firebase_realtime_app/src/screens/user/user_bottom_sheet.dart';
import 'package:flutter_firebase_realtime_app/utils/local_storage.dart';
import 'package:provider/provider.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final provider = context.read<UserProvider>();
      await provider.fetchUserData(currentUser.uid);

      final userData = provider.user;

      if (userData == null) {
        await _goToUserForm();
        return;
      }

      if (mounted) {
        setState(() {
          _userData = userData.toMap();
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados do usuário: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _goToUserForm() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !mounted) return;

    await Navigator.pushNamed(context, AppRoutes.userForm, arguments: user.uid);

    _loadUserData();
  }

  Future<void> _logout() async {
    await LocalStorage.removeLogin();
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.signIn, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final userInfo = userProvider.user;
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_userData == null) {
      return const Scaffold(body: Center(child: Text('Redirecionando...')));
    }

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de ${userInfo?.name ?? ''}'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Hero(tag: 'user_avatar_$userId', child: _buildAvatar(theme)),
            const SizedBox(height: 24),
            _buildUserInfoCard(_userData!, theme),
            const SizedBox(height: 40),
            _buildEditButton(theme, userId),
          ],
        ),
      ),
    );
  }

  /// 🟣 Avatar circular com gradiente e sombra suave
  Widget _buildAvatar(ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.9),
            theme.colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(Icons.person, size: 72, color: AppColors.foregroundButton),
      ),
    );
  }

  /// 📄 Card elegante com informações do usuário
  Widget _buildUserInfoCard(Map<String, dynamic> data, ThemeData theme) {
    final labelStyle = theme.textTheme.titleMedium?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
    );

    final valueStyle = theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onSurface,
    );

    Widget infoRow(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: labelStyle),
          Expanded(child: Text(value, style: valueStyle)),
        ],
      ),
    );

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            infoRow('Nome', data['name'] ?? '-'),
            infoRow('E-mail', data['email'] ?? '-'),
            infoRow('ID', FirebaseAuth.instance.currentUser?.uid ?? '-'),
            infoRow('Code', data['code'] ?? '-'),
            infoRow('Nível', _getRoleName(data['level'])),
          ],
        ),
      ),
    );
  }

  /// ✏️ Botão moderno de edição com Hero animation
  Widget _buildEditButton(ThemeData theme, String userId) {
    return Hero(
      tag: 'edit_button_$userId',
      child: ElevatedButton.icon(
        onPressed: () =>
            UserBottomSheet.show(context, uid: userId), //_goToUserForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        icon: const Icon(Icons.edit_outlined, size: 22),
        label: const Text(
          'Editar Dados',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String _getRoleName(dynamic level) {
    switch (level) {
      case 2:
        return 'Admin';
      case 1:
        return 'Usuário';
      case 0:
        return 'Inativo';
      default:
        return '-';
    }
  }
}

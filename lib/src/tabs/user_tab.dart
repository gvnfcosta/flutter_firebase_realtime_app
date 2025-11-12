import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_realtime_app/src/services/auth/delete_account_service.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../common/custom_widgets.dart';
import '../config/app_colors.dart';
import '../config/app_routes.dart';
import '../screens/components/app_drawer.dart';
import '../screens/user/user_bottom_sheet.dart';
import '../services/auth/auth_service.dart';

class UserTab extends StatefulWidget {
  const UserTab({super.key});

  @override
  State<UserTab> createState() => _UserTabState();
}

class _UserTabState extends State<UserTab> {
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

    await Navigator.pushReplacementNamed(
      context,
      AppRoutes.userForm,
      arguments: user.uid,
    );

    _loadUserData();
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
      appBar: CustomAppBar(aboveText: 'Perfil de ${userInfo?.name ?? ''}'),
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
            const SizedBox(height: 16),
            _buildDeleteButton(theme, userId),
          ],
        ),
      ),
      drawer: AppDrawer(),
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
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoCard(
              icon: Icons.people,
              label: 'Nome',
              value: data['name'] ?? '-',
            ),
            InfoCard(
              icon: Icons.email,
              label: 'E-mail',
              value: data['email'] ?? '-',
            ),
            InfoCard(
              icon: Icons.numbers,
              label: 'ID',
              value: FirebaseAuth.instance.currentUser?.uid ?? '-',
            ),
            InfoCard(
              icon: Icons.code,
              label: 'Code',
              value: data['code'] ?? '-',
            ),
            InfoCard(
              icon: Icons.leave_bags_at_home,
              label: 'Nível',
              value: _getRoleName(data['level']),
            ),
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
        onPressed: () => UserBottomSheet.show(context, uid: userId),
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

  /// 🗑️ Botão de exclusão de conta
  Widget _buildDeleteButton(ThemeData theme, String userId) {
    return ElevatedButton.icon(
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Excluir conta'),
            content: const Text(
              'Tem certeza de que deseja excluir permanentemente sua conta? Esta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text('Excluir'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await DeleteAccountService.deleteAccount(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      icon: const Icon(Icons.delete_forever, size: 22),
      label: const Text(
        'Excluir Conta',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

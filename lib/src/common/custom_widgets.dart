import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_colors.dart';

/// 🔹 Indicador de progresso customizado
class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 36,
        width: 36,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          backgroundColor: Colors.white24,
          color: AppColors.foregroundIcon,
        ),
      ),
    );
  }
}

/// 🔹 Classe base abstrata para AppBars customizadas
abstract class DefaultAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String aboveText;
  final String? belowText;
  final Icon? leading;
  final bool showBackButton;

  const DefaultAppBar({
    super.key,
    required this.aboveText,
    this.belowText,
    this.leading,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context);
}

/// 🔹 Implementação padrão da AppBar
class CustomAppBar extends DefaultAppBar {
  const CustomAppBar({
    super.key,
    required super.aboveText,
    super.belowText,
    super.leading,
    super.showBackButton,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton ? null : leading,
      title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                aboveText,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,

                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (belowText != null)
                Text(
                  belowText!.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ],
      ),
      centerTitle: true,
    );
  }
}

/// 🔹 Cartão de informação padrão
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.withValues(alpha: 0.1),
          child: Icon(icon, color: Colors.teal),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}

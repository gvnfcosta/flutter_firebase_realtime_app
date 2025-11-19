import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/models/client_model.dart';
import 'package:flutter_firebase_realtime_app/src/common/custon_functions.dart';

import 'package:flutter_firebase_realtime_app/src/config/app_colors.dart';

class ClientCard extends StatelessWidget {
  final ClientModel client;
  final VoidCallback? onTap;

  const ClientCard({super.key, required this.client, this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Card(
            elevation: 3,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              splashColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícone ilustrativo
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.business,
                        size: 28,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Nome do cliente
                    Expanded(
                      child: Text(
                        capitalize(client.name),
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../models/client_model.dart';
import '../../../common/custon_functions.dart';

class ClientHeaderCard extends StatelessWidget {
  final ClientModel client;
  const ClientHeaderCard(this.client, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            child: Text(
              getInitials(client.name),
              style: TextStyle(
                fontSize: 28,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  client.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

Future<bool> confirmDelete(BuildContext context, String name) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Excluir Cliente'),
          content: Text(
            'Deseja excluir $name?',
            style: const TextStyle(color: Colors.red),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        ),
      ) ??
      false;
}

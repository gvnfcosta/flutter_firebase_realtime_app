import 'package:flutter/material.dart';

Widget customButton(BuildContext context, String text) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(text, style: TextStyle(color: Colors.grey[400]!)),
      ),
    ],
  );
}

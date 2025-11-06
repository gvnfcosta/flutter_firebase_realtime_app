import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/client_app.dart';
import 'package:flutter_firebase_realtime_app/providers/client_provider.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_firebase_realtime_app/providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeFirebase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
      ],
      child: const ClientApp(),
    ),
  );
}

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase inicializado com sucesso!");
  } catch (e) {
    debugPrint("Erro ao inicializar Firebase: $e");
  }
}

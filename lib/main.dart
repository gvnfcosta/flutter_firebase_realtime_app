import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase_realtime_app/providers/user_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'package:flutter_firebase_realtime_app/client_app.dart';
import 'package:flutter_firebase_realtime_app/providers/client_provider.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: AppColors.appBarBackground,
      statusBarIconBrightness: Brightness.light,
    ),
  );

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
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    debugPrint("Firebase inicializado com sucesso!");
  } catch (e) {
    debugPrint("Erro ao inicializar Firebase: $e");
  }
}

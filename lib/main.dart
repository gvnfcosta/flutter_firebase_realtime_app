// lib/main.dart
import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_realtime_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'screens/signin_screen.dart';
import 'screens/user_form_screen.dart';
import 'screens/user_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (kIsWeb) {
  //   // Força registro do plugin no web
  //   await SharedPreferences.setMockInitialValues({});
  // }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Cadastro de Usuário',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    if (user == null) return const SignInScreen();
    return FutureBuilder(
      future: _checkUserData(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final hasData = snapshot.data ?? false;
        return hasData
            ? const UserDetailScreen()
            : UserFormScreen(uid: user.uid);
      },
    );
  }

  Future<bool> _checkUserData(String uid) async {
    final ref = FirebaseDatabase.instance.ref('users/$uid');
    final snapshot = await ref.get();
    return snapshot.exists;
  }
}

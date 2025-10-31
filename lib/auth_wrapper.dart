import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_firebase_realtime_app/screens/signin_screen.dart';
import 'package:flutter_firebase_realtime_app/screens/user_detail_screen.dart';
import 'package:flutter_firebase_realtime_app/screens/user_form_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  /// Checa se o usuário já possui perfil no Firebase Realtime Database
  Future<bool> _userHasProfile(String uid) async {
    final snapshot = await FirebaseDatabase.instance.ref('users/$uid').get();
    return snapshot.exists;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1️⃣ Loading inicial
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2️⃣ Usuário não autenticado → SignInScreen
        if (!snapshot.hasData) {
          return const SignInScreen();
        }

        // 3️⃣ Usuário autenticado → verifica perfil
        final user = snapshot.data!;

        return FutureBuilder<bool>(
          future: _userHasProfile(user.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final hasProfile = profileSnapshot.data ?? false;

            // 4️⃣ Redireciona para UserFormScreen se ainda não tiver perfil
            if (!hasProfile) {
              return UserFormScreen(uid: user.uid); // 🔹 envia uid
            }

            // 5️⃣ Redireciona para UserDetailScreen se já tiver perfil
            return const UserDetailScreen();
          },
        );
      },
    );
  }
}

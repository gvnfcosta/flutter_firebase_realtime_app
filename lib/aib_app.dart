import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/auth_wrapper.dart';
import 'package:flutter_firebase_realtime_app/screens/splash_screen.dart';

import 'package:flutter_firebase_realtime_app/src/config/app_routes.dart';
import 'package:flutter_firebase_realtime_app/screens/signin_screen.dart';
import 'package:flutter_firebase_realtime_app/screens/signup_screen.dart';
import 'package:flutter_firebase_realtime_app/screens/user_detail_screen.dart';
import 'package:flutter_firebase_realtime_app/screens/user_form_screen.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_theme.dart';

class AibApp extends StatelessWidget {
  const AibApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Firebase Realtime App',
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash, // Agora começa no splash
        theme: appTheme,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.splash:
              return MaterialPageRoute(
                builder: (_) => const SplashScreen(),
              );

            case AppRoutes.wrapper:
              return MaterialPageRoute(
                builder: (_) => const AuthWrapper(),
              );

            case AppRoutes.signIn:
              return MaterialPageRoute(
                builder: (_) => const SignInScreen(),
              );

            case AppRoutes.signUp:
              return MaterialPageRoute(
                builder: (_) => const SignUpScreen(),
              );

            case AppRoutes.userForm:
              final uid = settings.arguments as String?;
              if (uid == null) {
                throw Exception('UID obrigatório para UserFormScreen');
              }
              return MaterialPageRoute(
                builder: (_) => UserFormScreen(uid: uid),
              );

            case AppRoutes.userDetail:
              return MaterialPageRoute(
                builder: (_) => const UserDetailScreen(),
              );

            default:
              return MaterialPageRoute(
                builder: (_) => const SplashScreen(),
              );
          }
        });
  }
}

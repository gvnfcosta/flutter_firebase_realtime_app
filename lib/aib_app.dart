import 'package:flutter/material.dart';

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
      initialRoute: '/signin',
      routes: {
        AppRoutes.signIn: (_) => const SignInScreen(),
        AppRoutes.signUp: (_) => const SignUpScreen(),
        AppRoutes.userForm: (_) => const UserFormScreen(),
        AppRoutes.userDetail: (_) => const UserDetailScreen(),
      },
      theme: appTheme,
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_colors.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_data.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_realtime_app/src/services/auth_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Controla o fade da logo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _controller.forward();

    // Espera animação + checa login
    Timer(const Duration(seconds: 2), _checkLoginStatus);
  }

  Future<void> _checkLoginStatus() async {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    bool autoLogged = false;

    try {
      await AuthService.autoLogin(
        context: context,
        emailCtrl: emailCtrl,
        passCtrl: passCtrl,
        setLoading: (_) {},
      );
      // Se o usuário foi logado automaticamente, _handlePostLogin já fez o Navigator
      autoLogged = FirebaseAuth.instance.currentUser != null;
    } catch (e) {
      debugPrint("Erro no autoLogin da SplashScreen: $e");
    }

    if (!mounted) return;

    if (!autoLogged) {
      Navigator.pushReplacementNamed(context, AppRoutes.signIn);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.38),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: 400,
                      child: Text(
                        programName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Arbotek',
                          color: Colors.green,
                          fontSize: 36,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 100),
                SizedBox(
                  width: 300,
                  child: LinearProgressIndicator(
                    color: Colors.green.shade200,
                    backgroundColor: AppColors.foregroundIcon,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: (size.height / 2.5) - 300,
            left: 0,
            right: 0,
            child: Center(
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.jpg',
                  height: 250,
                  width: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

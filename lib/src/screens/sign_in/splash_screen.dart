import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_colors.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_realtime_app/src/services/auth/auth_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'widgets/app_title.dart';

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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    Timer(const Duration(seconds: 3), _checkLoginStatus);
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          /// Fundo com gradiente sutil
          Container(decoration: BoxDecoration(color: Colors.white)),

          /// Conteúdo principal
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              appTitle(size),

              SizedBox(height: 30),

              /// Logo com animação de fade + scale
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeOutBack,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(200),
                  child:
                      Image.asset(
                            'assets/images/Logo.jpg',
                            height: 160,
                            width: 160,
                            fit: BoxFit.cover,
                          )
                          .animate()
                          .fadeIn(duration: 1200.ms)
                          .scale(duration: 800.ms, curve: Curves.easeOutBack),
                ),
              ),

              const SizedBox(height: 40),

              /// Barra de progresso
              SizedBox(
                width: size.width * 0.6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      LinearProgressIndicator(
                            minHeight: 6,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.3,
                            ),
                            color: AppColors.foregroundIcon.withValues(
                              alpha: 0.9,
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .shimmer(duration: 1800.ms),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }
}
